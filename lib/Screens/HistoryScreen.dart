import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final bool isDonorMode;
  const HistoryScreen({super.key, required this.isDonorMode});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDonorMode ? "Received Requests History" : "Sent Requests History"),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder(
        stream: widget.isDonorMode
            ? FirebaseFirestore.instance
                .collection('requests')
                .where('donorId', isEqualTo: currentUser!.uid)
                .where('status', whereIn: ['accepted', 'rejected'])
                .snapshots()
            : FirebaseFirestore.instance
                .collection('requests')
                .where('recipientId', isEqualTo: currentUser!.uid)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text("No history found.", style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var req = docs[index];
              String status = req['status'];
              Color statusColor = status == 'accepted'
                  ? Colors.green
                  : (status == 'rejected' ? Colors.red : Colors.orange);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.isDonorMode ? "Requested by: ${req['recipientName']}" : "Sent to: ${req['donorName']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Blood Group: ${req['bloodGroup']}", style: TextStyle(color: Colors.grey.shade700)),
                      Text("Area: ${req['area']}", style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 10),
                      
                      // Show contact info if Accepted
                      if (status == 'accepted')
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.green),
                              const SizedBox(width: 10),
                              Text(
                                "Contact: ${widget.isDonorMode 
                                    ? ((req.data() as Map<String, dynamic>).containsKey('recipientPhone') ? req['recipientPhone'] : 'N/A') 
                                    : ((req.data() as Map<String, dynamic>).containsKey('donorPhone') ? req['donorPhone'] : 'N/A')}", 
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            ],
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
    );
  }
}
