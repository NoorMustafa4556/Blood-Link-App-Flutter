import 'package:blood_app/Screens/HomeScreen.dart';
import 'package:blood_app/Screens/SignupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isDonor = true; // Toggle state
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  bool _isPasswordVisible = false;

  // Login Function
  Future<void> login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Successfully Logged In
      Fluttertoast.showToast(msg: "Login Successful");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "Login Failed");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.bloodtype,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome Back!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Toggle Button (Donor vs Recipient)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isDonor = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                isDonor
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            "Donor",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDonor ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isDonor = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                !isDonor
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            "Recipient",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !isDonor ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Email Input
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Login as ${isDonor ? 'Donor' : 'Recipient'}",
                            style: const TextStyle(fontSize: 18),
                          ),
                ),
              ),
              const SizedBox(height: 20),

              // Signup Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
