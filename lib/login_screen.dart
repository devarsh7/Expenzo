import 'package:expenzo/budget&bills/bills_budget_page.dart';
import 'package:expenzo/budget&bills/budget_added.dart';
import 'package:expenzo/budget&bills/budget_intro_page.dart';
import 'package:expenzo/dashboard.dart';
import 'package:expenzo/navigation_bar.dart';
import 'package:expenzo/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:expenzo/auth_service.dart';
import 'package:expenzo/signup_screen.dart';
import 'package:expenzo/home_screen.dart';
import 'package:expenzo/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = await _auth.signIn(_email, _password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "To continue using this app, please sign in first.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 40),
                // Image.asset(
                //   'assets/login_illustration.png', // You can replace this with the image you have
                //   height: 150,
                // ),
                SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email or Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter an email' : null,
                        onSaved: (value) => _email = value!,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          suffixIcon: Icon(Icons.visibility_off),
                        ),
                        obscureText: true,
                        validator: (value) => value!.length < 6
                            ? 'Enter a password 6+ chars long'
                            : null,
                        onSaved: (value) => _password = value!,
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          child: Text(
                            'Forgot your Password?',
                            style: TextStyle(color: Color(0xFF5C6BC0)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen()),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 100.0, vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          primary: Color(0xFF5C6BC0), // Blue color
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have any Account?",
                            style: TextStyle(fontSize: 14.0),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) => SignUpScreen())));
                            },
                            child: Text(
                              " Sign Up",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xFF5C6BC0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
