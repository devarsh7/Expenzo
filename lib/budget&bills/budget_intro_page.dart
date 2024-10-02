import 'package:expenzo/budget&bills/bills_budget_page.dart';
import 'package:flutter/material.dart';
import 'package:expenzo/auth_service.dart';
import 'package:expenzo/budget&bills/budget_service.dart';
import 'package:expenzo/budget&bills/housing_budget_page.dart';

class BudgetIntroPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final BudgetService _budgetService = BudgetService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5C6BC0), // Background color you provided
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Asset image placeholder, add the correct path
            Container(
              padding: EdgeInsets.all(20.0),
              child: Image.asset(
                'assets\\expenzologo.png', // Add the correct asset path
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            // Main content with title and description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Let\'s start making a budget to track expenses',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .white, // White text to contrast the blue background
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Spacing for button
            SizedBox(height: 30),
            // 'Next' button with dynamic styling
            ElevatedButton(
              onPressed: () async {
                String? userId = await _auth.getCurrentUserId();
                if (userId != null) {
                  await _budgetService.initializeBudget(userId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HousingBudgetPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: User not logged in')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                primary: Color(0xFFF9A825), // Bright yellow button for contrast
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      30.0), // Rounded button for a softer look
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors
                      .black, // Black text for contrast against yellow button
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
