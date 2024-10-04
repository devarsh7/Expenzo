import 'package:expenzo/FixedExpensesPages/gridviewdashboard.dart';
import 'package:flutter/material.dart';
import 'package:expenzo/budget&bills/budget_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenzo/auth_service.dart';
import 'package:expenzo/expense_service.dart';

class BudgetDashboard extends StatefulWidget {
  @override
  _BudgetDashboardState createState() => _BudgetDashboardState();
}

class _BudgetDashboardState extends State<BudgetDashboard>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final BudgetService _budgetService = BudgetService();
  final ExpenseService _expenseService = ExpenseService();

  String? userId;
  double budget = 0.0;
  double totalExpenses = 0.0;
  double fixedExpenses = 0.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _getUserId();
  }

  void _getUserId() async {
    try {
      String? id = await _auth.getCurrentUserId();
      setState(() {
        userId = id;
      });
      if (userId != null) {
        _fetchBudgetAndExpenses();
        _fetchFixedExpenses();
      }
    } catch (e) {
      print('Error fetching user ID: $e');
    }
  }

  void _fetchBudgetAndExpenses() async {
    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth =
          DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

      List<Map<String, dynamic>> budgetEntries =
          await _budgetService.getBudgetEntries(userId!);

      if (budgetEntries.isNotEmpty) {
        setState(() {
          budget = budgetEntries.fold(0.0, (sum, entry) {
            Timestamp timestamp = entry['Date'];
            DateTime budgetDate = timestamp.toDate();
            if (budgetDate.isAfter(firstDayOfMonth) &&
                budgetDate.isBefore(lastDayOfMonth)) {
              return sum + entry['Amount'];
            } else {
              return sum;
            }
          });
        });
      }

      _expenseService.getExpenses(userId!).listen((expenses) {
        double total = expenses
            .where((expense) =>
                expense.date.toDate().isAfter(firstDayOfMonth) &&
                expense.date.toDate().isBefore(lastDayOfMonth))
            .fold(0, (sum, expense) => sum + expense.amount);
        setState(() {
          totalExpenses = total;
        });
      });
    } catch (e) {
      print('Error fetching budget and expenses: $e');
    }
  }

  void _fetchFixedExpenses() async {
    try {
      print('Starting _fetchFixedExpenses');
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 1);
      print(
          'Date range: ${firstDayOfMonth.toString()} to ${lastDayOfMonth.toString()}');

      List<String> collections = [
        'Housing',
        'Bills',
        'Loan',
        'Subscriptions',
        'HealthandFitness',
        'Education',
        'Kids'
      ];
      double total = 0.0;

      for (String collection in collections) {
        double amount = await _budgetService.getAmountForCollection(
            userId!, collection, firstDayOfMonth, lastDayOfMonth);
        total += amount;
        print('Added $amount from $collection. New total: $total');

        // Debug: Print the documents in each collection
        await _printCollectionDocuments(
            collection, firstDayOfMonth, lastDayOfMonth);
      }

      print('Final total fixed expenses: $total');
      setState(() {
        fixedExpenses = total;
      });
      print('State updated. fixedExpenses: $fixedExpenses');
    } catch (e) {
      print('Error fetching fixed expenses: $e');
    }
  }

  Future<void> _printCollectionDocuments(
      String collection, DateTime start, DateTime end) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserBudget')
          .doc(userId)
          .collection(collection)
          .where('Date', isGreaterThanOrEqualTo: start)
          .where('Date', isLessThan: end)
          .get();

      print('Documents in $collection:');
      querySnapshot.docs.forEach((doc) {
        print('Document ID: ${doc.id}, Data: ${doc.data()}');
      });
    } catch (e) {
      print('Error printing documents for $collection: $e');
    }
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double remainingBudget = budget - totalExpenses - fixedExpenses;
    double progress =
        budget > 0 ? (totalExpenses + fixedExpenses) / budget : 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Black circular container for 3D effect
                    Container(
                      height: 260,
                      width: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    // Circular progress indicator
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          height: 250,
                          width: 250,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 15,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress > 1 ? Colors.red : Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
                    // Text in the center
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${remainingBudget.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: progress > 1
                                ? Color(0xFFEF5350)
                                : Color(0xFF66BB6A),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          progress > 1 ? 'Over Budget' : 'Safe to Spend',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              _buildStatTile(
                  'Budget', '\$${budget.toStringAsFixed(2)}', Colors.blue, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FixedExpensesGridPage()));
              }),
              SizedBox(height: 10),
              _buildStatTile(
                  'Expenses',
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  Colors.redAccent, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FixedExpensesGridPage()));
              }),
              SizedBox(height: 10),
              _buildStatTile('Fixed Expenses',
                  '\$${fixedExpenses.toStringAsFixed(2)}', Colors.orange, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FixedExpensesGridPage()));
              }),
              SizedBox(height: 10),
              _buildStatTile('Remaining',
                  '\$${remainingBudget.toStringAsFixed(2)}', Colors.green, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FixedExpensesGridPage()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(
      String title, String value, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
