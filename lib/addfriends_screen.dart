import 'package:flutter/material.dart';
import 'package:expenzo/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFriendsScreen extends StatefulWidget {
  @override
  _AddFriendsScreenState createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _friendUsernameOrEmail = '';
  bool _isButtonEnabled = false;

  void _checkFriendAndAdd() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? currentUserId = await _auth.getCurrentUserId();
      if (currentUserId != null) {
        try {
          // Check if username or email exists in Firestore
          QuerySnapshot result = await FirebaseFirestore.instance
              .collection('UserDetails')
              .where('username', isEqualTo: _friendUsernameOrEmail)
              .get();

          if (result.docs.isEmpty) {
            result = await FirebaseFirestore.instance
                .collection('UserDetails')
                .where('email', isEqualTo: _friendUsernameOrEmail)
                .get();
          }

          if (result.docs.isNotEmpty) {
            var friendData = result.docs.first.data() as Map<String, dynamic>;

            // Check if UserFriends document for currentUserId exists, if not, create it
            DocumentReference userFriendsRef =
                FirebaseFirestore.instance.collection('UserFriends').doc(currentUserId);

            DocumentSnapshot docSnapshot = await userFriendsRef.get();
            if (!docSnapshot.exists) {
              // Create the document with an empty 'friends' array if it doesn't exist
              await userFriendsRef.set({
                'friends': []
              });
            }

            // Add the friend to the friends array
            await userFriendsRef.update({
              'friends': FieldValue.arrayUnion([
                {
                  'username': friendData['username'],
                  'email': friendData['email'],
                  'addedAt': Timestamp.now(),
                }
              ]),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Friend added successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No username or email exists')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding friend: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Friends')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Username or Email'),
                onChanged: (value) {
                  setState(() {
                    _friendUsernameOrEmail = value;
                    _isButtonEnabled = value.isNotEmpty;
                  });
                },
                validator: (value) =>
                    value!.isEmpty ? 'Enter a username or email' : null,
                onSaved: (value) => _friendUsernameOrEmail = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isButtonEnabled ? _checkFriendAndAdd : null,
                child: Text('Add Friend'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
