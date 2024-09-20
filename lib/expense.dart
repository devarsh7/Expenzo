import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final double amount;
  final String description;
  final String type;
  final Timestamp date;

  Expense({
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
  });

  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      amount: data['amount'],
      description: data['description'],
      type: data['type'],
      date: data['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'description': description,
      'type': type,
      'date': date,
    };
  }
}