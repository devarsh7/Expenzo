// import 'package:flutter/material.dart';
// import 'package:expenzo/budget&bills/budget_service.dart';
// import 'package:expenzo/auth_service.dart';
// import 'package:intl/intl.dart';

// class LoanPaymentsPage extends StatefulWidget {
//   @override
//   _LoanPaymentsPageState createState() => _LoanPaymentsPageState();
// }

// class _LoanPaymentsPageState extends State<LoanPaymentsPage> {
//   final AuthService _auth = AuthService();
//   final BudgetService _budgetService = BudgetService();

//   String _selectedLoan = '';
//   double _amount = 0;
//   String _frequency = 'every month';
//   DateTime _selectedDate = DateTime.now();
//   bool _isLoading = false;

//   final List<String> _loanOptions = [
//     'Student Loans',
//     'Personal Loans',
//     'Payoff Credit cards'
//   ];

//   final List<String> _frequencyOptions = [
//     'every week',
//     'every month',
//     'every 2 weeks',
//     'every 3 weeks',
//     'every 3 months',
//     'every 6 months',
//     'every 9 months',
//     'every year'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Loan Payments'),
//         backgroundColor: Color(0xFF5C6BC0),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Select your loan type:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 15),
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: _loanOptions
//                   .map((loan) => ElevatedButton(
//                         child: Text(loan),
//                         onPressed: () => setState(() => _selectedLoan = loan),
//                         style: ElevatedButton.styleFrom(
//                           primary: _selectedLoan == loan
//                               ? Color(0xFF5C6BC0)
//                               : Colors.grey[300],
//                           onPrimary:
//                               _selectedLoan == loan ? Colors.white : Colors.black87,
//                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                       ))
//                   .toList(),
//             ),
//             SizedBox(height: 25),
//             if (_selectedLoan.isNotEmpty) ...[
//               TextFormField(
//                 decoration: InputDecoration(
//                   labelText: 'Amount',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   prefixIcon: Icon(Icons.attach_money),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (value) =>
//                     setState(() => _amount = double.tryParse(value) ?? 0),
//               ),
//               SizedBox(height: 15),
//               DropdownButtonFormField<String>(
//                 value: _frequency,
//                 decoration: InputDecoration(
//                   labelText: 'Frequency',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   prefixIcon: Icon(Icons.repeat),
//                 ),
//                 items: _frequencyOptions.map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   if (newValue != null) {
//                     setState(() {
//                       _frequency = newValue;
//                     });
//                   }
//                 },
//               ),
//               SizedBox(height: 15),
//               ElevatedButton(
//                 child: Text(
//                     'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
//                 onPressed: () async {
//                   final DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: _selectedDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2101),
//                   );
//                   if (picked != null && picked != _selectedDate) {
//                     setState(() {
//                       _selectedDate = picked;
//                     });
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   primary: Color(0xFF5C6BC0),
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ],
//             SizedBox(height: 25),
//             ElevatedButton(
//               child: _isLoading
//                   ? CircularProgressIndicator(color: Colors.white)
//                   : Text('Update Loan Payment'),
//               onPressed: _isLoading ? null : _updateLoanPayment,
//               style: ElevatedButton.styleFrom(
//                 primary: Color(0xFF5C6BC0),
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _updateLoanPayment() async {
//     if (_selectedLoan.isNotEmpty && _amount > 0) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         String? userId = await _auth.getCurrentUserId();
//         if (userId != null) {
//           await _budgetService.updateLoanEntry(
//             userId,index
//             _selectedLoan as int,
//             _amount as String,
//             _frequency as double, 
//             _selectedDate as String
//           );
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Loan payment updated successfully')),
//           );
//         } else {
//           throw Exception('User not logged in');
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a loan type and enter an amount')),
//       );
//     }
//   }
// }