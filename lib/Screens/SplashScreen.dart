import 'dart:async';
import 'package:blood_app/Screens/HomeScreen.dart';
import 'package:blood_app/Screens/Auth/SignUpScreen.dart';
import 'package:blood_app/ViewModels/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      await authVM.fetchUserData();

      if (authVM.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isDonorMode = prefs.getBool('isDonorMode') ?? true;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(isDonorMode: isDonorMode)),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 100, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              "Life Saver",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}