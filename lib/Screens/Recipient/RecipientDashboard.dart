import 'package:blood_app/Screens/SearchResultsScreen.dart';
import 'package:blood_app/ViewModels/AuthViewModel.dart';
import 'package:blood_app/ViewModels/RecipientViewModel.dart';
import 'package:blood_app/Utils/AppConstants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecipientDashboard extends StatelessWidget {
  const RecipientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Emergency Blood", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
              Text("Choose blood type to find donors instantly.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: AppConstants.bloodGroups.length,
            itemBuilder: (context, index) {
              return _buildBloodTile(context, AppConstants.bloodGroups[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTile(BuildContext context, String group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () => _showCityDialog(context, group),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(group, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text("Type $group", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Tap to search donors"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showCityDialog(BuildContext context, String group) {
    String selectedArea = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Search $group Donors"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<String>(
              optionsBuilder: (val) => val.text == '' 
                  ? const Iterable<String>.empty() 
                  : AppConstants.pakistanCities.where((opt) => opt.toLowerCase().contains(val.text.toLowerCase())),
              onSelected: (val) => selectedArea = val,
              fieldViewBuilder: (context, controller, focus, onComplete) {
                return TextFormField(
                  controller: controller,
                  focusNode: focus,
                  decoration: const InputDecoration(
                    hintText: "Search City (e.g. Lahore)",
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  onChanged: (val) => selectedArea = val,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (selectedArea.isNotEmpty) {
                Navigator.pop(context);
                _navigateToResults(context, group, selectedArea.trim());
              }
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  void _navigateToResults(BuildContext context, String group, String area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(bloodGroup: group, area: area),
      ),
    );
  }
}
