import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequestModel {
  final String requestId;
  final String recipientId;
  final String recipientName;
  final String recipientPhone;
  final String donorId;
  final String donorName;
  final String donorPhone;
  final String bloodGroup;
  final String status; // pending, accepted, rejected
  final DateTime requestedAt;
  final String area;

  BloodRequestModel({
    required this.requestId,
    required this.recipientId,
    required this.recipientName,
    required this.recipientPhone,
    required this.donorId,
    required this.donorName,
    required this.donorPhone,
    required this.bloodGroup,
    required this.status,
    required this.requestedAt,
    required this.area,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'donorId': donorId,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'bloodGroup': bloodGroup,
      'status': status,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'area': area,
    };
  }

  factory BloodRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodRequestModel(
      requestId: id,
      recipientId: map['recipientId'] ?? '',
      recipientName: map['recipientName'] ?? '',
      recipientPhone: map['recipientPhone'] ?? '',
      donorId: map['donorId'] ?? '',
      donorName: map['donorName'] ?? '',
      donorPhone: map['donorPhone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      status: map['status'] ?? 'pending',
      requestedAt: (map['requestedAt'] as Timestamp).toDate(),
      area: map['area'] ?? '',
    );
  }
}
