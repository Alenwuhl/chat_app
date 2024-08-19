import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signUp(String email, String password, File? image,
      Function(bool) onUploading, String username) async {
    if (image == null) {
      throw Exception('An image must be selected to sign up.');
    }

    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Iniciar la subida de la imagen
      onUploading(true);

      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredential.user!.uid}.jpg');

      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();

      // Guardar los datos del usuario en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'image_url': imageUrl,
      }).then((_) {
        print('User data saved in Firestore successfully.');
      }).catchError((error) {
        print('Failed to save user data: $error');
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } finally {
      onUploading(false); // finish uploading
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      return 'Incorrect password provided.';
    } else if (e.code == 'email-already-in-use') {
      return 'This email address is already in use.';
    } else if (e.code == 'weak-password') {
      return 'The password is too weak.';
    } else if (e.code == 'invalid-email') {
      return 'The email address is invalid.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }
}
