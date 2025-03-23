import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _logoVisible = false;

  @override
  void initState() {
    super.initState();

    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _logoVisible = true;
      });
    });

    // Navigate to LoginPage after the animation completes
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0072FF), // Gradient background color
      body: Stack(
        children: [
          // Animated Logo
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            left: _logoVisible ? MediaQuery.of(context).size.width / 2 - 75 : -150,
            top: _logoVisible ? MediaQuery.of(context).size.height / 2 - 75 : MediaQuery.of(context).size.height,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png', // Replace with your logo path
                height: 150, // Adjust height
                width: 150,  // Adjust width
              ),
            ),
          ),

          // Welcome Text
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: _logoVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: const Padding(
                padding: EdgeInsets.only(top: 200),
                child: Text(
                  'Welcome to Horizon!',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto', // Ensure to include the font if custom
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
