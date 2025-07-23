import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String? id;
  final String name;
  final int targetAmount;
  final int monthlyAmount;
  final String targetDate;

  GoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.monthlyAmount,
    required this.targetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'monthlyAmount': monthlyAmount,
      'targetDate': targetDate,
    };
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      name: data['name'] ?? '',
      targetAmount: data['targetAmount'] ?? 0,
      monthlyAmount: data['monthlyAmount'] ?? 0,
      targetDate: data['targetDate'] ?? '',
    );
  }
}
