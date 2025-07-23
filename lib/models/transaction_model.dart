import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String? id;
  final String category;
  final int amount;
  final String note;
  final String date;
  final String wallet;

  TransactionModel({
    this.id,
    required this.category,
    required this.amount,
    required this.note,
    required this.date,
    required this.wallet,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'note': note,
      'date': date,
      'wallet': wallet,
    };
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      category: data['category'] ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      note: data['note'] ?? '',
      date: data['date'] ?? '',
      wallet: data['wallet'] ?? '',
    );
  }
}
