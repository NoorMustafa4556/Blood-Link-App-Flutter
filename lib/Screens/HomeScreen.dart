import 'package:blood_app/Screens/LoginScreen.dart';
import 'package:blood_app/Screens/ProfileScreen.dart';
import 'package:blood_app/Screens/SearchResultsScreen.dart';
import 'package:blood_app/Screens/SettingsScreen.dart';
import 'package:blood_app/Screens/HistoryScreen.dart';
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
  int _currentIndex = 0;

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
          // myRole = doc['role']; // Role check hata diya, sab users dono use kar sakty hain
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
        title: Text(_currentIndex == 0 ? "Find Donors" : "Blood Requests"),
        elevation: 0,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _showGeneralSearchDialog();
              },
            ),
        ],
      ),
      body: myName.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _currentIndex == 0
              ? _buildRecipientView()
              : _buildDonorDashboard(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Find Donors",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "My Requests",
          ),
        ],
      ),
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
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen()));
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Emergency Blood",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose the required blood type from the list below to discover matching donors instantly.",
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: bloodGroups.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              return _buildBloodTile(bloodGroups[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTile(String group) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showCitySelectionDialog(group),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Modern Circular Icon
                Container(
                  height: 65,
                  width: 65,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      group,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type $group",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tap to find donors",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, $myName",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Here are the blood requests directed to you.",
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // New Stats Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.water_drop, color: Colors.white, size: 28),
                          SizedBox(height: 10),
                          Text("Donations", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text("3 Times", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.favorite, color: Theme.of(context).primaryColor, size: 28),
                          const SizedBox(height: 10),
                          Text("Lives Saved", style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const Text("9 Lives", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchText = val.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search Requests...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    fillColor: Colors.transparent,
                    filled: true,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
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
                .where('status', isEqualTo: 'pending')
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

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  var req = docs[index];
                  String status = req['status'];
                  Color statusColor = status == 'pending'
                      ? Colors.orange
                      : (status == 'accepted' ? Colors.green : Colors.red);

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    req['recipientName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor.withOpacity(0.5)),
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
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(Icons.bloodtype, size: 18, color: Colors.red.shade400),
                              const SizedBox(width: 5),
                              Text(
                                "Needs ${req['bloodGroup']}",
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Icon(Icons.location_on, size: 18, color: Colors.blue.shade400),
                              const SizedBox(width: 5),
                              Text(
                                req['area'],
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Decline"),
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
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text("Accept"),
                                ),
                              ),
                            ],
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
