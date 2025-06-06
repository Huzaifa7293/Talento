import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talento/utils/appColors.dart';

class ChatDetailScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String peerImage;

  const ChatDetailScreen({
    Key? key,
    required this.peerId,
    required this.peerName,
    required this.peerImage,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  late String chatId;
  String username = "";
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    // Sort UIDs to get consistent chatId
    chatId = currentUser.uid.hashCode <= widget.peerId.hashCode
        ? '${currentUser.uid}_${widget.peerId}'
        : '${widget.peerId}_${currentUser.uid}';

    getUserData();
  }

  void getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance
        .collection('TalentoUsers')
        .doc(currentUser.uid)
        .get();
    if (snapshot.exists) {
      setState(() {
        username = snapshot.data()?['username'];
        profileImage = snapshot.data()?['photoUrl'];
      });
    }
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messageData = {
      'senderId': currentUser.uid,
      'receiverId': widget.peerId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Save message
    await FirebaseFirestore.instance
        .collection('TalentoChats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update chat preview
    await FirebaseFirestore.instance.collection('TalentoChats').doc(chatId).set({
      'users': [currentUser.uid, widget.peerId],
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    _messageController.clear();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.peerImage),
            ),
            const SizedBox(width: 10),
            Text(widget.peerName, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('TalentoChats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg['senderId'] == currentUser.uid;
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.orange : AppColors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg['text'],
                  style: TextStyle(color:  isMe ?  Colors.white: AppColors.textColor),
                ),
              ),
            );
          },
        );
      },
    );
  }

Widget _buildMessageInput() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: const BoxDecoration(
      color: AppColors.white,
      border: Border(top: BorderSide(color: Colors.white12, width: 1)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                )
              ]
            ),
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: AppColors.textColor),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppColors.lightGrey),
                border: InputBorder.none,
              ),
              cursorColor: AppColors.orange,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.gradient
          ),
          child: IconButton(
            icon: const Icon(Icons.send, color: AppColors.white),
            onPressed: sendMessage,
            tooltip: 'Send Message',
          ),
        ),
      ],
    ),
  );
}

}
