import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeBudget(String userId) async {
    DocumentReference userBudgetRef = _firestore.collection('UserBudget').doc(userId);
    
    DocumentSnapshot docSnapshot = await userBudgetRef.get();
    if (!docSnapshot.exists) {
      await userBudgetRef.set({
        'initialized': true,
      });
      
      await userBudgetRef.collection('Housing').doc('details').set({
        'Description': 'NA',
        'Amount': 'NA',
        'Frequency': 'NA',
        'Date': 'NA',
        'Type': 'expense',
      });

      await userBudgetRef.collection('Budget').doc('details').set({
        'budgetEntries': [],
      });
    }
  }

  Future<void> updateHousingBudget(String userId, String description, double amount, String frequency, DateTime date) async {
    await _firestore.collection('UserBudget').doc(userId).collection('Housing').doc('details').set({
      'Description': description,
      'Amount': amount,
      'Frequency': frequency,
      'Date': date,
      'Type': 'expense',
    });
  }

  Future<void> addBudgetEntry(String userId, double amount, String frequency, DateTime date) async {
    await _firestore.collection('UserBudget').doc(userId).collection('Budget').doc('details').update({
      'budgetEntries': FieldValue.arrayUnion([
        {
          'Description': 'Budget',
          'Amount': amount,
          'Frequency': frequency,
          'Date': date,
          'Type': 'income',
        }
      ]),
    });
  }
   Future<void> checkAndInitializeBudgetDocument(String userId) async {
    DocumentReference budgetDocRef = _firestore
        .collection('UserBudget')
        .doc(userId)
        .collection('Budget')
        .doc('details');

    DocumentSnapshot docSnapshot = await budgetDocRef.get();
    if (!docSnapshot.exists) {
      await budgetDocRef.set({
        'budgetEntries': [],
      });
    }
  }

Future<List<Map<String, dynamic>>> getBudgetEntries(String userId) async {
    DocumentSnapshot doc = await _firestore
        .collection('UserBudget')
        .doc(userId)
        .collection('Budget')
        .doc('details')
        .get();
    
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['budgetEntries'] ?? []);
    } else {
      return [];
    }
  }
}