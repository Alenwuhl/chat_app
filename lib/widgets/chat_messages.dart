import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  final String chatId;

  const ChatMessages({required this.chatId, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatDocs = chatSnapshot.data?.docs ?? [];
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final currentMessage = chatDocs[index];
            final nextMessage = index + 1 < chatDocs.length ? chatDocs[index + 1] : null;

            final currentUserId = currentMessage['senderId'];
            final nextUserId = nextMessage?['senderId'];

            final isFirstInSequence = nextUserId != currentUserId;

            return isFirstInSequence
                ? MessageBubble.first(
                    message: currentMessage['text'],
                    isMe: currentUserId == FirebaseAuth.instance.currentUser!.uid,
                    username: currentMessage['senderUsername'],
                    userImage: currentMessage['senderImage'],
                  )
                : MessageBubble.next(
                    message: currentMessage['text'],
                    isMe: currentUserId == FirebaseAuth.instance.currentUser!.uid,
                  );
          },
        );
      },
    );
  }
}
