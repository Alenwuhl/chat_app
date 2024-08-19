import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/search_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 192, 247, 255),
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color.fromARGB(255, 50, 49, 49),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color.fromARGB(255, 50, 49, 49)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SearchUserScreen(),
              ));
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.person, color: Color.fromARGB(255, 50, 49, 49)),
            onSelected: (value) {
              if (value == 'logout') {
                FirebaseAuth.instance.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Color.fromARGB(255, 50, 49, 49)),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chats')
              .where('users', arrayContains: user.uid)
              .snapshots(),
          builder: (context, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final chatDocs = chatSnapshot.data?.docs;
            if (chatDocs == null || chatDocs.isEmpty) {
              return const Center(
                child: Text(
                  'No chats found.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 50, 49, 49),
                    fontSize: 18,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                final chatDoc = chatDocs[index];
                final userIds = List<String>.from(chatDoc['users'] ?? []);
                final otherUserId = userIds.firstWhere(
                  (uid) => uid != user.uid,
                  orElse: () => '', // Devuelve una cadena vacía si no se encuentra
                );

                if (otherUserId.isEmpty) {
                  return const ListTile(
                    title: Text('Error: No other user found in this chat.'),
                  );
                }

                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUserId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    final otherUserData = userSnapshot.data!;
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatDoc.id)
                          .collection('messages')
                          .orderBy('createdAt', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, messageSnapshot) {
                        if (messageSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        }

                        final lastMessage = messageSnapshot.data?.docs.first;
                        final lastMessageText =
                            lastMessage != null ? lastMessage['text'] : 'No messages yet';

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatScreen(chatId: chatDoc.id),
                            ));
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            shadowColor: Colors.grey.withOpacity(0.5),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(otherUserData['image_url']),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          otherUserData['username'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 50, 49, 49),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          lastMessageText,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
