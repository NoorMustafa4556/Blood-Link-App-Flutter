import 'package:blood_app/Screens/Auth/LoginScreen.dart';
import 'package:blood_app/Screens/Donor/DonorDashboard.dart';
import 'package:blood_app/Screens/HistoryScreen.dart';
import 'package:blood_app/Screens/Recipient/RecipientDashboard.dart';
import 'package:blood_app/ViewModels/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isDonorMode;
  const HomeScreen({super.key, required this.isDonorMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isDonorMode;

  @override
  void initState() {
    super.initState();
    _isDonorMode = widget.isDonorMode;
    // Fetch user data on home load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthViewModel>(context, listen: false).fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isDonorMode ? "Donor Dashboard" : "Find Donors"),
      ),
      drawer: _buildDrawer(authVM),
      body: authVM.user == null
          ? const Center(child: CircularProgressIndicator())
          : _isDonorMode ? const DonorDashboard() : const RecipientDashboard(),
    );
  }

  Widget _buildDrawer(AuthViewModel vm) {
    final user = vm.user;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? "User"),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(user?.name[0].toUpperCase() ?? "?", style: const TextStyle(fontSize: 24, color: Color(0xFFD32F2F))),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (c) => HistoryScreen(isDonorMode: _isDonorMode)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {}, // Navigate to Profile later
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await vm.logout();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
    );
  }
}
