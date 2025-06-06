import 'dart:async';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talento/Models/postModel.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Views/profileScreen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;
  String fullName = '';
  String username = '';
  String photoUrl = '';
  final TextEditingController commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    isLiked = user != null && widget.post.likedBy.contains(user!.uid);
    likeCount = widget.post.likesCount;
    fetchUserInfo(widget.post.uId);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> fetchUserInfo(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('TalentoUsers')
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          fullName = data['fullName'] ?? '';
          username = data['username'] ?? '';
          photoUrl = data['profilePhotoUrl'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  void _showCommentsSheet(BuildContext context) {
    final postId = widget.post.postId;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('TalentoPosts')
                        .doc(postId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
                      if (comments.isEmpty) {
                        return const Center(child: Text('No comments yet'));
                      }
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[comments.length - 1 - index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment['userPhoto'] != null && comment['userPhoto'] != ""
                                  ? NetworkImage(comment['userPhoto'])
                                  : const AssetImage('assets/Images/user.png') as ImageProvider,
                            ),
                            title: Text(comment['username'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(comment['text'] ?? ''),
                            trailing: Text(
                              comment['timestamp'] != null
                                  ? timeago.format(
                                      (comment['timestamp'] as Timestamp?)?.toDate() ??
                                      DateTime.tryParse(comment['timestamp'].toString()) ??
                                      DateTime.now())
                                  : 'Just now',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.orange),
                        onPressed: () async {
                          final text = commentController.text.trim();
                          if (text.isEmpty) return;
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          final userDoc = await FirebaseFirestore.instance.collection('TalentoUsers').doc(user.uid).get();
                          final userData = userDoc.data() ?? {};
                          final commentData = {
                            'userId': user.uid,
                            'username': userData['username'] ?? '',
                            'userPhoto': userData['profilePic'] ?? '',
                            'text': text,
                            'timestamp': DateTime.now(),
                          };
                          await FirebaseFirestore.instance
                              .collection('TalentoPosts')
                              .doc(postId)
                              .update({
                            'comments': FieldValue.arrayUnion([commentData]),
                            'commentCount': FieldValue.increment(1),
                            'commentBy': FieldValue.arrayUnion([
                              {'uid': user.uid, 'comment': text}
                            ]),
                          });
                          commentController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Post Image with overlay content
          Stack(
            children: [
              // Background Media (Image or Video)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: widget.post.type == 'video'
                    ? PostVideoPlayer(
  url: widget.post.mediaUrl,
  autoPlay: false, // set to true if you want video to play automatically
  showControls: true, // set to false if you want minimal controls
  aspectRatio: 1/1, // adjust based on your video's aspect ratio
)
                    : Image.network(
                        widget.post.mediaUrl,
                        height: 360,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              // User Info (Top Left)
              Positioned(
                top: 16,
                left: 16,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: widget.post.uId),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            photoUrl.isNotEmpty
                                ? photoUrl
                                : 'https://via.placeholder.com/150',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            timeago.format(widget.post.timestamp.toDate()),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // 3-dots menu for owner
              if (user != null && user!.uid == widget.post.uId)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: const Text('Delete', style: TextStyle(color: Colors.red)),
                            onTap: () async {
                              Navigator.pop(context);
                              await FirebaseFirestore.instance
                                  .collection('TalentoPosts')
                                  .doc(widget.post.postId)
                                  .delete();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Post deleted')),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Comments & Likes (Right Center)
              Positioned(
                right: 16,
                top: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showCommentsSheet(context),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 15),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('TalentoPosts')
                              .doc(widget.post.postId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text(
                                '0',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              );
                            }
                            final data = snapshot.data!.data() as Map<String, dynamic>;
                            final commentCount = data['commentCount'] ?? 0;
                            return Text(
                              '$commentCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LikeButton(
                      size: 48,
                      isLiked: isLiked,
                      likeCount: likeCount,
                      likeBuilder: (isLiked) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      countBuilder: (count, isLiked, text) => Text(
                        '${count ?? 0}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      onTap: (isLikedNow) async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return !isLikedNow;

                        final ref = FirebaseFirestore.instance
                            .collection('TalentoPosts')
                            .doc(widget.post.postId);

                        if (isLikedNow) {
                          await ref.update({
                            'likedBy': FieldValue.arrayRemove([user.uid]),
                            'likesCount': FieldValue.increment(-1),
                          });
                          setState(() {
                            isLiked = false;
                            likeCount--;
                          });
                        } else {
                          await ref.update({
                            'likedBy': FieldValue.arrayUnion([user.uid]),
                            'likesCount': FieldValue.increment(1),
                          });
                          setState(() {
                            isLiked = true;
                            likeCount++;
                          });
                        }
                        return !isLikedNow;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // --- Bottom Section: Add Comment
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (text) async {
                        final trimmed = text.trim();
                        if (trimmed.isEmpty) return;
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        final userDoc = await FirebaseFirestore.instance.collection('TalentoUsers').doc(user.uid).get();
                        final userData = userDoc.data() ?? {};
                        final commentData = {
                          'userId': user.uid,
                          'username': userData['username'] ?? '',
                          'userPhoto': userData['profilePic'] ?? '',
                          'text': trimmed,
                          'timestamp': DateTime.now(),
                        };
                        await FirebaseFirestore.instance
                            .collection('TalentoPosts')
                            .doc(widget.post.postId)
                            .update({
                          'comments': FieldValue.arrayUnion([commentData]),
                          'commentCount': FieldValue.increment(1),
                          'commentBy': FieldValue.arrayUnion([
                            {'uid': user.uid, 'comment': trimmed}
                          ]),
                        });
                        commentController.clear();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.orange),
                    onPressed: () async {
                      final text = commentController.text.trim();
                      if (text.isEmpty) return;
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      final userDoc = await FirebaseFirestore.instance.collection('TalentoUsers').doc(user.uid).get();
                      final userData = userDoc.data() ?? {};
                      final commentData = {
                        'userId': user.uid,
                        'username': userData['username'] ?? '',
                        'userPhoto': userData['profilePic'] ?? '',
                        'text': text,
                        'timestamp': DateTime.now(),
                      };
                      await FirebaseFirestore.instance
                          .collection('TalentoPosts')
                          .doc(widget.post.postId)
                          .update({
                        'comments': FieldValue.arrayUnion([commentData]),
                        'commentCount': FieldValue.increment(1),
                        'commentBy': FieldValue.arrayUnion([
                          {'uid': user.uid, 'comment': text}
                        ]),
                      });
                      commentController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PostVideoPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool showControls;
  final double aspectRatio;

  const PostVideoPlayer({
    required this.url,
    this.autoPlay = false,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
    Key? key,
  }) : super(key: key);

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _isBuffering = false;
  bool _hasError = false;
  bool _isInitialized = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.network(widget.url)
      ..addListener(_videoListener);

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _totalDuration = _controller.value.duration;
        });
        if (widget.autoPlay) {
          _controller.play();
          _isPlaying = true;
        }
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      debugPrint('Video player error: $error');
    });
  }

  void _videoListener() {
    if (!mounted) return;
    
    setState(() {
      _isPlaying = _controller.value.isPlaying;
      _isBuffering = _controller.value.isBuffering;
      _currentPosition = _controller.value.position;
      _totalDuration = _controller.value.duration;
      
      // Show controls when buffering
      if (_isBuffering) {
        _showControls = true;
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
      _showControls = true;
    });
    
    // Hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isBuffering) {
        setState(() => _showControls = false);
      }
    });
  }

  void _seekTo(Duration position) {
    _controller.seekTo(position);
    if (!_isPlaying) {
      _controller.pause();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  void _showFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: PostVideoPlayer(
              url: widget.url,
              autoPlay: true,
              showControls: true,
              aspectRatio: _controller.value.aspectRatio,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return GestureDetector(
      onTap: () {
        if (widget.showControls) {
          setState(() => _showControls = !_showControls);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player
          AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // Buffering indicator
          if (_isBuffering)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),

          // Play/pause overlay
          if (!_isPlaying && !_showControls)
            Icon(
              Icons.play_circle_filled,
              color: Colors.white.withOpacity(0.8),
              size: 64,
            ),

          // Controls overlay
          if (widget.showControls && _showControls)
            _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top controls
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: _showFullScreen,
              ),
            ],
          ),

          // Center play/pause button
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 48,
            ),
            onPressed: _togglePlayPause,
          ),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Progress bar
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.red,
                    inactiveTrackColor: Colors.grey,
                    trackHeight: 2,
                    thumbColor: Colors.red,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayColor: Colors.red.withAlpha(32),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _totalDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _seekTo(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                // Time indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        color: Colors.black12,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitialized = false;
                  });
                  _initializeVideo();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        color: Colors.black12,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}