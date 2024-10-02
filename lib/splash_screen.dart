import 'dart:async';
import 'package:expenzo/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:expenzo/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Splash screen duration
    )..forward();

    // Wait for the splash screen to complete before checking user authentication
    Timer(Duration(seconds: 1), () async {
      // Check if the user is logged in
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        // If user is logged in, go to the main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainContainer()),
        );
      } else {
        // If user is not logged in, go to the login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background theme color
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The app logo or icon goes here
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/expenzologo.png'), // Replace with your logo
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Loading indicator under the logo
            Positioned(
              bottom: 80, // Adjust the position as needed
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                strokeWidth: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
