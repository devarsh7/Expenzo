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
      appBar: AppBar(
        title: Text('Housing Budget'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select your housing type:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text('Mortgage'),
                  onPressed: () => setState(() => _selectedOption = 'Mortgage'),
                ),
                ElevatedButton(
                  child: Text('Rent'),
                  onPressed: () => setState(() => _selectedOption = 'Rent'),
                ),
                ElevatedButton(
                  child: Text('None'),
                  onPressed: () => setState(() => _selectedOption = 'None'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_selectedOption.isNotEmpty && _selectedOption != 'None') ...[
              TextField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _amount = double.tryParse(value) ?? 0),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _frequency,
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
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text('Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                onPressed: () async {
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
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () async {
                String? userId = await _auth.getCurrentUserId();
                if (userId != null) {
                  if (_selectedOption == 'None') {
                    await _budgetService.updateHousingBudget(userId, 'NA', 0, 'NA', DateTime.now());
                  } else {
                    await _budgetService.updateHousingBudget(userId, _selectedOption, _amount, _frequency, _selectedDate);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: User not logged in')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}