import 'package:blood_app/Models/BloodRequestModel.dart';
import 'package:blood_app/ViewModels/AuthViewModel.dart';
import 'package:blood_app/ViewModels/DonorViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final donorVM = Provider.of<DonorViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStats(context),
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Pending Requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<List<BloodRequestModel>>(
            stream: donorVM.getIncomingRequests(authVM.user?.uid ?? ""),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No requests yet."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final req = snapshot.data![index];
                  return _buildRequestCard(context, req, donorVM);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _statItem(context, "Donations", "3 Times", Icons.water_drop, true),
          const SizedBox(width: 15),
          _statItem(context, "Lives Saved", "9 Lives", Icons.favorite, false),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String title, String value, IconData icon, bool isPrimary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isPrimary ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: isPrimary ? Colors.white70 : Colors.grey, fontSize: 12)),
            Text(value, style: TextStyle(color: isPrimary ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, BloodRequestModel req, DonorViewModel vm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(req.recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Needs ${req.bloodGroup} in ${req.area}"),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => vm.rejectRequest(req.requestId),
                    child: const Text("Decline"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => vm.acceptRequest(req.requestId),
                    child: const Text("Accept"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
