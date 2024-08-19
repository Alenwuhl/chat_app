import 'package:chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchUserScreen extends StatefulWidget {
  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  var _searchQuery = '';
  String getChatId(String userId1, String userId2) {
    final List<String> sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }

  Future<void> _startChat(String otherUserId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final chatId = getChatId(user.uid, otherUserId);

    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      // Si el chat no existe, crea uno nuevo
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'users': [user.uid, otherUserId],
      });
    }

    // Navega al ChatScreen con el ID del chat
    Navigator.of(context).pop(); // Cierra la pantalla de búsqueda
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatScreen(chatId: chatId),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                  labelText: 'Search by username or email'),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isGreaterThanOrEqualTo: _searchQuery)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = userSnapshot.data?.docs ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final user = FirebaseAuth.instance.currentUser!;

                    // Skip the logged-in user
                    if (userDoc.id == user.uid) {
                      return const SizedBox.shrink();
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userDoc['image_url']),
                      ),
                      title: Text(userDoc['username']),
                      subtitle: Text(userDoc['email']),
                      onTap: () => _startChat(userDoc.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
