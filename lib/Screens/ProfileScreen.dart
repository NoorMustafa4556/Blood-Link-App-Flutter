import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    if (currentUser != null) {
      _emailController.text = currentUser!.email ?? "";

      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get();

      if (doc.exists && mounted) {
        setState(() {
          _nameController.text = doc['name'] ?? "";
          try {
            _usernameController.text = doc['username'] ?? "";
          } catch (e) {
            _usernameController.text = "";
          }
        });
      }
    }
  }

  void _updateProfile() async {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Name cannot be empty");
      return;
    }

    setState(() => isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({
            'name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
          });
      Fluttertoast.showToast(msg: "Profile Updated Successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error updating profile");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPassController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Old Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: newPassController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed:
                      dialogLoading
                          ? null
                          : () async {
                            if (oldPassController.text.isEmpty ||
                                newPassController.text.isEmpty) {
                              Fluttertoast.showToast(msg: "Fill all fields");
                              return;
                            }
                            if (newPassController.text.length < 6) {
                              Fluttertoast.showToast(msg: "Password too short");
                              return;
                            }

                            setDialogState(() => dialogLoading = true);
                            try {
                              // 1. Re-authenticate
                              String email = currentUser!.email!;
                              AuthCredential credential =
                                  EmailAuthProvider.credential(
                                    email: email,
                                    password: oldPassController.text.trim(),
                                  );
                              await currentUser!.reauthenticateWithCredential(
                                credential,
                              );

                              // 2. Update Password
                              await currentUser!.updatePassword(
                                newPassController.text.trim(),
                              );

                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: "Password Changed Successfully",
                              );
                            } on FirebaseAuthException catch (e) {
                              Fluttertoast.showToast(
                                msg: e.message ?? "Failed to change password",
                              );
                            } finally {
                              setDialogState(() => dialogLoading = false);
                            }
                          },
                  child:
                      dialogLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFFCDD2),
              child: Icon(Icons.person, size: 60, color: Color(0xFFD32F2F)),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              readOnly: true,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateProfile,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Changes"),
              ),
            ),
            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.lock),
              label: const Text("Change Password"),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
