// import 'package:expenzo/create_groups.dart';
// import 'package:flutter/material.dart';
// import 'package:expenzo/auth_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class GroupsPage extends StatefulWidget {
//   @override
//   _GroupsPageState createState() => _GroupsPageState();
// }

// class _GroupsPageState extends State<GroupsPage> {
//   final AuthService _auth = AuthService();
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _getUserId();
//   }

//   Future<void> _getUserId() async {
//     userId = await _auth.getCurrentUserId();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Groups'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => CreateGroupPage()),
//               );
//             },
//             child: Text(
//               'Create Group',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: userId == null
//           ? Center(child: CircularProgressIndicator())
//           : StreamBuilder<DocumentSnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('UserGroups')
//                   .doc(userId)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || !snapshot.data!.exists) {
//                   // No document exists, show "No groups yet"
//                   return _buildNoGroupsUI();
//                 }

//                 // Check if the 'groups' field exists in the document
//                 var data = snapshot.data!.data() as Map<String, dynamic>?;
//                 if (data == null || !data.containsKey('groups')) {
//                   // 'groups' field does not exist, show "No groups yet"
//                   return _buildNoGroupsUI();
//                 }

//                 // Retrieve the 'groups' array
//                 List<dynamic> groups = data['groups'] as List<dynamic>;

//                 if (groups.isEmpty) {
//                   // If the groups array is empty, show "No groups yet"
//                   return _buildNoGroupsUI();
//                 }

//                 // Display the list of groups
//                 return ListView.separated(
//                   itemCount: groups.length,
//                   itemBuilder: (context, index) {
//                     var group = groups[index];
//                     return ListTile(
//                       title: Text(group['groupName'] ?? 'Unknown Group'),
//                       subtitle: Text(group['description'] ?? 'No description'),
//                     );
//                   },
//                   separatorBuilder: (context, index) => Divider(),
//                 );
//               },
//             ),
//     );
//   }

//   // Widget for when there are no groups
//   Widget _buildNoGroupsUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.group, size: 80, color: Colors.grey),
//           SizedBox(height: 20),
//           Text(
//             'No groups yet',
//             style: TextStyle(fontSize: 20, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }
