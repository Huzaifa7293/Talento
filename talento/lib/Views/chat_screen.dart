import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talento/Views/chat_details_screen.dart';
import 'package:talento/Widgets/appBarWidget.dart';
import 'package:talento/utils/appColors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool _isLoading = false;
  String photoUrl = "";
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      DocumentSnapshot currentUserDoc =
          await FirebaseFirestore.instance
              .collection('TalentoUsers')
              .doc(currentUser)
              .get();

      if (currentUserDoc.exists) {
        Map<String, dynamic> userData =
            currentUserDoc.data() as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            photoUrl = userData['profilePhotoUrl'];
          });
        }
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Chats"),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(child: _buildInboxList()), // Added Expanded here
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search Here",
            hintStyle: const TextStyle(fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
          ),
          onChanged: (val) {
            setState(() => searchQuery = val.trim());
          },
        ),
      ),
    );
  }

  Widget _buildInboxList() {
    if (searchQuery.isNotEmpty) {
      return _buildSearchedUsersList();
    } else {
      return _buildRecentChats();
    }
  }

  Widget _buildSearchedUsersList() {
    final String normalizedQuery = searchQuery.toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('TalentoUsers')
              .orderBy('username')
              .startAt([normalizedQuery])
              .endAt([normalizedQuery + '\uf8ff'])
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        final users =
            snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data.containsKey('username') &&
                  data['username'] != null &&
                  (data['username'] as String).toLowerCase().contains(
                    normalizedQuery,
                  );
            }).toList();

        if (users.isEmpty) {
          return const Center(child: Text('No matching users found'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            return _buildUserCard(userDoc);
          },
        );
      },
    );
  }

  Widget _buildRecentChats() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('TalentoChats')
        .where('users', arrayContains: currentUser)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        debugPrint('Error: ${snapshot.error}');
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text('No chats yet', style: TextStyle(color: Colors.grey)),
        );
      }

      final docs = snapshot.data!.docs;

      // Sort by lastMessageTime descending
      docs.sort((a, b) {
        final aTime = (a['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime(0);
        final bTime = (b['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      return ListView.builder(
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final chatData = docs[index].data() as Map<String, dynamic>;
          final users = chatData['users'] as List<dynamic>;

          if (users.length < 2) {
            return const SizedBox.shrink();
          }

          final otherUserId = users.firstWhere(
            (id) => id != currentUser,
            orElse: () => null,
          );

          if (otherUserId == null) return const SizedBox.shrink();

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('TalentoUsers')
                .doc(otherUserId)
                .get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  leading: CircleAvatar(),
                  title: Text('Loading...'),
                );
              }

              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const SizedBox();
              }

              final userDoc = userSnap.data!;
              final lastMessage = chatData['lastMessage'] ?? '';
              final lastMessageTime =
                  chatData['lastUpdated'] != null
                      ? (chatData['lastUpdated'] as Timestamp).toDate()
                      : null;

              return _buildChatCard(userDoc, lastMessage, lastMessageTime);
            },
          );
        },
      );
    },
  );
}
  Widget _buildUserCard(DocumentSnapshot userDoc) {
    final userData = userDoc.data() as Map<String, dynamic>;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userData['profilePhotoUrl'] ?? ''),
        radius: 25,
      ),
      title: Text(userData['fullName'] ?? 'Unknown'),
      subtitle: const Text('Tap to start chat'),
      onTap: () {
        _navigateToChat(
          userDoc.id,
          userData['fullName'] ?? 'User',
          userData['profilePhotoUrl'] ?? '',
        );
      },
    );
  }

  Widget _buildChatCard(
    DocumentSnapshot userDoc,
    String lastMessage,
    DateTime? lastMessageTime,
  ) {
    final userData = userDoc.data() as Map<String, dynamic>;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userData['profilePhotoUrl'] ?? ''),
        radius: 25,
      ),
      title: Text(userData['fullName'] ?? 'Unknown'),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing:
          lastMessageTime != null
              ? Text(
                _formatTime(lastMessageTime),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
              : null,
      onTap: () {
        _navigateToChat(
          userDoc.id,
          userData['fullName'] ?? 'User',
          userData['profilePhotoUrl'] ?? '',
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _navigateToChat(String otherUserId, String name, String profileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatDetailScreen(
              peerId: otherUserId,
              peerName: name,
              peerImage: profileImage,
            ),
      ),
    );
  }
}
