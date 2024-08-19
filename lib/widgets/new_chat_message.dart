import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewChatMessage extends StatefulWidget {
  final String chatId;

  const NewChatMessage({required this.chatId, super.key});

  @override
  State<NewChatMessage> createState() => _NewChatMessageState();
}

class _NewChatMessageState extends State<NewChatMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'senderId': user.uid,
      'senderUsername': userData['username'],
      'senderImage': userData['image_url'],
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: submitMessage,
          ),
        ],
      ),
    );
  }
}
