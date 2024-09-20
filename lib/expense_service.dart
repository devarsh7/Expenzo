import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenzo/expense.dart';

class ExpenseService {
  final CollectionReference _userExpenseCollection = FirebaseFirestore.instance.collection('UserExpense');

  Future<void> addExpense(String userId, double amount, String description, String type) async {
    try {
      DocumentReference userDoc = _userExpenseCollection.doc(userId);
      await userDoc.set({
        'expenses': FieldValue.arrayUnion([
          {
            'amount': amount,
            'description': description,
            'type': type,
            'date': Timestamp.now(),
          }
        ])
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding expense: $e');
      throw Exception('Failed to add expense');
    }
  }

  Stream<List<Expense>> getExpenses(String userId) {
    return _userExpenseCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      var data = snapshot.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('expenses')) {
        return [];
      }
      List<dynamic> expenses = data['expenses'];
      return expenses.map((expense) => Expense.fromMap(expense)).toList();
    });
  }

  Future<void> updateExpense(String userId, int index, Expense updatedExpense) async {
    try {
      DocumentReference userDoc = _userExpenseCollection.doc(userId);
      DocumentSnapshot snapshot = await userDoc.get();
      var data = snapshot.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('expenses')) {
        throw Exception('No expenses found');
      }
      List<dynamic> expenses = List.from(data['expenses']);
      if (index < 0 || index >= expenses.length) {
        throw Exception('Invalid expense index');
      }
      expenses[index] = updatedExpense.toMap();
      await userDoc.update({'expenses': expenses});
    } catch (e) {
      print('Error updating expense: $e');
      throw Exception('Failed to update expense');
    }
  }

  Future<void> deleteExpense(String userId, int index) async {
    try {
      DocumentReference userDoc = _userExpenseCollection.doc(userId);
      DocumentSnapshot snapshot = await userDoc.get();
      var data = snapshot.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('expenses')) {
        throw Exception('No expenses found');
      }
      List<dynamic> expenses = List.from(data['expenses']);
      if (index < 0 || index >= expenses.length) {
        throw Exception('Invalid expense index');
      }
      expenses.removeAt(index);
      await userDoc.update({'expenses': expenses});
    } catch (e) {
      print('Error deleting expense: $e');
      throw Exception('Failed to delete expense');
    }
  }
}