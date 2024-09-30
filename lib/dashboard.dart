import 'package:expenzo/home_screen.dart';
import 'package:expenzo/settings_screen.dart';
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
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true); // Initialize the AnimationController here
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

  @override
  void dispose() {
    // Ensure the animation controller is disposed of only if it's initialized
    if (_animationController.isAnimating) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double remainingBudget = budget - totalExpenses;
    double progress = budget > 0 ? totalExpenses / budget : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF5C6BC0),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Main Card with CircularProgressIndicator
              Card(
                color: Color.fromARGB(255, 26, 28, 44),
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: AnimatedBuilder(
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
                      ),
                      Positioned(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '\$${remainingBudget.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: progress > 1 ? Colors.red : Colors.green,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Budget, Expenses, and Savings in Containers
              _buildStatTile(
                  'Budget', '\$${budget.toStringAsFixed(2)}', Colors.blue),
              SizedBox(height: 10),
              _buildStatTile('Expenses',
                  '\$${totalExpenses.toStringAsFixed(2)}', Colors.redAccent),
              SizedBox(height: 10),
              _buildStatTile('Savings',
                  '\$${remainingBudget.toStringAsFixed(2)}', Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, Color color) {
    return Container(
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
    );
  }
}
