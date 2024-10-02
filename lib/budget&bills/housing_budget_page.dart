import 'package:expenzo/budget&bills/bills_budget_page.dart';
import 'package:expenzo/budget&bills/budget_service.dart';
import 'package:flutter/material.dart';
import 'package:expenzo/auth_service.dart';
import 'package:intl/intl.dart';

class HousingBudgetPage extends StatefulWidget {
  @override
  _HousingBudgetPageState createState() => _HousingBudgetPageState();
}

class _HousingBudgetPageState extends State<HousingBudgetPage> {
  final AuthService _auth = AuthService();
  final BudgetService _budgetService = BudgetService();

  String _selectedOption = '';
  double _amount = 0;
  String _frequency = 'every month';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _housingOptions = ['Mortgage', 'Rent', 'None'];

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
                  'assets\\housing.png',
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
                      Text('Select your housing type:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _housingOptions
                            .map((option) => ElevatedButton(
                                  child: Text(option),
                                  onPressed: () =>
                                      setState(() => _selectedOption = option),
                                  style: ElevatedButton.styleFrom(
                                    primary: _selectedOption == option
                                        ? Color(0xFF5C6BC0)
                                        : Colors.grey[300],
                                    onPrimary: _selectedOption == option
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
                      if (_selectedOption.isNotEmpty && _selectedOption != 'None') ...[
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
                                    if (_selectedOption.isNotEmpty) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      try {
                                        String? userId = await _auth.getCurrentUserId();
                                        if (userId != null) {
                                          if (_selectedOption == 'None') {
                                            await _budgetService.updateHousingBudget(
                                                userId, 'NA', 0, 'NA', DateTime.now());
                                          } else {
                                            await _budgetService.updateHousingBudget(
                                                userId, _selectedOption, _amount, _frequency, _selectedDate);
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Housing budget updated successfully')),
                                          );
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: ((context) => BillsBudgetPage())));
                                        } else {
                                          throw Exception('User not logged in');
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: ${e.toString()}')),
                                        );
                                      } finally {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Please select a housing option')),
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
                                  MaterialPageRoute(
                                      builder: ((context) => BillsBudgetPage())));
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