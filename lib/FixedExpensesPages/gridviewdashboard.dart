
import 'package:flutter/material.dart';


class FixedExpensesGridPage extends StatelessWidget {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Bills', 'icon': Icons.receipt},
    {'name': 'Housing', 'icon': Icons.home},
    {'name': 'Loans', 'icon': Icons.account_balance},
    {'name': 'Education', 'icon': Icons.security},
    {'name': 'Subscriptions', 'icon': Icons.subscriptions},
    {'name': 'Health & Fitness', 'icon': Icons.health_and_safety_sharp},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fixed Expenses'),
        backgroundColor: Color(0xFF5C6BC0),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(context, _categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToExpensePage(context, category['name']),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'], size: 48, color: Color(0xFF5C6BC0)),
            SizedBox(height: 8),
            Text(
              category['name'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToExpensePage(BuildContext context, String categoryName) {
    if (categoryName == 'Loans') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => LoanPaymentsPage()),
      // );
    } else {
      // Navigate to other expense pages when implemented
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$categoryName page not implemented yet')),
      );
    }
  }
}