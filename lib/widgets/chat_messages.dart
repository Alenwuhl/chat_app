import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found, start sending messages!'),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('An error occurred!'),
          );
        }
        final chatDocs = chatSnapshot.data?.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 40,
          ),
          reverse: true,
          itemCount: chatDocs?.length,
          itemBuilder: (ctx, index) {
            final currentMessage = chatDocs?[index];
            final nextMessage = index + 1 < chatDocs!.length
                ? chatDocs[index + 1]
                : null;

            final currentUserId = currentMessage?['userId'];
            final nextUserId = nextMessage?['userId'];

            final isSameUser = currentUserId == nextUserId;

            if (isSameUser) {
              return MessageBubble.next(
                message: currentMessage?['text'],
                isMe: currentMessage?['userId'] ==
                    FirebaseAuth.instance.currentUser!.uid,
              );
            } else {
              return MessageBubble.first(
                userImage: currentMessage?['userImage'],
                username: currentMessage?['username'],
                message: currentMessage?['text'],
                isMe: currentMessage?['userId'] ==
                    FirebaseAuth.instance.currentUser!.uid,
              );
            }
          },
        );
      },
    );
  }
}
