import 'package:flutter/material.dart';
import '../Models/BloodRequestModel.dart';
import '../Services/FirebaseService.dart';

class DonorViewModel extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  Stream<List<BloodRequestModel>> getIncomingRequests(String uid) {
    return _service.getIncomingRequests(uid);
  }

  Future<void> acceptRequest(String requestId) async {
    await _service.updateRequestStatus(requestId, 'accepted');
  }

  Future<void> rejectRequest(String requestId) async {
    await _service.updateRequestStatus(requestId, 'rejected');
  }
}
