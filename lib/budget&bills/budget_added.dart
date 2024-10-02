import 'package:expenzo/budget&bills/bills_budget_page.dart';
import 'package:expenzo/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenzo/budget&bills/budget_service.dart';
import 'package:expenzo/auth_service.dart';

class BudgetEntryPage extends StatefulWidget {
  @override
  _BudgetEntryPageState createState() => _BudgetEntryPageState();
}

class _BudgetEntryPageState extends State<BudgetEntryPage>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final BudgetService _budgetService = BudgetService();
  final _formKey = GlobalKey<FormState>();

  double _amount = 0;
  String _frequency = 'Monthly';
  DateTime _selectedDate = DateTime.now();

  final List<String> _frequencyOptions = ['Weekly', 'Monthly'];

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeBudgetDocument();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeBudgetDocument() async {
    String? userId = await _auth.getCurrentUserId();
    if (userId != null) {
      await _budgetService.checkAndInitializeBudgetDocument(userId);
    }
  }

  Widget _buildBudgetForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) => _amount = double.parse(value!),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _frequency,
            decoration: InputDecoration(
              labelText: 'Frequency',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.repeat),
            ),
            items: _frequencyOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _frequency = newValue!;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a frequency' : null,
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != _selectedDate)
                setState(() {
                  _selectedDate = picked;
                });
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Skip', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => MainContainer())));
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Create',
                    style: TextStyle(fontSize: 16, color: Color(0xFF5C6BC0))),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String? userId = await _auth.getCurrentUserId();
                    if (userId != null) {
                      await _budgetService.addBudgetEntry(
                          userId, _amount, _frequency, _selectedDate);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Budget entry added successfully')),
                      );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => MainContainer())));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: User not logged in')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5C6BC0),
      body: SafeArea(
        child: Stack(
          children: [
           
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets\\budgetimg.png',
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 405.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: _buildBudgetForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
