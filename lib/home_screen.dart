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
  List<Map<String, dynamic>> _expenseTypes = [
    {'name': 'Groceries', 'icon': Icons.shopping_cart},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Personal', 'icon': Icons.person},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Gas', 'icon': Icons.local_gas_station},
    {'name': 'Uncategorized', 'icon': Icons.category},
  ];

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

  Widget _buildExpenseTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _expenseTypes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _expenseType = _expenseTypes[index]['name'];
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _expenseType == _expenseTypes[index]['name']
                  ? Color(0xFF5C6BC0)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _expenseTypes[index]['icon'],
                  color: _expenseType == _expenseTypes[index]['name']
                      ? Colors.white
                      : Colors.black,
                ),
                SizedBox(height: 5),
                Text(
                  _expenseTypes[index]['name'],
                  style: TextStyle(
                    color: _expenseType == _expenseTypes[index]['name']
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                SizedBox(height: 10),
                Text(
                  "Add an Expense",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C6BC0)),
                ),
                SizedBox(height: 50),
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
                SizedBox(height: 20),
                Text(
                  'Expense Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildExpenseTypeGrid(),
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