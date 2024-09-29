import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileUpdate extends StatefulWidget {
  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // Email controller added
  bool isUsernameEditable = false; // Tracks if username can be edited
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDetails = await _firestore.collection('UserDetails').doc(user.uid).get();

      if (userDetails.exists) {
        String fetchedUsername = userDetails.data().toString().contains('username')
            ? userDetails['username']
            : 'Unknown User';

        setState(() {
          _usernameController.text = fetchedUsername;
          _emailController.text = userDetails['email'] ?? '';
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateUsername() async {
    String newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) return;

    QuerySnapshot existingUser = await _firestore
        .collection('UserDetails')
        .where('username', isEqualTo: newUsername)
        .get();

    if (existingUser.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Username is already in use by another user')));
    } else {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('UserDetails').doc(user.uid).set(
            {
              'username': newUsername,
            },
            SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username updated successfully')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Update'),
        backgroundColor: Color(0xFF5C6BC0),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameController,
                          enabled: isUsernameEditable, // Editable only when true
                          decoration: InputDecoration(
                            labelText: 'Username',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isUsernameEditable ? Icons.lock_open : Icons.edit,
                          color: isUsernameEditable ? Colors.green : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isUsernameEditable = !isUsernameEditable; // Toggle edit mode
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    enabled: false, // Email is not editable
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        primary: Color(0xFF5C6BC0),
                        fixedSize: Size.fromWidth(60)),
                    onPressed: _updateUsername,
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}
