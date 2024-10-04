import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenzo/changepassword.dart';
import 'package:expenzo/settings_menus/contact_us.dart';
import 'package:expenzo/settings_menus/profile.dart';
import 'package:flutter/material.dart';
import 'package:expenzo/login_screen.dart';
import 'package:expenzo/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();
  String? userId;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _getUserId() async {
    String? id = await _auth.getCurrentUserId();
    if (id != null) {
      setState(() {
        userId = id;
      });
      _fetchUsername(id);
    } else {
      setState(() {
        isLoading = false;
        username = 'Unknown User';
      });
    }
  }

  Future<void> _fetchUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserDetails')
          .doc(userId)
          .get();
      setState(() {
        username = userDoc['username'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching username: $e');
      setState(() {
        username = 'Unknown User';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(username ?? 'Unknown User'),
                    titlePadding: EdgeInsets.only(bottom: 92),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF5C6BC0),
                        // gradient: LinearGradient(
                        //   begin: Alignment.topRight,
                        //   end: Alignment.bottomLeft,
                        //   colors: [Colors.white, Colors.blue],
                        // ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 250.0),
                        child: Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF5C6BC0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildSettingsItem(
                        icon: Icons.account_circle_sharp,
                        title: 'Profile',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileUpdate()));
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.lock,
                        title: 'Change Password',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangePasswordPage()));
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.notifications,
                        title: 'Notification Settings',
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        icon: Icons.info,
                        title: 'Currency',
                        onTap: () {
                          // Show About screen
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.contact_mail,
                        title: 'Contact Developer',
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactDeveloper()));
                        },
                      ),
                      _buildSettingsItem(
                        icon: Icons.exit_to_app,
                        title: 'Log Out',
                        onTap: () async {
                          await _auth.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
