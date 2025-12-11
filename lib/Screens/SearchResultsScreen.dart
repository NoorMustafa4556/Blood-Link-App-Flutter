import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchResultsScreen extends StatefulWidget {
  final String bloodGroup;
  final String area;

  const SearchResultsScreen({
    super.key,
    required this.bloodGroup,
    required this.area,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String myName = "Unknown";

  @override
  void initState() {
    super.initState();
    _fetchMyName();
  }

  // Apna naam fetch karo ta k Donor ko pata chalay kis ne manga hai
  void _fetchMyName() async {
    if (currentUser != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if(mounted) {
        setState(() {
          myName = doc['name'];
        });
      }
    }
  }

  // --- MAIN LOGIC: SEND REQUEST ---
  void sendRequest(String donorId, String donorName) async {
    // Check karo k khud ko request na bhej do
    if (donorId == currentUser!.uid) {
      Fluttertoast.showToast(msg: "You cannot request yourself!");
      return;
    }

    try {
      // Create a unique ID for request
      String requestId = "${currentUser!.uid}_$donorId";

      await FirebaseFirestore.instance.collection('requests').doc(requestId).set({
        'recipientId': currentUser!.uid,
        'recipientName': myName,
        'donorId': donorId,
        'donorName': donorName,
        'bloodGroup': widget.bloodGroup,
        'status': 'pending', // Shuru main status Pending hoga
        'requestedAt': DateTime.now(),
        'area': widget.area,
      });

      Fluttertoast.showToast(msg: "Request Sent Successfully!", backgroundColor: Colors.green, textColor: Colors.white);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error sending request");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.bloodGroup} Donors in ${widget.area}")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'donor')
            .where('bloodGroup', isEqualTo: widget.bloodGroup)
            .where('area', isEqualTo: widget.area)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Donors Found!"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              String donorId = data['uid']; // Make sure signup main 'uid' save kia tha

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(data['bloodGroup'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Available in ${data['area']}"),

                  // Request Button with Logic
                  trailing: StreamBuilder(
                    // Check karo k kya pehlay se request bhej chuky ho?
                    stream: FirebaseFirestore.instance.collection('requests').doc("${currentUser!.uid}_$donorId").snapshots(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> reqSnapshot) {

                      // Agar request exist karti hai
                      if (reqSnapshot.hasData && reqSnapshot.data!.exists) {
                        String status = reqSnapshot.data!['status'];
                        // Button ka color status k mutabiq
                        Color statusColor = status == 'accepted' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange);

                        return Chip(
                          label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                          backgroundColor: statusColor,
                        );
                      }

                      // Agar Request nahi bheji to Button dikhao
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white
                        ),
                        onPressed: () {
                          sendRequest(donorId, data['name']);
                        },
                        child: const Text("Request"),
                      );
                    },
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