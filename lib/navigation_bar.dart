import 'package:expenzo/analytics.dart';
import 'package:expenzo/budget&bills/budget_added.dart';
import 'package:expenzo/dashboard.dart';
import 'package:expenzo/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:expenzo/home_screen.dart';
import 'package:expenzo/history_screen.dart';
import 'package:expenzo/settings_screen.dart';

class MainContainer extends StatefulWidget {
  @override
  _MainContainerState createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    BudgetDashboard(),
    ReportsScreen(),
    HomeScreen(),
    BudgetEntryPage(),
    SettingsScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.analytics_outlined, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white), // New "+" icon
          Icon(Icons.account_balance_wallet,
              size: 30, color: Colors.white), // New budget icon
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: Color(0xFF5C6BC0),
        buttonBackgroundColor: Color(0xFF5C6BC0),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: onTabTapped,
      ),
    );
  }
}
