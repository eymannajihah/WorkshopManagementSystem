import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePayment {
  final String paymentId;
  final String userId;
  final double paymentAmount;
  final String paymentDescription;
  final String paymentStatus;
  final DateTime? paymentDate;

  ManagePayment({
    required this.paymentId,
    required this.userId,
    required this.paymentAmount,
    required this.paymentDescription,
    required this.paymentStatus,
    this.paymentDate,
  });

  // Corrected factory constructor
  factory ManagePayment.fromMap(Map<String, dynamic> map, String documentId) {
    return ManagePayment(
      paymentId: documentId,
      userId: map['userId'] as String,
      paymentAmount: (map['paymentAmount'] as num).toDouble(),
      
      // Correctly extracts 'paymentDescription' before casting
      paymentDescription: map['paymentDescription'] as String,
      
      // Correctly extracts 'paymentStatus' before casting
      paymentStatus: map['paymentStatus'] as String,

      // Correctly checks and casts 'paymentDate'
      paymentDate: map['paymentDate'] == null
          ? null
          : (map['paymentDate'] as Timestamp).toDate(),
    );
  }

  // Method to convert a ManagePayment instance to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'paymentAmount': paymentAmount,
      'paymentDescription': paymentDescription,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate,
    };
  }
}