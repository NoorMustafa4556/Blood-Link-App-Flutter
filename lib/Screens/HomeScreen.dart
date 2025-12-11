import 'package:blood_app/Screens/LoginScreen.dart';
import 'package:blood_app/Screens/ProfileScreen.dart';
import 'package:blood_app/Screens/SearchResultsScreen.dart';
import 'package:blood_app/Screens/SettingsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String myRole = 'loading';

  // User Data for Drawer
  String myName = '';
  String myUsername = ''; // removed from UI but kept for safety

  // Search Controller for Donor
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    if (currentUser != null) {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        setState(() {
          myRole = doc['role'];
          myName = doc['name'] ?? 'User';
          try {
            myUsername = doc['username'] ?? '';
          } catch (e) {
            myUsername = '';
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text(myRole == 'donor' ? "Donor Dashboard" : "Find Donors"),
        actions: [
          if (myRole == 'recipient')
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _showGeneralSearchDialog();
              },
            ),
        ],
      ),
      body: myRole == 'loading'
          ? const Center(child: CircularProgressIndicator())
          : myRole == 'donor'
          ? _buildDonorDashboard()
          : _buildRecipientView(),
    );
  }

  // ===========================
  // DRAWER WITHOUT USERNAME
  // ===========================
  Widget _buildDrawer() {
    String avatarLetter = myName.isNotEmpty ? myName[0].toUpperCase() : '?';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFD32F2F)),
            accountName: Text(
              myName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(currentUser?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // RECIPIENT VIEW
  // ==========================================
  Widget _buildRecipientView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFD32F2F),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Need Blood?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Select a blood group to find donors near you.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: bloodGroups.length,
              itemBuilder: (context, index) {
                return _buildBloodCard(bloodGroups[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodCard(String group) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _showCitySelectionDialog(group),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bloodtype, size: 40, color: Color(0xFFD32F2F)),
            const SizedBox(height: 10),
            Text(
              group,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showCitySelectionDialog(String selectedGroup) {
    String? selectedCity;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Find $selectedGroup Donors"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please select your area to filter results:"),
              const SizedBox(height: 20),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') return const Iterable<String>.empty();
                  return pakistanCities.where(
                        (String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                  );
                },
                onSelected: (String selection) {
                  selectedCity = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      hintText: "Enter City (e.g. Lahore)",
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCity != null && selectedCity!.isNotEmpty) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchResultsScreen(
                        bloodGroup: selectedGroup,
                        area: selectedCity!,
                      ),
                    ),
                  );
                }
              },
              child: const Text("Search"),
            ),
          ],
        );
      },
    );
  }

  void _showGeneralSearchDialog() {
    String? selectedGroup;
    String? selectedCity;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("General Search"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedGroup,
                    hint: const Text("Select Blood Group"),
                    items: bloodGroups
                        .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedGroup = val),
                  ),
                  const SizedBox(height: 15),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue val) {
                      if (val.text == '') return const Iterable<String>.empty();
                      return pakistanCities.where(
                            (opt) => opt.toLowerCase().contains(val.text.toLowerCase()),
                      );
                    },
                    onSelected: (val) => selectedCity = val,
                    fieldViewBuilder: (context, controller, focus, onComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focus,
                        onEditingComplete: onComplete,
                        decoration: const InputDecoration(
                          labelText: "City",
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedGroup != null && selectedCity != null) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchResultsScreen(
                            bloodGroup: selectedGroup!,
                            area: selectedCity!,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Search"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // DONOR DASHBOARD
  // ==========================================
  Widget _buildDonorDashboard() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFD32F2F),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome $myName!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchText = val.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search Requests...",
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('requests')
                .where('donorId', isEqualTo: currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.volunteer_activism, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      const Text("No Requests yet.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              var docs = snapshot.data!.docs.where((doc) {
                String rName = doc['recipientName'].toString().toLowerCase();
                String area = doc['area'].toString().toLowerCase();
                String bGroup = doc['bloodGroup'].toString().toLowerCase();
                return rName.contains(_searchText) ||
                    area.contains(_searchText) ||
                    bGroup.contains(_searchText);
              }).toList();

              if (docs.isEmpty) {
                return const Center(child: Text("No matching requests found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var req = docs[index];
                  String status = req['status'];
                  Color statusColor = status == 'pending'
                      ? Colors.orange
                      : (status == 'accepted' ? Colors.green : Colors.red);

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                req['recipientName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Needs ${req['bloodGroup']} in ${req['area']}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 15),
                          if (status == 'pending')
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('requests')
                                          .doc(req.id)
                                          .update({'status': 'rejected'});
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child: const Text("Reject"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('requests')
                                          .doc(req.id)
                                          .update({'status': 'accepted'});
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Accept"),
                                  ),
                                ),
                              ],
                            ),
                          if (status == 'accepted')
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "✅ You have accepted this request.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
