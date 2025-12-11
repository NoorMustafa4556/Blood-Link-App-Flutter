import 'package:blood_app/Screens/HomeScreen.dart';
import 'package:blood_app/Screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isDonor = true; // Toggle
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Area controller ki ab zaroorat nahi, hum direct variable use karein gy
  String? selectedCity;

  String? selectedBloodGroup;
  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  // Pakistan Major Cities List
  final List<String> pakistanCities = [
    "Karachi",
    "Lahore",
    "Islamabad",
    "Rawalpindi",
    "Faisalabad",
    "Multan",
    "Peshawar",
    "Quetta",
    "Gujranwala",
    "Sialkot",
    "Hyderabad",
    "Bahawalpur",
    "Sargodha",
    "Abbottabad",
    "Sukkur",
    "Mardan",
    "Kasur",
    "Rahim Yar Khan",
    "Sahiwal",
    "Okara",
    "Gujrat",
    "Mirpur",
    "Muzaffarabad",
    "Sheikhupura",
    "Jhang",
    "Larkana",
    "Nawabshah",
    "Dera Ghazi Khan",
    "Chiniot",
  ];

  bool isLoading = false;

  // Register Function
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation update: Check if City is selected
    if (isDonor) {
      if (selectedBloodGroup == null) {
        Fluttertoast.showToast(msg: "Please select Blood Group");
        return;
      }
      if (selectedCity == null || selectedCity!.isEmpty) {
        Fluttertoast.showToast(msg: "Please select your City/Area");
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      // 1. Create User
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Prepare Data
      String uid = userCredential.user!.uid;

      Map<String, dynamic> userData = {
        'uid': uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': isDonor ? 'donor' : 'recipient',
        'createdAt': DateTime.now(),
      };

      if (isDonor) {
        userData['bloodGroup'] = selectedBloodGroup;
        // City ko save kar rahy hain
        userData['area'] = selectedCity;
        userData['isAvailable'] = true;
      }

      // 3. Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      Fluttertoast.showToast(msg: "Account Created Successfully!");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? "Registration Failed");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Toggle Button
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                            child: const Text(
                              "Signup as Donor",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                            child: const Text(
                              "Signup as Recipient",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Common Fields
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v!.isEmpty ? "Enter Name" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator:
                      (v) => v!.contains('@') ? null : "Enter valid email",
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
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
                  validator:
                      (v) => v!.length < 6 ? "Password must be 6+ chars" : null,
                ),
                const SizedBox(height: 15),

                // --- DONOR SPECIFIC FIELDS ---
                if (isDonor) ...[
                  const Divider(thickness: 2, height: 30),
                  const Text(
                    "Donor Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 15),

                  // Blood Group Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedBloodGroup,
                    decoration: const InputDecoration(
                      labelText: "Blood Group",
                      prefixIcon: Icon(Icons.bloodtype),
                    ),
                    items:
                        bloodGroups.map((bg) {
                          return DropdownMenuItem(value: bg, child: Text(bg));
                        }).toList(),
                    onChanged:
                        (val) => setState(() => selectedBloodGroup = val),
                  ),
                  const SizedBox(height: 15),

                  // --- CITY AUTOCOMPLETE (New Code) ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          // List filter logic
                          return pakistanCities.where((String option) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          selectedCity = selection;
                          debugPrint('You just selected $selection');
                        },
                        // Field ka Design wesa hi rakhny k liye jesa baqi forms ka hai
                        fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: const InputDecoration(
                              labelText: "Select City / Area",
                              prefixIcon: Icon(Icons.location_city),
                              hintText: "Type to search (e.g. Lahore)",
                            ),
                            validator: (val) {
                              if (isDonor && (val == null || val.isEmpty)) {
                                return "Select a city";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              // Agar user type kary aur select na kary to bhi value save ho
                              selectedCity = val;
                            },
                          );
                        },
                      );
                    },
                  ),
                ],

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Create Account",
                              style: TextStyle(fontSize: 18),
                            ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
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
      ),
    );
  }
}
