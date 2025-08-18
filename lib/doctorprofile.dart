// /// doctor_profile_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_application_2/screen/methode__RDV.dart';

// class DoctorProfileScreen extends StatefulWidget {
//   const DoctorProfileScreen({super.key});

//   @override
//   State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
// }

// String? spice;
// String? nom;

// class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0D6EFD),
//         leading: const BackButton(color: Colors.white),
//         actions: const [
//           IconButton(
//             icon: Icon(Icons.star_border, color: Colors.white),
//             onPressed: null,
//           ),
//           IconButton(
//             icon: Icon(Icons.share, color: Colors.white),
//             onPressed: null,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Doctor Header Info
//               Container(
//                 width: 10000,
//                 color: const Color(0xFF0D6EFD),
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: Column(
//                   children: [
//                     // Profile picture
//                     const CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.white,
//                       child: CircleAvatar(
//                         radius: 38,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       'nom',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Text(
//                       'Cardiologue',
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                     const SizedBox(height: 15),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.calendar_today,
//                           color: Color(0xFF0D6EFD)),
//                       label: const Text(
//                         'PRENDRE RENDEZ-VOUS',
//                         style: TextStyle(
//                             color: Color(0xFF0D6EFD),
//                             fontWeight: FontWeight.bold),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             PageRouteBuilder(
//                                 pageBuilder:
//                                     (context, Animation, secondryanimation) =>
//                                         const PackageSelectionScreen(),
//                                 transitionsBuilder: (context, animation,
//                                     secondaryAnimation, child) {
//                                   return FadeTransition(
//                                     opacity: animation,
//                                     child: child,
//                                   );
//                                 }));
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // Warning message
//               Container(
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF8E7),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: const Color(0xFFFFECB5)),
//                 ),
//                 child: const Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(Icons.warning_amber_rounded, color: Color(0xFFDDA122)),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Ce soignant réserve la prise de rendez-vous en ligne aux patients déjà suivis.',
//                             style: TextStyle(fontSize: 14),
//                           ),
//                           Text(
//                             'Vous pouvez le contacter au 05 56 42 11 10',
//                             style: TextStyle(fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Addresses section
//               _buildSectionWithHeader(
//                 icon: Icons.location_on_outlined,
//                 title: 'Adresses',
//                 actionText: 'Voir plus',
//                 content: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Location chip
//                     Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1E3A5F),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         'Le Bouscat - CISA',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),

//                     const Text('Bordeaux - Cabinet 202'),
//                     const SizedBox(height: 16),

//                     const Text(
//                       'Centre de cardiologie - Bordeaux Nord',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const Text(
//                         'CISA (Centre Inter-spécialité Aquitain) - Le Bouscat'),
//                     const Text('311 Avenue de la Libération Charles de Gaulle'),
//                     const Text('33110 Le Bouscat'),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 12,
//               ),
//               // Presentation
//               _buildSectionWithHeader(
//                 icon: Icons.info_outline,
//                 title: 'Présentation',
//                 actionText: 'Voir plus',
//                 content: const Text(
//                   'La cardiologie pédiatrique est une spécialité du cœur et de ses pathologies chez l\'enfant avec toutes ses spécificités. Vous pouvez consulter en cas de souffle entendu par le médecin...',
//                   style: TextStyle(fontSize: 14),
//                 ),
//               ),
//               const SizedBox(
//                 height: 12,
//               ),
//               // Payment methods

//               // Simple list items
//               _buildSimpleListItem(
//                   Icons.access_time, 'Horaires et coordonnées', 'Voir plus'),
//               _buildSimpleListItem(
//                   Icons.school_outlined, 'Formations', 'Voir plus'),

//               // Footer

//               // Report Issue Button

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionWithHeader({
//     required IconData icon,
//     required String title,
//     String? actionText,
//     required Widget content,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(icon, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (actionText != null)
//                   Text(
//                     actionText,
//                     style: const TextStyle(
//                       color: Color(0xFF0D6EFD),
//                       fontSize: 14,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: content,
//           ),
//           const Divider(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _buildSimpleListItem(IconData icon, String title, String? actionText) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, color: Colors.grey),
//                   const SizedBox(width: 8),
//                   Text(title),
//                 ],
//               ),
//               if (actionText != null)
//                 Text(
//                   actionText,
//                   style: const TextStyle(
//                     color: Color(0xFF0D6EFD),
//                     fontSize: 14,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const Divider(height: 1),
//       ],
//     );
//   }
// }
