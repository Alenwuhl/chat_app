import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<String> _loadingTexts;
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadingTexts = [
      "Loading...",
      "Almost there...",
      "Just a moment...",
    ];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();


    Future.delayed(const Duration(milliseconds: 2000), _changeLoadingText);
  }

  void _changeLoadingText() {
    setState(() {
      _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
    });
    Future.delayed(const Duration(milliseconds: 1500), _changeLoadingText);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 185, 216, 255),
              Color.fromARGB(255, 197, 224, 255),
              Color.fromARGB(255, 143, 191, 255),
              Color.fromARGB(255, 125, 186, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 500,
                  height: 500,
                  child: Image.asset('assets/chat_app_logo.png'),
                ),
              ),
              const SizedBox(height: 5),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 10),
              Text(
                _loadingTexts[_currentTextIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
