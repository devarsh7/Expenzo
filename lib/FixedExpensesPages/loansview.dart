import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenzo/budget&bills/budget_service.dart';
import 'package:expenzo/auth_service.dart';

class LoanUpdatePage extends StatefulWidget {
  @override
  _LoanUpdatePageState createState() => _LoanUpdatePageState();
}

class _LoanUpdatePageState extends State<LoanUpdatePage> {
  final AuthService _auth = AuthService();
  final BudgetService _budgetService = BudgetService();

  List<Map<String, dynamic>> _loanEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoanEntries();
  }

  Future<void> _loadLoanEntries() async {
    setState(() => _isLoading = true);
    String? userId = await _auth.getCurrentUserId();
    if (userId != null) {
      _loanEntries = await _budgetService.getLoanEntries(userId);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateLoanEntry(int index, String description, double amount, DateTime date) async {
    String? userId = await _auth.getCurrentUserId();
    if (userId != null) {
      await _budgetService.updateLoanEntry(
        userId,
        index,
        description,
        amount,
        _loanEntries[index]['Frequency'],
        date,
      );
      await _loadLoanEntries();
    }
  }

  Future<void> _deleteLoanEntry(int index) async {
    String? userId = await _auth.getCurrentUserId();
    if (userId != null) {
      List<Map<String, dynamic>> updatedEntries = List.from(_loanEntries);
      updatedEntries.removeAt(index);
      await _budgetService.updateLoanEntries(userId, updatedEntries);
      await _loadLoanEntries();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Loan Payments'),
        backgroundColor: Color(0xFF5C6BC0),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _loanEntries.length,
              itemBuilder: (context, index) {
                final entry = _loanEntries[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(entry['Description']),
                    subtitle: Text('${entry['Amount']} ${entry['Frequency']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showUpdateDialog(context, index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _showDeleteDialog(context, index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF5C6BC0),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, int index) {
    final entry = _loanEntries[index];
    final descriptionController = TextEditingController(text: entry['Description']);
    final amountController = TextEditingController(text: entry['Amount'].toString());
    DateTime selectedDate = DateTime.parse(entry['Date']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Loan Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                _updateLoanEntry(
                  index,
                  descriptionController.text,
                  double.parse(amountController.text),
                  selectedDate,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Loan Payment'),
          content: Text('Are you sure you want to delete this loan payment?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteLoanEntry(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Loan Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Select Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                String? userId = await _auth.getCurrentUserId();
                if (userId != null) {
                  await _budgetService.addLoanEntry(
                    userId,
                    descriptionController.text,
                    double.parse(amountController.text),
                    'monthly', // You might want to make this configurable
                    selectedDate,
                  );
                  await _loadLoanEntries();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}