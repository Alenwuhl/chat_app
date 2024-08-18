import 'package:flutter/material.dart';
import 'package:chat_app/widgets/auth_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userPassword = '';

  void _submitForm() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
      print(_userEmail);
      print(_userPassword);
    }
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
        onEmailSaved: (value) {
          _userEmail = value!;
        },
        onPasswordSaved: (value) {
          _userPassword = value!;
        },
        submitForm: _submitForm,
        switchAuthMode: _switchAuthMode,
      ),
    );
  }
}
