// import 'package:flutter/material.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';

// class AddUser extends StatelessWidget {
//   final TextEditingController first_Name;
//   final TextEditingController last_Name;

//   final TextEditingController email;
//   final TextEditingController phone_number;

//   const AddUser(
//     this.first_Name,
//     this.email,
//     this.phone_number,
//     this.last_Name, {super.key},
//   );

//   @override
//   Widget build(BuildContext context) {
//     // Create a CollectionReference called users that references the firestore collection
//     CollectionReference amine;
//     amine = FirebaseFirestore.instance.collection('amine');

//     Future<void> addUser() {
//       // Call the user's CollectionReference to add a new user
//       return amine
//           .add({
//             'first_Name': first_Name.text, // amine
//             'last_name': last_Name.text,
//             'email': email.text, // 42
//             'phone_number': phone_number.text,
//           })
//           .then((value) => print("User Added"))
//           .catchError((error) => print("Failed to add user: $error"));
//     }

//     return TextButton(
//       onPressed: addUser,
//       child: const Text(
//         "Add User",
//       ),
//     );
//   }
// }
