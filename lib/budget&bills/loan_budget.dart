  import 'package:expenzo/budget&bills/subscription_budget.dart';
  import 'package:expenzo/navigation_bar.dart';
  import 'package:flutter/material.dart';
  import 'package:expenzo/budget&bills/budget_service.dart';
  import 'package:expenzo/auth_service.dart';
  import 'package:intl/intl.dart';
  import 'package:flutter_animate/flutter_animate.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:lottie/lottie.dart';

  class LoanPaymentsPage extends StatefulWidget {
    @override
    _LoanPaymentsPageState createState() => _LoanPaymentsPageState();
  }

  class _LoanPaymentsPageState extends State<LoanPaymentsPage> with SingleTickerProviderStateMixin {
    final AuthService _auth = AuthService();
    final BudgetService _budgetService = BudgetService();

    String _selectedLoan = '';
    double _amount = 0;
    String _frequency = 'every month';
    DateTime _selectedDate = DateTime.now();
    bool _isLoading = false;

    late AnimationController _animationController;

    final List<String> _loanOptions = [
      'Student Loans',
      'Personal Loans',
      'Payoff Credit cards'
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
    void initState() {
      super.initState();
      _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    }

    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Color(0xFF5C6BC0),
        body: SafeArea(
          child: Stack(
            children: [
              // Positioned.fill(
              //   child: Lottie.network(
              //     'https://assets6.lottiefiles.com/packages/lf20_jcikwtux.json',
              //     fit: BoxFit.cover,
                  
              //   ),
              // ),
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  // child: Lottie.network(
                  //   'https://assets2.lottiefiles.com/packages/lf20_wg0utmom.json',
                  //   height: 200,
                  //   width: 200,
                  //   fit: BoxFit.contain,
                  // ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),
              ),
              Positioned(
                top: 260,
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
                        Text('Select your loan type:',
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5C6BC0)))
                          .animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                        SizedBox(height: 15),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _loanOptions
                              .asMap()
                              .entries
                              .map((entry) => ElevatedButton(
                                    child: Text(entry.value),
                                    onPressed: () => setState(() => _selectedLoan = entry.value),
                                    style: ElevatedButton.styleFrom(
                                      primary: _selectedLoan == entry.value
                                          ? Color(0xFF5C6BC0)
                                          : Colors.grey[300],
                                      onPrimary: _selectedLoan == entry.value
                                          ? Colors.white
                                          : Colors.black87,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 5,
                                    ),
                                  ).animate().fadeIn(delay: (300 * entry.key).ms).scale(delay: (300 * entry.key).ms))
                              .toList(),
                        ),
                        SizedBox(height: 25),
                        if (_selectedLoan.isNotEmpty) ...[
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              prefixIcon: Icon(Icons.attach_money, color: Color(0xFF5C6BC0)),
                              labelStyle: GoogleFonts.poppins(color: Color(0xFF5C6BC0)),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(() => _amount = double.tryParse(value) ?? 0),
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                          SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            value: _frequency,
                            decoration: InputDecoration(
                              labelText: 'Frequency',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              prefixIcon: Icon(Icons.repeat, color: Color(0xFF5C6BC0)),
                              labelStyle: GoogleFonts.poppins(color: Color(0xFF5C6BC0)),
                            ),
                            items: _frequencyOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: GoogleFonts.poppins()),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _frequency = newValue;
                                });
                              }
                            },
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                          SizedBox(height: 15),
                          ElevatedButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text(
                              'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                              style: GoogleFonts.poppins(),
                            ),
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                        ],
                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: _isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.save),
                              label: Text('Create', style: GoogleFonts.poppins(fontSize: 16)),
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_selectedLoan.isNotEmpty && _amount > 0) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        try {
                                          String? userId = await _auth.getCurrentUserId();
                                          if (userId != null) {
                                            await _budgetService.checkAndInitializeLoanDocument(userId);
                                            await _budgetService.addLoanEntry(
                                                userId, _selectedLoan, _amount, _frequency, _selectedDate);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Loan payment added successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            _animationController.forward();
                                            await Future.delayed(Duration(milliseconds: 500));
                                            Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => SubscriptionPage()));
                                          } else {
                                            throw Exception('User not logged in');
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
                                          );
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Please select a loan type and enter an amount'),
                                            backgroundColor: Colors.orange,
                                          ),
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
                            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                            ElevatedButton.icon(
                              icon: Icon(Icons.arrow_forward),
                              label: Text('Next', style: GoogleFonts.poppins(fontSize: 16)),
                              onPressed: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => SubscriptionPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF5C6BC0),
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                              ),
                            ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0),
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