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
  Future<void> addBillEntry(String userId, String billType, double amount, String frequency, DateTime date) async {
    try {
      await _firestore.collection('UserBudget').doc(userId).collection('Bills').doc('details').set({
        'billEntries': FieldValue.arrayUnion([
          {
            'Description': billType,
            'Amount': amount,
            'Frequency': frequency,
            'Date': date.toIso8601String(),
            'Type': 'expense',
          }
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding bill entry: $e');
      throw Exception('Failed to add bill entry');
    }
  }

  Future<void> checkAndInitializeBillsDocument(String userId) async {
    try {
      DocumentReference billsDocRef = _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Bills')
          .doc('details');

      DocumentSnapshot docSnapshot = await billsDocRef.get();
      if (!docSnapshot.exists) {
        await billsDocRef.set({
          'billEntries': [],
        });
      }
    } catch (e) {
      print('Error initializing bills document: $e');
      throw Exception('Failed to initialize bills document');
    }
  }

  Future<List<Map<String, dynamic>>> getBillEntries(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Bills')
          .doc('details')
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['billEntries'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting bill entries: $e');
      throw Exception('Failed to get bill entries');
    }
  }
  Future<void> addLoanEntry(String userId, String loanType, double amount, String frequency, DateTime date) async {
    try {
      await _firestore.collection('UserBudget').doc(userId).collection('Loan').doc('details').set({
        'loanEntries': FieldValue.arrayUnion([
          {
            'Description': loanType,
            'Amount': amount,
            'Frequency': frequency,
            'Date': date.toIso8601String(),
            'Type': 'expense',
          }
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding loan entry: $e');
      throw Exception('Failed to add loan entry');
    }
  }

  Future<void> checkAndInitializeLoanDocument(String userId) async {
    try {
      DocumentReference loanDocRef = _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Loan')
          .doc('details');

      DocumentSnapshot docSnapshot = await loanDocRef.get();
      if (!docSnapshot.exists) {
        await loanDocRef.set({
          'loanEntries': [],
        });
      }
    } catch (e) {
      print('Error initializing loan document: $e');
      throw Exception('Failed to initialize loan document');
    }
  }

  Future<List<Map<String, dynamic>>> getLoanEntries(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Loan')
          .doc('details')
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['loanEntries'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting loan entries: $e');
      throw Exception('Failed to get loan entries');
    }
  }
  Future<void> updateLoanEntry(String userId, int entryIndex, String loanType, double amount, String frequency, DateTime date) async {
  try {
    // Get the existing loan entries first
    DocumentSnapshot doc = await _firestore
        .collection('UserBudget')
        .doc(userId)
        .collection('Loan')
        .doc('details')
        .get();
    
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> loanEntries = List<Map<String, dynamic>>.from(data['loanEntries'] ?? []);

      // Ensure the entryIndex is valid
      if (entryIndex >= 0 && entryIndex < loanEntries.length) {
        // Update the entry with new values
        loanEntries[entryIndex] = {
          'Description': loanType,
          'Amount': amount,
          'Frequency': frequency,
          'Date': date.toIso8601String(),
          'Type': 'expense',
        };

        // Update the document in Firestore
        await _firestore.collection('UserBudget').doc(userId).collection('Loan').doc('details').update({
          'loanEntries': loanEntries,
        });
      } else {
        throw Exception('Invalid entry index');
      }
    } else {
      throw Exception('No loan document found');
    }
  } catch (e) {
    print('Error updating loan entry: $e');
    throw Exception('Failed to update loan entry');
  }
}
Future<void> updateLoanEntries(String userId, List<Map<String, dynamic>> updatedEntries) async {
    try {
      await _firestore.collection('UserBudget').doc(userId).collection('Loan').doc('details').update({
        'loanEntries': updatedEntries,
      });
    } catch (e) {
      print('Error updating loan entries: $e');
      throw Exception('Failed to update loan entries');
    }
  }


  // Subscriptions
  Future<void> addSubscriptionEntry(String userId, String subscriptionType, double amount, String frequency, DateTime date) async {
    try {
      await _firestore.collection('UserBudget').doc(userId).collection('Subscriptions').doc('details').set({
        'subscriptionEntries': FieldValue.arrayUnion([
          {
            'Description': subscriptionType,
            'Amount': amount,
            'Frequency': frequency,
            'Date': date.toIso8601String(),
            'Type': 'expense',
          }
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding subscription entry: $e');
      throw Exception('Failed to add subscription entry');
    }
  }

  Future<void> checkAndInitializeSubscriptionsDocument(String userId) async {
    try {
      DocumentReference subscriptionsDocRef = _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Subscriptions')
          .doc('details');

      DocumentSnapshot docSnapshot = await subscriptionsDocRef.get();
      if (!docSnapshot.exists) {
        await subscriptionsDocRef.set({
          'subscriptionEntries': [],
        });
      }
    } catch (e) {
      print('Error initializing subscriptions document: $e');
      throw Exception('Failed to initialize subscriptions document');
    }
  }

  Future<List<Map<String, dynamic>>> getSubscriptionEntries(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Subscriptions')
          .doc('details')
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['subscriptionEntries'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting subscription entries: $e');
      throw Exception('Failed to get subscription entries');
    }
  }
  

  // Health and Fitness
  Future<void> addHealthAndFitnessEntry(String userId, String healthType, double amount, String frequency, DateTime date) async {
    try {
      await _firestore.collection('UserBudget').doc(userId).collection('HealthandFitness').doc('details').set({
        'healthAndFitnessEntries': FieldValue.arrayUnion([
          {
            'Description': healthType,
            'Amount': amount,
            'Frequency': frequency,
            'Date': date.toIso8601String(),
            'Type': 'expense',
          }
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding health and fitness entry: $e');
      throw Exception('Failed to add health and fitness entry');
    }
  }

  Future<void> checkAndInitializeHealthAndFitnessDocument(String userId) async {
    try {
      DocumentReference healthAndFitnessDocRef = _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('HealthandFitness')
          .doc('details');

      DocumentSnapshot docSnapshot = await healthAndFitnessDocRef.get();
      if (!docSnapshot.exists) {
        await healthAndFitnessDocRef.set({
          'healthAndFitnessEntries': [],
        });
      }
    } catch (e) {
      print('Error initializing health and fitness document: $e');
      throw Exception('Failed to initialize health and fitness document');
    }
  }

  Future<List<Map<String, dynamic>>> getHealthAndFitnessEntries(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('HealthandFitness')
          .doc('details')
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['healthAndFitnessEntries'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting health and fitness entries: $e');
      throw Exception('Failed to get health and fitness entries');
    }
  }

  // Education
  Future<void> addEducationEntry(String userId, String educationType, double amount, String frequency, DateTime date) async {
    try {
      await _firestore.collection('UserBudget').doc(userId).collection('Education').doc('details').set({
        'educationEntries': FieldValue.arrayUnion([
          {
            'Description': educationType,
            'Amount': amount,
            'Frequency': frequency,
            'Date': date.toIso8601String(),
            'Type': 'expense',
          }
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding education entry: $e');
      throw Exception('Failed to add education entry');
    }
  }

  Future<void> checkAndInitializeEducationDocument(String userId) async {
    try {
      DocumentReference educationDocRef = _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Education')
          .doc('details');

      DocumentSnapshot docSnapshot = await educationDocRef.get();
      if (!docSnapshot.exists) {
        await educationDocRef.set({
          'educationEntries': [],
        });
      }
    } catch (e) {
      print('Error initializing education document: $e');
      throw Exception('Failed to initialize education document');
    }
  }

  Future<List<Map<String, dynamic>>> getEducationEntries(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Education')
          .doc('details')
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['educationEntries'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting education entries: $e');
      throw Exception('Failed to get education entries');
    }
  }

  // Kids
  Future<void> addKidsEntry(String userId, String kidsExpenseType, double amount, String frequency, DateTime date) async {
    try {
      await _firestore.collection('UserBudget').doc(userId).collection('Kids').doc('details').set({
        'kidsEntries': FieldValue.arrayUnion([
          {
            'Description': kidsExpenseType,
            'Amount': amount,
            'Frequency': frequency,
            'Date': date.toIso8601String(),
            'Type': 'expense',
          }
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding kids expense entry: $e');
      throw Exception('Failed to add kids expense entry');
    }
  }

  Future<void> checkAndInitializeKidsDocument(String userId) async {
    try {
      DocumentReference kidsDocRef = _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Kids')
          .doc('details');

      DocumentSnapshot docSnapshot = await kidsDocRef.get();
      if (!docSnapshot.exists) {
        await kidsDocRef.set({
          'kidsEntries': [],
        });
      }
    } catch (e) {
      print('Error initializing kids document: $e');
      throw Exception('Failed to initialize kids document');
    }
  }

  Future<List<Map<String, dynamic>>> getKidsEntries(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('UserBudget')
          .doc(userId)
          .collection('Kids')
          .doc('details')
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['kidsEntries'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting kids expense entries: $e');
      throw Exception('Failed to get kids expense entries');
    }
  }

  
   Future<double> getAmountForCollection(
  String userId, 
  String collectionName,
  DateTime startDate,
  DateTime endDate
) async {
  try {
    print('Fetching amount for $collectionName between ${startDate.toString()} and ${endDate.toString()}');
    
    QuerySnapshot querySnapshot = await _firestore
        .collection('UserBudget')
        .doc(userId)
        .collection(collectionName)
        .get();

    double totalAmount = 0.0;

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      if (collectionName == 'Housing') {
        // Handle Housing collection
        if (data['Date'] != null && data['Amount'] != null) {
          DateTime entryDate = data['Date'] is Timestamp 
              ? (data['Date'] as Timestamp).toDate()
              : DateTime.parse(data['Date'].toString());
          
          if (entryDate.isAfter(startDate) && entryDate.isBefore(endDate)) {
            totalAmount += (data['Amount'] as num).toDouble();
          }
        }
      }
      else if (collectionName == 'Bills') {
        // Handle other collections
        String entryListName = 'billEntries';
        List<dynamic> entries = data[entryListName] ?? [];
        
        for (var entry in entries) {
          if (entry['Date'] != null && entry['Amount'] != null) {
            DateTime entryDate = entry['Date'] is Timestamp 
                ? (entry['Date'] as Timestamp).toDate()
                : DateTime.parse(entry['Date'].toString());
            
            if (entryDate.isAfter(startDate) && entryDate.isBefore(endDate)) {
              totalAmount += (entry['Amount'] as num).toDouble();
            }
          }
        }
      }
      else if (collectionName == 'Subscriptions') {
        // Handle other collections
        String entryListName = 'subscriptionEntries';
        List<dynamic> entries = data[entryListName] ?? [];
        
        for (var entry in entries) {
          if (entry['Date'] != null && entry['Amount'] != null) {
            DateTime entryDate = entry['Date'] is Timestamp 
                ? (entry['Date'] as Timestamp).toDate()
                : DateTime.parse(entry['Date'].toString());
            
            if (entryDate.isAfter(startDate) && entryDate.isBefore(endDate)) {
              totalAmount += (entry['Amount'] as num).toDouble();
            }
          }
        }
      } 
      else {
        // Handle other collections
        String entryListName = '${collectionName.toLowerCase()}Entries';
        List<dynamic> entries = data[entryListName] ?? [];
        
        for (var entry in entries) {
          if (entry['Date'] != null && entry['Amount'] != null) {
            DateTime entryDate = entry['Date'] is Timestamp 
                ? (entry['Date'] as Timestamp).toDate()
                : DateTime.parse(entry['Date'].toString());
            
            if (entryDate.isAfter(startDate) && entryDate.isBefore(endDate)) {
              totalAmount += (entry['Amount'] as num).toDouble();
            }
          }
        }
      }
    }

    print('Total amount for $collectionName: $totalAmount');
    return totalAmount;
  } catch (e) {
    print('Error getting amount for $collectionName: $e');
    return 0.0;  // Return 0 if there's an error or the collection doesn't exist
  }
}
}
