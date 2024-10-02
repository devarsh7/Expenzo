// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> createUser(String userId, String name, String email) async {
//     await _firestore.collection('users').doc(userId).set({
//       'name': name,
//       'email': email,
//       'friends': [],
//     });
//   }

//   Future<List<String>> getFriends(String userId) async {
//     DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
//     List<dynamic> friendIds = doc.get('friends') ?? [];
//     List<String> friends = [];

//     for (String friendId in friendIds) {
//       DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendId).get();
//       String friendName = friendDoc.get('name');
//       friends.add(friendName);
//     }

//     return friends;
//   }

//   Future<void> addFriend(String userId, String friendId) async {
//     await _firestore.collection('users').doc(userId).update({
//       'friends': FieldValue.arrayUnion([friendId])
//     });
//   }

//   Future<List<Map<String, dynamic>>> searchUsers(String query) async {
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('users')
//         .where('name', isGreaterThanOrEqualTo: query)
//         .where('name', isLessThan: query + 'z')
//         .get();

//     return querySnapshot.docs
//         .map((doc) => {
//               'id': doc.id,
//               'name': doc.get('name'),
//               'email': doc.get('email'),
//             })
//         .toList();
//   }
// }