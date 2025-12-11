import 'dart:async';
import 'package:blood_app/Screens/HomeScreen.dart';
import 'package:blood_app/Screens/LoginScreen.dart';
import 'package:blood_app/Screens/SignUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 seconds wait then check auth status
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Agar user login hai to Home per jao
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        // Agar login nahi hai to Login Screen per jao
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon ya Logo
            const Icon(
              Icons.bloodtype,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              "Blood Link",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Donate Blood, Save Life",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}