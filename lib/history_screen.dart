import 'package:flutter/material.dart';
import 'package:expenzo/auth_service.dart';
import 'package:expenzo/expense_service.dart';
import 'package:expenzo/expense.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AuthService _auth = AuthService();
  final ExpenseService _expenseService = ExpenseService();
  String? userId;
  String _selectedType = 'All';
  String _selectedMonth = 'All';
  final List<String> _expenseTypes = [
    'All',
    'Groceries',
    'Food',
    'Shopping',
    'Personal'
  ];
  final List<String> _months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _getUserId();
    _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  }

  void _getUserId() async {
    String? id = await _auth.getCurrentUserId();
    setState(() {
      userId = id;
    });
  }

  Future<void> _deleteExpense(int index) async {
    if (userId == null) return;

    try {
      await _expenseService.deleteExpense(userId!, index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete expense: $e')),
      );
    }
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses
        .where((expense) =>
            (_selectedType == 'All' || expense.type == _selectedType) &&
            (_selectedMonth == 'All' ||
                DateFormat('MMMM').format(expense.date.toDate()) ==
                    _selectedMonth))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  void _showExpenseDialog(Expense expense, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense.description),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(' Added \$${expense.amount.toStringAsFixed(2)}'),
              //Text(' \$${expense.amount.toStringAsFixed(2)} '),
              Text(
                  ' on ${DateFormat('MMM d, y').format(expense.date.toDate())}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _deleteExpense(index); // Delete expense
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle the editing functionality here.
                Navigator.of(context).pop(); // Close dialog
                // Navigate to edit screen or show edit functionality.
              },
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff1f1f1),
      body: userId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Expense>>(
              stream: _expenseService.getExpenses(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No expenses found'));
                }
                List<Expense> expenses = snapshot.data!;
                double totalExpense = _calculateTotal(expenses);
                List<Expense> filteredExpenses = expenses
                    .where((e) =>
                        (_selectedType == 'All' || e.type == _selectedType) &&
                        (_selectedMonth == 'All' ||
                            DateFormat('MMMM').format(e.date.toDate()) ==
                                _selectedMonth))
                    .toList();
                return Column(
                  children: [
                    SizedBox(height: 40), // Added space above the card
                    Card(
                      elevation: 8, // Shadow elevation
                      margin: EdgeInsets.all(16), // Margin around the card
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Curved borders
                      ),
                      child: Container(height: 130,
                        width: MediaQuery.of(context).size.width *
                            0.9, // Set width to 90% of the screen width
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.9), // Opacity for the card color
                          borderRadius: BorderRadius.circular(
                              20), // Matching curved borders for the container
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26, // Shadow color
                              blurRadius: 10, // Soft shadow radius
                              offset: Offset(0, 4), // Shadow position
                            ),
                          ],
                        ),
                        child: Padding(
                          padding:
                              EdgeInsets.all(16), // Padding inside the card
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Total Expense',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '\$${totalExpense.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: _selectedMonth,
                            items: _months.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedMonth = newValue!;
                              });
                            },
                          ),
                          DropdownButton<String>(
                            value: _selectedType,
                            items: _expenseTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedType = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          Expense expense = filteredExpenses[index];
                          return GestureDetector(
                            onTap: () {
                              _showExpenseDialog(expense, index);
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.primaries[
                                      expense.type.hashCode %
                                          Colors.primaries.length],
                                  child: Icon(Icons.attach_money,
                                      color: Colors.white),
                                ),
                                title: Text(expense.description),
                                subtitle: Text(
                                    '${expense.type} - ${DateFormat('MMM d, y').format(expense.date.toDate())}'),
                                trailing: Text(
                                  '\$${expense.amount.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
