import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_chat_message.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({required this.chatId, super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final chatData = chatSnapshot.data!;
        final otherUserId = (chatData['users'] as List)
            .firstWhere(
              (uid) => uid != currentUser.uid,
              orElse: () => null, // Manejo de caso cuando no se encuentra otro usuario
            );

        if (otherUserId == null) {
          return const Scaffold(
            body: Center(
              child: Text('No other user found in this chat.'),
            ),
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(otherUserId)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final otherUserData = userSnapshot.data!;
            return Scaffold(
              appBar: AppBar(
                elevation: 3, // Sombra sutil en la AppBar
                backgroundColor: const Color.fromARGB(255, 192, 247, 255),
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(otherUserData['image_url']),
                      radius: 20, // Ajuste del tamaño de la imagen
                    ),
                    const SizedBox(width: 12),
                    Text(
                      otherUserData['username'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 50, 49, 49),
                      ),
                    ),
                  ],
                ),
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 192, 247, 255),
                      Color.fromARGB(255, 227, 237, 250),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ChatMessages(chatId: chatId),
                    ),
                    NewChatMessage(chatId: chatId),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
