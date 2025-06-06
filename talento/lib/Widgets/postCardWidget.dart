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
      final doc =
          await FirebaseFirestore.instance
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
                const Text(
                  'Comments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('TalentoPosts')
                            .doc(postId)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final comments = List<Map<String, dynamic>>.from(
                        data['comments'] ?? [],
                      );
                      if (comments.isEmpty) {
                        return const Center(child: Text('No comments yet'));
                      }
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[comments.length - 1 - index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  comment['userPhoto'] != null &&
                                          comment['userPhoto'] != ""
                                      ? NetworkImage(comment['userPhoto'])
                                      : const AssetImage(
                                            'assets/images/user.png',
                                          )
                                          as ImageProvider,
                            ),
                            title: Text(
                              comment['username'] ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(comment['text'] ?? ''),
                            trailing: Text(
                              comment['timestamp'] != null
                                  ? timeago.format(
                                    (comment['timestamp'] as Timestamp?)
                                            ?.toDate() ??
                                        DateTime.tryParse(
                                          comment['timestamp'].toString(),
                                        ) ??
                                        DateTime.now(),
                                  )
                                  : 'Just now',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
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
                          final userDoc =
                              await FirebaseFirestore.instance
                                  .collection('TalentoUsers')
                                  .doc(user.uid)
                                  .get();
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
                                'comments': FieldValue.arrayUnion([
                                  commentData,
                                ]),
                                'commentCount': FieldValue.increment(1),
                                'commentBy': FieldValue.arrayUnion([
                                  {'uid': user.uid, 'comment': text},
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
                child:
                    widget.post.type == 'video'
                        ? AspectRatio(
                          aspectRatio:
                              9 / 16, // Instagram-style vertical video ratio
                          child: PostVideoPlayer(
                            url: widget.post.mediaUrl,
                            autoPlay: true,
                            showControls: true,
                            aspectRatio: 9 / 16,
                          ),
                        )
                        : Image.network(
                          widget.post.mediaUrl,
                          height: MediaQuery.of(context).size.width,
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
                        builder:
                            (context) => ProfileScreen(userId: widget.post.uId),
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
                        builder:
                            (context) => SafeArea(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await FirebaseFirestore.instance
                                      .collection('TalentoPosts')
                                      .doc(widget.post.postId)
                                      .delete();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Post deleted'),
                                      ),
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
                          stream:
                              FirebaseFirestore.instance
                                  .collection('TalentoPosts')
                                  .doc(widget.post.postId)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text(
                                '0',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              );
                            }
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
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
                      likeBuilder:
                          (isLiked) => Container(
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
                      countBuilder:
                          (count, isLiked, text) => Text(
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (text) async {
                        final trimmed = text.trim();
                        if (trimmed.isEmpty) return;
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        final userDoc =
                            await FirebaseFirestore.instance
                                .collection('TalentoUsers')
                                .doc(user.uid)
                                .get();
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
                                {'uid': user.uid, 'comment': trimmed},
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
                      final userDoc =
                          await FirebaseFirestore.instance
                              .collection('TalentoUsers')
                              .doc(user.uid)
                              .get();
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
                              {'uid': user.uid, 'comment': text},
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
    this.autoPlay = true,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
    Key? key,
  }) : super(key: key);

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _showControls = false;
  bool _isBuffering = false;
  bool _hasError = false;
  bool _isInitialized = false;
  late AnimationController _progressController;
  Timer? _controlsTimer;
  bool _isDoubleTapEnabled = false;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller =
        VideoPlayerController.network(widget.url)
          ..setLooping(true)
          ..setVolume(0.0)
          ..addListener(_videoListener);

    _initializeVideoPlayerFuture = _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
              _isDoubleTapEnabled = true;
            });
            if (widget.autoPlay) {
              _controller.play();
              _isPlaying = true;
            }
          }
        })
        .catchError((error) {
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

    final progress =
        _controller.value.position.inMilliseconds /
        (_controller.value.duration.inMilliseconds == 0
            ? 1
            : _controller.value.duration.inMilliseconds);
    _progressController.value = progress;

    setState(() {
      _isPlaying = _controller.value.isPlaying;
      _isBuffering = _controller.value.isBuffering;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showControls = true;
    });
    _startControlsTimer();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
    _startControlsTimer();
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && !_isBuffering) {
        setState(() => _showControls = false);
      }
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (!_isDoubleTapEnabled) return;

    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      final screenWidth = MediaQuery.of(context).size.width;
      final tapPosition = details.globalPosition.dx;

      if (tapPosition < screenWidth / 2) {
        // Double tap on left - rewind 10 seconds
        final newPosition =
            _controller.value.position - const Duration(seconds: 10);
        _controller.seekTo(newPosition);
      } else {
        // Double tap on right - forward 10 seconds
        final newPosition =
            _controller.value.position + const Duration(seconds: 10);
        _controller.seekTo(newPosition);
      }
      _showControls = true;
      _startControlsTimer();
    }
    _lastTapTime = now;
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _progressController.dispose();
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
      onTapDown: _handleDoubleTap,
      onTap: () {
        _togglePlayPause();
        setState(() => _showControls = true);
        _startControlsTimer();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player with proper sizing
          SizedBox(
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

          // Dark overlay when controls are shown
          if (_showControls)
            Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
            ),

          // Progress bar at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressController.value,
                  backgroundColor: Colors.grey[800]?.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                );
              },
            ),
          ),

          // Double tap indicators
          if (_showControls)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: double.infinity,
                    color: Colors.transparent,
                    child: const Center(
                      child: Icon(
                        Icons.fast_rewind,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 100,
                    height: double.infinity,
                    color: Colors.transparent,
                    child: const Center(
                      child: Icon(
                        Icons.fast_forward,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Buffering indicator
          if (_isBuffering)
            Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            ),

          // Play/Pause overlay - Always create the widget but control opacity
          Center(
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),

          // Mute/Unmute button
          Positioned(
            bottom: 8,
            right: 8,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _toggleMute,
                ),
              ),
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
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isInitialized = false;
                  });
                  _initializeVideo();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
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
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
