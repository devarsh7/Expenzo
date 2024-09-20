import 'package:flutter/material.dart';
import 'package:expenzo/auth_service.dart';
import 'package:expenzo/expense_service.dart';
import 'package:expenzo/addfriends_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final ExpenseService _expenseService = ExpenseService();
  final _formKey = GlobalKey<FormState>();

  String _amount = '';
  String _description = '';
  String _expenseType = 'Groceries';
  List<String> _expenseTypes = ['Groceries', 'Food', 'Personal', 'Shopping'];

  void _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? userId = await _auth.getCurrentUserId();
      if (userId != null) {
        try {
          await _expenseService.addExpense(
              userId, double.parse(_amount), _description, _expenseType);
          _formKey.currentState!.reset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Expense added successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add expense: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 1),
                Padding(
                  padding: const EdgeInsets.only(left: 250.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFriendsScreen()),
                      );
                    },
                    child: Text(
                      'Add Friends',
                      style: TextStyle(fontSize: 18, color: Color(0xFF5C6BC0)),
                    ),
                  ),
                ),
                SizedBox(height: 120),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter an amount' : null,
                  onSaved: (value) => _amount = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a description' : null,
                  onSaved: (value) => _description = value!,
                ),
                DropdownButtonFormField(
                  value: _expenseType,
                  items: _expenseTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _expenseType = value.toString();
                    });
                  },
                  decoration: InputDecoration(labelText: 'Expense Type'),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      primary: Color(0xFF5C6BC0),
                    ),
                    child: Text(
                      'Add Expense',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _submitExpense,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
