import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projects/features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const SplashScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              isDark: widget.isDark,
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_bg.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: FadeTransition(
              opacity: _opacity,
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
