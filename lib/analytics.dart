import 'package:flutter/material.dart';
import 'package:expenzo/auth_service.dart';
import 'package:expenzo/expense_service.dart';
import 'package:expenzo/expense.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AuthService _auth = AuthService();
  final ExpenseService _expenseService = ExpenseService();
  String? userId;
  String _selectedMonth = 'All';
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
  List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
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

  List<PieChartSectionData> _getSections() {
    return _typePercentages.entries.map((entry) {
      final index = _typePercentages.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        color: _colors[index % _colors.length],
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
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
                _calculateTypePercentages(expenses);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButton<String>(
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
                    ),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _getSections(),
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: _typePercentages.entries.map((entry) {
                          final index =
                              _typePercentages.keys.toList().indexOf(entry.key);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: _colors[index % _colors.length],
                                ),
                                SizedBox(width: 8),
                                Text(
                                    '${entry.key}: ${entry.value.toStringAsFixed(1)}%'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
