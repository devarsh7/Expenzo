import 'package:expenzo/budget&bills/budget_added.dart';
import 'package:flutter/material.dart';
import 'package:expenzo/budget&bills/budget_service.dart';
import 'package:expenzo/auth_service.dart';
import 'package:intl/intl.dart';

class KidsExpensesPage extends StatefulWidget {
  @override
  _KidsExpensesPageState createState() => _KidsExpensesPageState();
}

class _KidsExpensesPageState extends State<KidsExpensesPage> {
  final AuthService _auth = AuthService();
  final BudgetService _budgetService = BudgetService();

  String _selectedExpense = '';
  double _amount = 0;
  String _frequency = 'every month';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _expenseOptions = [
    'Daycare',
    'School Lunch',
    'Child Support',
    'Classes',
    'Others'
  ];

  final List<String> _frequencyOptions = [
    'every week',
    'every month',
    'every 2 weeks',
    'every 3 weeks',
    'every 3 months',
    'every 6 months',
    'every 9 months',
    'every year'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5C6BC0),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets\\budgetimg.png',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 280,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select kids expense type:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _expenseOptions
                            .map((expense) => ElevatedButton(
                                  child: Text(expense),
                                  onPressed: () =>
                                      setState(() => _selectedExpense = expense),
                                  style: ElevatedButton.styleFrom(
                                    primary: _selectedExpense == expense
                                        ? Color(0xFF5C6BC0)
                                        : Colors.grey[300],
                                    onPrimary: _selectedExpense == expense
                                        ? Colors.white
                                        : Colors.black87,
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 5,
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 25),
                      if (_selectedExpense.isNotEmpty) ...[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(
                              () => _amount = double.tryParse(value) ?? 0),
                        ),
                        SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: _frequency,
                          decoration: InputDecoration(
                            labelText: 'Frequency',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            prefixIcon: Icon(Icons.repeat),
                          ),
                          items: _frequencyOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _frequency = newValue;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 15),
                        ElevatedButton(
                          child: Text(
                              'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _selectedDate) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF5C6BC0),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ],
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Create'),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_selectedExpense.isNotEmpty &&
                                        _amount > 0) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        String? userId =
                                            await _auth.getCurrentUserId();
                                        if (userId != null) {
                                          await _budgetService.checkAndInitializeKidsDocument(userId);
                                          await _budgetService.addKidsEntry(
                                              userId,
                                              _selectedExpense,
                                              _amount,
                                              _frequency,
                                              _selectedDate);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Kids expense added successfully')),
                                          );
                                          // Navigate to the next page or close this one
                                          Navigator.pop(context);
                                          Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BudgetEntryPage()));
                              Navigator.pop(context);
                                        } else {
                                          throw Exception('User not logged in');
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error: ${e.toString()}')),
                                        );
                                      } finally {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Please select an expense type and enter an amount')),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF5C6BC0),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                            ),
                          ),
                          ElevatedButton(
                            child: Text('Next'),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BudgetEntryPage()));
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF5C6BC0),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}