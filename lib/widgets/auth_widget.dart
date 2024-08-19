import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/image_picker_widget.dart';

class AuthWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool isLogin;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final void Function(String?) onEmailSaved;
  final void Function(String?) onPasswordSaved;
  final void Function(String?) onConfirmPasswordSaved;
  final void Function(String?) onUsernameSaved;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;
  final VoidCallback submitForm;
  final VoidCallback switchAuthMode;
  final bool isLoading;
  final void Function(File?) onImagePicked;

  const AuthWidget({
    super.key,
    required this.formKey,
    required this.isLogin,
    required this.passwordVisible,
    required this.confirmPasswordVisible,
    required this.onEmailSaved,
    required this.onPasswordSaved,
    required this.onConfirmPasswordSaved,
    required this.onUsernameSaved,
    required this.togglePasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
    required this.submitForm,
    required this.switchAuthMode,
    required this.isLoading,
    required this.onImagePicked,
  });

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant AuthWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLogin) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final logoHeight = screenHeight * (widget.isLogin ? 0.3 : 0.2);
    final logoWidth = screenWidth * (widget.isLogin ? 0.7 : 0.4);

    final logoPosition = Tween<Alignment>(
      begin: Alignment.topCenter,
      end: Alignment.topLeft,
    ).animate(_animationController);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 241, 252),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (ctx, child) => Align(
                  alignment: logoPosition.value,
                  child: SizedBox(
                    width: logoWidth,
                    height: logoHeight,
                    child: Image.asset('assets/chat_app_logo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: widget.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.isLogin)
                        UserImagePicker(onImagePicked: (pickedImage) {
                          widget.onImagePicked(pickedImage);
                        }),
                      const SizedBox(height: 20),
                      TextFormField(
                        onSaved: widget.onEmailSaved,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!widget.isLogin)
                        TextFormField(
                          onSaved: widget.onUsernameSaved,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return 'Please enter at least a 4 characters name.';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 20),
                      TextFormField(
                        onSaved: widget.onPasswordSaved,
                        obscureText: !widget.passwordVisible,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'Password must be at least 7 characters long.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(widget.passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: widget.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      if (!widget.isLogin) ...[
                        const SizedBox(height: 20),
                        TextFormField(
                          onSaved: widget.onConfirmPasswordSaved,
                          obscureText: !widget.confirmPasswordVisible,
                          validator: widget.isLogin
                              ? null
                              : (value) {
                                  if (value!.isEmpty || value.length < 7) {
                                    return 'Please repeat the password correctly.';
                                  }
                                  return null;
                                },
                          decoration: InputDecoration(
                            labelText: 'Repeat Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(widget.confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed:
                                  widget.toggleConfirmPasswordVisibility,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      if (widget.isLoading)
                        const CircularProgressIndicator()
                      else
                        ElevatedButton(
                          onPressed: widget.submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(widget.isLogin ? 'Login' : 'Signup'),
                        ),
                      TextButton(
                        onPressed: widget.switchAuthMode,
                        child: Text(widget.isLogin
                            ? 'Create an account'
                            : 'I already have an account.'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}