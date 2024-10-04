import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _selectedDay = 'All'; // New variable for day filter
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

  final List<String> _days = [
    'All',
    for (var i = 1; i <= 31; i++) i.toString(), // Dynamically generate days
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
    try {
      await _expenseService.deleteExpense(userId!, index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense deleted successfully')),
      );
      setState(() {}); // Refresh the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete expense: $e')),
      );
    }
  }

  Future<void> _updateExpense(int index, Expense updatedExpense) async {
    if (userId == null) return;
    try {
      await _expenseService.updateExpense(userId!, index, updatedExpense);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense updated successfully')),
      );
      setState(() {}); // Refresh the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update expense: $e')),
      );
    }
  }
  double _calculateTotal(List<Expense> expenses) {
    return expenses
        .where((expense) =>
            (_selectedType == 'All' || expense.type == _selectedType) &&
            (_selectedMonth == 'All' ||
                DateFormat('MMMM').format(expense.date.toDate()) ==
                    _selectedMonth) &&
            (_selectedDay == 'All' || 
                DateFormat('d').format(expense.date.toDate()) == _selectedDay))
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
    final _formKey = GlobalKey<FormState>();
    String _amount = expense.amount.toString();
    String _description = expense.description;
    String _type = expense.type;
    DateTime _date = expense.date.toDate();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Expense Details'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: _amount,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter an amount' : null,
                    onSaved: (value) => _amount = value!,
                  ),
                  TextFormField(
                    initialValue: _description,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter a description' : null,
                    onSaved: (value) => _description = value!,
                  ),
                  DropdownButtonFormField<String>(
                    value: _type,
                    items: _expenseTypes.where((type) => type != 'All').map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _type = newValue!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Type'),
                  ),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _date) {
                        setState(() {
                          _date = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(DateFormat('MMM d, y').format(_date)),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Expense updatedExpense = Expense(
                    amount: double.parse(_amount),
                    description: _description,
                    type: _type,
                    date: Timestamp.fromDate(_date),
                  );
                  _updateExpense(index, updatedExpense);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense(index);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
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
                                _selectedMonth) &&
                        (_selectedDay == 'All' ||
                            DateFormat('d').format(e.date.toDate()) ==
                                _selectedDay))
                    .toList();

                return CustomScrollView(
                  slivers: [
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
                              value: _selectedDay, // Add day dropdown here
                              items: _days.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDay = newValue!;
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