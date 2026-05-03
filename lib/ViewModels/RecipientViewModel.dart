import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Models/BloodRequestModel.dart';
import '../Models/UserModel.dart';
import '../Services/FirebaseService.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecipientViewModel extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  Stream<List<UserModel>> findDonors(String bloodGroup, String area) {
    return _service.searchDonors(bloodGroup, area);
  }

  Future<void> requestBlood({
    required UserModel donor,
    required UserModel recipient,
    required String bloodGroup,
    required String area,
  }) async {
    final requestId = FirebaseFirestore.instance.collection('requests').doc().id;
    final request = BloodRequestModel(
      requestId: requestId,
      recipientId: recipient.uid,
      recipientName: recipient.name,
      recipientPhone: recipient.phone,
      donorId: donor.uid,
      donorName: donor.name,
      donorPhone: donor.phone,
      bloodGroup: bloodGroup,
      status: 'pending',
      requestedAt: DateTime.now(),
      area: area,
    );

    try {
      await _service.sendBloodRequest(request);
      Fluttertoast.showToast(msg: "Request Sent Successfully!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to send request");
    }
  }
}
