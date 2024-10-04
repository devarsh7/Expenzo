import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUp(String email, String password, String username) async {
    try {
      // Step 1: Check if the username already exists in Firestore
      QuerySnapshot usernameCheck = await _firestore
          .collection('UserDetails')
          .where('username', isEqualTo: username)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        // Username already in use, do not proceed with the sign-up
        return 'Username already in use. Please choose a different one.';
      }

      // Step 2: If the username is available, proceed with authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Step 3: Initialize the user document with basic information
        DocumentReference userDoc =
            _firestore.collection('UserDetails').doc(user.uid);
        await userDoc.set({
          'username': username,
          'email': email,
          'signUpTime': FieldValue.serverTimestamp(),
        });

        // Save userId to SharedPreferences
        await _saveUserId(user.uid);

        return 'success';
      } else {
        return 'User creation failed';
      }
    } catch (e) {
      print('Error during sign up: $e');
      return e.toString();
    }
  }

  Future<void> _createUserDetails(
      String userId, String username, String email) async {
    await _firestore.collection('UserDetails').doc(userId).set({
      'username': username,
      'email': email,
      'signUpTime': FieldValue.serverTimestamp(),
    });
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _saveUserId(user.uid);
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _removeUserId();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> _saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> _removeUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<String?> getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  Future<String> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return 'No user is currently signed in';
      }

      // Create a credential with the current email and password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // Reauthenticate the user
      await user.reauthenticateWithCredential(credential);

      // Change the password
      await user.updatePassword(newPassword);

      return 'Password changed successfully';
    } catch (e) {
      print('Error changing password: $e');
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          return 'The current password is incorrect';
        }
      }
      return 'Failed to change password: ${e.toString()}';
    }
  }

}
