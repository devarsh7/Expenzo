import 'dart:math';

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
    'Personal',
    'Gas',
    'Uncategorized'
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

  Map<String, double> _typePercentages = {};

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
    print("Usrid:  $userId");
    print("Exception $e");

    try {
      print("inside try block");
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

  void _calculateTypePercentages(List<Expense> expenses) {
    Map<String, double> typeTotals = {};
    double total = 0;

    for (var expense in expenses) {
      if (_selectedMonth == 'All' ||
          DateFormat('MMMM').format(expense.date.toDate()) == _selectedMonth) {
        typeTotals[expense.type] =
            (typeTotals[expense.type] ?? 0) + expense.amount;
        total += expense.amount;
      }
    }

    _typePercentages = {};
    typeTotals.forEach((type, amount) {
      _typePercentages[type] = (amount / total) * 100;
    });
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
              Text(
                  ' on ${DateFormat('MMM d, y').format(expense.date.toDate())}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // _deleteExpense(index); // Delete expense
              },
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.black),
              ),
            ),
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
              },
              child: Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForExpenseType(String type) {
    switch (type) {
      case 'Groceries':
        return Icons.shopping_cart;
      case 'Food':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Personal':
        return Icons.person;
      case 'Gas':
        return Icons.local_gas_station;
      case 'Uncategorized':
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _calculateTypePercentages(expenses);

                List<Expense> filteredExpenses = expenses
                    .where((e) =>
                        (_selectedType == 'All' || e.type == _selectedType) &&
                        (_selectedMonth == 'All' ||
                            DateFormat('MMMM').format(e.date.toDate()) ==
                                _selectedMonth))
                    .toList();

                return CustomScrollView(
                  slivers: [
                    // SliverAppBar(
                    //   expandedHeight: 200,
                    //   floating: false,
                    //   pinned: true,
                    //   flexibleSpace: FlexibleSpaceBar(
                    //     collapseMode: CollapseMode.parallax,
                    //     background: Container(
                    //       decoration: BoxDecoration(color: Color(0xFF5C6BC0)
                    //           // gradient: LinearGradient(
                    //           //   colors: [Colors.white, Colors.blue],
                    //           //   begin: Alignment.topRight,
                    //           //   end: Alignment.bottomLeft,
                    //           // ),
                    //           ),
                    //       child: Stack(
                    //         children: [
                    //           Center(
                    //             child: Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Text(
                    //                   '${"Your spendings :" + "\$" + totalExpense.toStringAsFixed(2)}',
                    //                   style: TextStyle(
                    //                     fontSize: 20,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.white,
                    //                   ),
                    //                 ),
                    //                 SizedBox(height: 20),
                    //                 Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceEvenly,
                    //                   children:
                    //                       _typePercentages.entries.map((entry) {
                    //                     return Container(
                    //                       padding: EdgeInsets.all(8),
                    //                       // decoration: BoxDecoration(
                    //                       //   color:
                    //                       //       Colors.white.withOpacity(0.1),
                    //                       //   // borderRadius:
                    //                       //   //     BorderRadius.circular(10),
                    //                       // ),
                    //                       child: Column(
                    //                         children: [
                    //                           Text(
                    //                             entry.key,
                    //                             style: TextStyle(
                    //                               fontSize: 15,
                    //                               fontWeight: FontWeight.bold,
                    //                               color: Colors.white,
                    //                             ),
                    //                           ),
                    //                           Text(
                    //                             '${entry.value.toStringAsFixed(1)}%',
                    //                             style: TextStyle(
                    //                               fontSize: 15,
                    //                               fontWeight: FontWeight.bold,
                    //                               color: Colors.white,
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     );
                    //                   }).toList(),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                                  child: Icon(
                                    _getIconForExpenseType(expense.type),
                                    color: Colors.white,
                                  ),
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
                        childCount: filteredExpenses.length,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
