import 'package:expenzo/analytics.dart';
import 'package:flutter/material.dart';
import 'history_screen.dart'; 

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C6BC0),
        title: Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 4.0,
          unselectedLabelColor: Colors.white.withOpacity(0.6), // Lower opacity for unselected tabs
          labelColor: Colors.white, // Full opacity for selected tabs
          tabs: [
            Tab(
              icon: Icon(Icons.list),
              text: 'Expenses',
            ),
            Tab(
              icon: Icon(Icons.insights),
              text: 'Insights',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HistoryScreen(),   // Replace with your actual HistoryScreen widget
          AnalyticsScreen(), // Replace with your actual AnalyticsScreen widget
        ],
      ),
    );
  }
}
