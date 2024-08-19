import 'package:flutter/material.dart';
import 'package:chat_app/widgets/auth_widget.dart';
import 'package:chat_app/services/auth_service.dart';
import 'dart:io';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  var _isLogin = true;
  var _userEmail = '';
  var _userPassword = '';
  var _userPasswordConfirm = '';
  var _username = '';
  var _passwordVisible = false;
  var _confirmPasswordVisible = false;
  var _isLoading = false;
  var _isUploading = false; // Estado para la subida de la imagen
  File? _selectedImage;

  Future<void> _submitForm() async {
    if (!_isLogin && _selectedImage == null) {
      _showErrorDialog('Please pick an image.');
      return;
    }

    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _authService.signIn(_userEmail, _userPassword);
      } else {
        if (_userPassword != _userPasswordConfirm) {
          _showErrorDialog('Passwords do not match!');
          return;
        }
        await _authService.signUp(
          _userEmail, 
          _userPassword, 
          _selectedImage,
          (isUploading) {
            setState(() {
              _isUploading = isUploading;
            });
          },
          _username // Pasamos el username al servicio
        );
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 241, 252),
      body: AuthWidget(
        formKey: _formKey,
        isLogin: _isLogin,
        passwordVisible: _passwordVisible,
        confirmPasswordVisible: _confirmPasswordVisible,
        onEmailSaved: (value) {
          _userEmail = value!;
        },
        onUsernameSaved: (value) {
          _username = value!;
        },
        onPasswordSaved: (value) {
          _userPassword = value!;
        },
        onConfirmPasswordSaved: (value) {
          _userPasswordConfirm = value!;
        },
        togglePasswordVisibility: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
        toggleConfirmPasswordVisibility: () {
          setState(() {
            _confirmPasswordVisible = !_confirmPasswordVisible;
          });
        },
        submitForm: _submitForm,
        switchAuthMode: _switchAuthMode,
        isLoading: _isLoading || _isUploading, // Muestra el spinner si se está subiendo la imagen
        onImagePicked: (pickedImage) {
          _selectedImage = pickedImage; 
        },
      ),
    );
  }
}
