// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/tools/doctor_card.dart';

// class DoctorService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<Widget> fetchDoctorCard() async {
//     try {
//       // Get current user's UID
//       String? currentUserId = _auth.currentUser?.uid;
      
//       if (currentUserId == null) {
//         return _buildErrorWidget('User not logged in');
//       }

//       // Fetch doctor document using user's UID
//       DocumentSnapshot doctorDoc = await _firestore
//           .collection('doctors')
//           .doc(currentUserId)
//           .get();

//       // Check if doctor data exists
//       if (!doctorDoc.exists) {
//         return _buildErrorWidget('Doctor profile not found');
//       }

//       // Parse doctor data
//       Map<String, dynamic> doctorData = 
//           doctorDoc.data() as Map<String, dynamic>;

//       // Create and return DoctorCard
//       return DoctorCard(
//         firstName: doctorData['firstName'] ?? 'N/A',
//         lastName: doctorData['lastName'] ?? 'N/A',
//         specialty: doctorData['specialty'] ?? 'No Specialty',
//         address: doctorData['address'] ?? 'No Address',
//         imageUrl: doctorData['profileImageUrl'] ?? 
//           'https://via.placeholder.com/100', // Placeholder image
//         rating: (doctorData['rating'] ?? 0.0).toDouble(),
//         onCardPressed: () {
//           // TODO: Implement doctor profile view navigation
//           print('Doctor card pressed');
//         },
//         onAppointmentPressed: () {
//           // TODO: Implement appointment booking logic
//           print('Appointment booking initiated');
//         },
//       );
//     } catch (e) {
//       // Handle any errors during data fetching
//       return _buildErrorWidget('Error fetching doctor data: ${e.toString()}');
//     }
//   }

//   // Helper method to build error widget
//   Widget _buildErrorWidget(String message) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.red.shade100,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.error_outline, color: Colors.red.shade800, size: 50),
//           const SizedBox(height: 10),
//           Text(
//             message,
//             style: TextStyle(
//               color: Colors.red.shade800,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Usage in a widget
// class DoctorProfileScreen extends StatefulWidget {
//   const DoctorProfileScreen({super.key, required firstName, required specialty, required address, required description, required phoneNumber, required locations, required doctorId, required doctorName, required imageUrl});

//   @override
//   _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
// }

// class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
//   late Future<Widget> _doctorCardFuture;

//   @override
//   void initState() {
//     super.initState();
//     _doctorCardFuture = DoctorService().fetchDoctorCard();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Profile'),
//       ),
//       body: FutureBuilder<Widget>(
//         future: _doctorCardFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           }

//           return snapshot.data ?? const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }