// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore integration
// import 'auth_service.dart'; // Assuming you have AuthService for getting the current userId

// class CreateGroupPage extends StatefulWidget {
//   @override
//   _CreateGroupPageState createState() => _CreateGroupPageState();
// }

// class _CreateGroupPageState extends State<CreateGroupPage> {
//   final AuthService _auth =
//       AuthService(); // Replace with your authentication service
//   final _formKey = GlobalKey<FormState>();

//   String _groupName = '';
//   String _description = '';
//   String _groupType = 'Trip'; // Default group type
//   List<String> _groupTypes = [
//     'Trip',
//     'Home',
//     'Couple',
//     'Others'
//   ]; // Group types
//   List<Map<String, String>> _friends = []; // Friends list fetched from database
//   List<Map<String, String>> _selectedFriends = []; // Selected friends

//   bool _isAddButtonEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadFriends(); // Load friends when the widget is initialized
//   }

//   Future<void> _loadFriends() async {
//     String? userId = await _auth.getCurrentUserId();
//     if (userId != null) {
//       // Fetch friends list from Firestore
//       DocumentSnapshot userFriendsDoc = await FirebaseFirestore.instance
//           .collection('UserFriends')
//           .doc(userId)
//           .get();

//       if (userFriendsDoc.exists) {
//         List<dynamic> friends = userFriendsDoc.get('friends');
//         setState(() {
//           _friends = friends
//               .map((friend) {
//                 return {
//                   'username': friend['username']?.toString() ?? 'Unknown',
//                   'email': friend['email']?.toString() ?? 'Unknown'
//                 };
//               })
//               .toList()
//               .cast<Map<String, String>>();
//         });
//       }
//     }
//   }

//   void _toggleSelectedFriend(Map<String, String> friend) {
//     setState(() {
//       if (_selectedFriends.contains(friend)) {
//         _selectedFriends.remove(friend);
//       } else {
//         _selectedFriends.add(friend);
//       }
//       _isAddButtonEnabled = _selectedFriends.isNotEmpty;
//     });
//   }

//   Future<void> _createGroup() async {
//     if (_formKey.currentState!.validate()) {
//       // Save the form state to update _groupName and _description
//       _formKey.currentState!.save();

//       String? userId = await _auth.getCurrentUserId();
//       if (userId != null) {
//         DocumentReference userGroupDocRef =
//             FirebaseFirestore.instance.collection('UserGroups').doc(userId);

//         try {
//           // Check if the document already exists
//           DocumentSnapshot docSnapshot = await userGroupDocRef.get();
//           if (docSnapshot.exists) {
//             // Update the document by adding group data to an array
//             await userGroupDocRef.update({
//               'groups': FieldValue.arrayUnion([
//                 {
//                   'groupName': _groupName,
//                   'description': _description,
//                   'type': _groupType,
//                   'members': _selectedFriends,
//                   'membersCount': _selectedFriends.length,
//                   'createdAt': Timestamp.now(),
//                 }
//               ])
//             });
//           } else {
//             // If the document does not exist, create it with the groups field
//             await userGroupDocRef.set({
//               'groups': [
//                 {
//                   'groupName': _groupName,
//                   'description': _description,
//                   'type': _groupType,
//                   'members': _selectedFriends,
//                   'membersCount': _selectedFriends.length,
//                   'createdAt': Timestamp.now(),
//                 }
//               ]
//             });
//           }

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Group created successfully!')),
//           );
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to create group: $e')),
//           );
//         }
//       } else {
//         print('User is not authenticated');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Create Group')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Group Name'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter a group name' : null,
//                 onSaved: (value) => _groupName = value!, // Save group name
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Description'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter a description' : null,
//                 onSaved: (value) => _description = value!, // Save description
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: _groupTypes.map((type) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _groupType = type;
//                       });
//                     },
//                     child: Column(
//                       children: [
//                         Icon(
//                           type == 'Trip'
//                               ? Icons.airplanemode_active
//                               : type == 'Home'
//                                   ? Icons.home
//                                   : type == 'Couple'
//                                       ? Icons.favorite
//                                       : Icons.group,
//                           size: 40,
//                           color: _groupType == type ? Colors.blue : Colors.grey,
//                         ),
//                         Text(type),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//               SizedBox(height: 20),
//               Text('Add Group Members'),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _friends.length,
//                   itemBuilder: (context, index) {
//                     Map<String, String> friend = _friends[index];
//                     return ListTile(
//                       title: Text(friend['username']!),
//                       subtitle: Text(friend['email']!),
//                       trailing: _selectedFriends.contains(friend)
//                           ? Icon(Icons.check_box, color: Colors.blue)
//                           : Icon(Icons.check_box_outline_blank),
//                       onTap: () => _toggleSelectedFriend(friend),
//                     );
//                   },
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _isAddButtonEnabled ? _createGroup : null,
//                 child: Text('Create Group'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }