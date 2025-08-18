// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:async/async.dart'; // N'oubliez pas d'ajouter cette dépendance

// // Modèle de données pour les docteurs (inchangé)
// class Docteur {
//   final String id;
//   final String prenom;
//   final String nom;
//   final String specialite;
//   final String imageUrl;

//   Docteur({
//     required this.id,
//     required this.prenom,
//     required this.nom,
//     required this.specialite,
//     required this.imageUrl,
//   });

//   factory Docteur.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Docteur(
//       id: doc.id,
//       prenom: data['firstName'] ?? '',
//       nom: data['lastName'] ?? '',
//       specialite: data['specialite'] ?? data['specialty'] ?? '',
//       imageUrl: data['imageUrl'] ?? '',
//     );
//   }

//   // Méthode pour obtenir le nom complet
//   String get nomComplet => '$prenom $nom';
// }

// // Modèle de données pour les consultations
// class Consultation {
//   final String id;
//   final String idDocteur;
//   final String idPatient;
//   final DateTime dateConsultation;
//   final String bloodPressure;
//   final String diagnosis;
//   final String height;
//   final String weight;
//   final String sugarLevel;
//   final String notes;
//   final String reasonForVisit;
//   final String symptoms;
//   final String numeroSalle;
//   final int dureeMinutes;
//   Docteur? docteur;

//   Consultation({
//     required this.id,
//     required this.idDocteur,
//     required this.idPatient,
//     required this.dateConsultation,
//     required this.bloodPressure,
//     required this.diagnosis,
//     required this.height,
//     required this.weight,
//     required this.sugarLevel,
//     required this.notes,
//     required this.reasonForVisit,
//     required this.symptoms,
//     required this.numeroSalle,
//     required this.dureeMinutes,
//     this.docteur,
//   });

//   factory Consultation.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//     // Handle date parsing safely
//     DateTime dateConsultation;
//     try {
//       if (data['date'] is Timestamp) {
//         dateConsultation = (data['date'] as Timestamp).toDate();
//       } else if (data['date'] is String) {
//         // Tester différents formats de date
//         try {
//           dateConsultation = DateFormat('dd-MM-yyyy').parse(data['date']);
//         } catch (_) {
//           try {
//             dateConsultation = DateFormat('dd/MM/yyyy').parse(data['date']);
//           } catch (_) {
//             dateConsultation = DateTime.now();
//           }
//         }
//       } else {
//         dateConsultation = DateTime.now();
//       }
//     } catch (_) {
//       dateConsultation = DateTime.now();
//     }

//     // Handle dureeMinutes safely
//     int dureeMinutes;
//     try {
//       if (data['duree_minutes'] is int) {
//         dureeMinutes = data['duree_minutes'];
//       } else if (data['duree_minutes'] is String) {
//         dureeMinutes = int.tryParse(data['duree_minutes']) ?? 30;
//       } else {
//         dureeMinutes = 30;
//       }
//     } catch (_) {
//       dureeMinutes = 30;
//     }

//     // Prendre en compte différentes conventions de nommage
//     String idDocteur = data['id_doctor'] ?? data['doctorId'] ?? '';
//     String idPatient = data['id_patient'] ?? data['patientId'] ?? '';
//     String reasonForVisit = data['reason_for_visit'] ?? data['motif'] ?? '';
//     String numeroSalle = data['numero_salle'] ?? data['room_number'] ?? '';

//     return Consultation(
//       id: doc.id,
//       idDocteur: idDocteur,
//       idPatient: idPatient,
//       dateConsultation: dateConsultation,
//       bloodPressure: data['blood_pressure'] ?? '',
//       diagnosis: data['diagnosis'] ?? '',
//       height: data['height'] ?? '',
//       weight: data['weight'] ?? '',
//       sugarLevel: data['sugar_level'] ?? '',
//       notes: data['notes'] ?? '',
//       reasonForVisit: reasonForVisit,
//       symptoms: data['symptoms'] ?? '',
//       numeroSalle: numeroSalle,
//       dureeMinutes: dureeMinutes,
//     );
//   }
// }

// // Service pour interagir avec Firebase
// class FirebaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Méthode pour diviser une liste en sous-listes de taille maximale spécifiée
//   List<List<T>> _chunked<T>(List<T> list, int size) {
//     List<List<T>> chunks = [];
//     for (var i = 0; i < list.length; i += size) {
//       chunks.add(
//           list.sublist(i, i + size > list.length ? list.length : i + size));
//     }
//     return chunks;
//   }

//   // Méthode pour écouter en temps réel toutes les consultations
//   Stream<List<Consultation>> streamAllConsultations() {
//     return _firestore.collection('consultation').snapshots().asyncMap(
//       (consultationsSnapshot) async {
//         // Liste pour stocker toutes les consultations
//         List<Consultation> consultations = [];

//         // Ensemble des IDs uniques de docteurs
//         Set<String> uniqueDoctorIds = {};

//         // Convertir les documents en objets Consultation et collecter les IDs de docteurs
//         for (var doc in consultationsSnapshot.docs) {
//           Consultation consultation = Consultation.fromFirestore(doc);
//           consultations.add(consultation);

//           if (consultation.idDocteur.isNotEmpty) {
//             uniqueDoctorIds.add(consultation.idDocteur);
//           }
//         }

//         // Map pour stocker les informations des docteurs
//         Map<String, Docteur> doctorsMap = {};

//         // Récupérer les informations de tous les docteurs
//         if (uniqueDoctorIds.isNotEmpty) {
//           // Diviser en lots (Firestore limite à 10 éléments dans whereIn)
//           for (var chunk in _chunked(uniqueDoctorIds.toList(), 10)) {
//             final doctorsSnapshot = await _firestore
//                 .collection('doctors')
//                 .where(FieldPath.documentId, whereIn: chunk)
//                 .get();

//             for (var doctorDoc in doctorsSnapshot.docs) {
//               doctorsMap[doctorDoc.id] = Docteur.fromFirestore(doctorDoc);
//             }
//           }
//         }

//         // Associer chaque consultation à son docteur
//         for (var consultation in consultations) {
//           if (doctorsMap.containsKey(consultation.idDocteur)) {
//             consultation.docteur = doctorsMap[consultation.idDocteur];
//           }
//         }

//         return consultations;
//       },
//     );
//   }

//   // Méthode pour écouter en temps réel les consultations d'un docteur spécifique
//   Stream<List<Consultation>> streamConsultationsByDoctorId(String doctorId) {
//     // Combiner deux streams pour gérer les deux formats possibles de nom de champ
//     return StreamGroup.merge([
//       _firestore
//           .collection('consultation')
//           .where('id_doctor', isEqualTo: doctorId)
//           .snapshots(),
//       _firestore
//           .collection('consultation')
//           .where('doctorId', isEqualTo: doctorId)
//           .snapshots(),
//     ]).asyncMap((snapshot) async {
//       // Récupérer les informations du docteur une seule fois
//       Docteur? docteur;
//       try {
//         final doctorDoc =
//             await _firestore.collection('doctors').doc(doctorId).get();
//         if (doctorDoc.exists) {
//           docteur = Docteur.fromFirestore(doctorDoc);
//         }
//       } catch (e) {
//         print('Erreur lors de la récupération du docteur: $e');
//       }

//       // Gérer le dédoublonnage car nous pourrions avoir des documents en double
//       Map<String, DocumentSnapshot> uniqueDocs = {};
//       for (var doc in snapshot.docs) {
//         uniqueDocs[doc.id] = doc;
//       }

//       List<Consultation> consultations = [];
//       for (var doc in uniqueDocs.values) {
//         final consultation = Consultation.fromFirestore(doc);
//         consultation.docteur = docteur;
//         consultations.add(consultation);
//       }
//       return consultations;
//     });
//   }

//   // Méthode pour écouter en temps réel les consultations d'un patient spécifique
//   Stream<List<Consultation>> streamConsultationsByPatientId(String patientId) {
//     // Combiner deux streams pour gérer les deux formats possibles de nom de champ
//     return StreamGroup.merge([
//       _firestore
//           .collection('consultation')
//           .where('patientId', isEqualTo: patientId)
//           .snapshots(),
//     ]).asyncMap((snapshot) async {
//       // Gérer le dédoublonnage car nous pourrions avoir des documents en double
//       Map<String, DocumentSnapshot> uniqueDocs = {};
//       for (var doc in snapshot.docs) {
//         uniqueDocs[doc.id] = doc;
//       }

//       List<Consultation> consultations = [];
//       Set<String> uniqueDoctorIds = {};

//       // Collecter les consultations et IDs de docteurs
//       for (var doc in uniqueDocs.values) {
//         Consultation consultation = Consultation.fromFirestore(doc);
//         consultations.add(consultation);

//         if (consultation.idDocteur.isNotEmpty) {
//           uniqueDoctorIds.add(consultation.idDocteur);
//         }
//       }

//       // Map pour stocker les informations des docteurs
//       Map<String, Docteur> doctorsMap = {};

//       // Récupérer les informations des docteurs
//       if (uniqueDoctorIds.isNotEmpty) {
//         for (var chunk in _chunked(uniqueDoctorIds.toList(), 10)) {
//           final doctorsSnapshot = await _firestore
//               .collection('doctors')
//               .where(FieldPath.documentId, whereIn: chunk)
//               .get();

//           for (var doctorDoc in doctorsSnapshot.docs) {
//             doctorsMap[doctorDoc.id] = Docteur.fromFirestore(doctorDoc);
//           }
//         }
//       }

//       // Associer chaque consultation à son docteur
//       for (var consultation in consultations) {
//         if (doctorsMap.containsKey(consultation.idDocteur)) {
//           consultation.docteur = doctorsMap[consultation.idDocteur];
//         }
//       }

//       return consultations;
//     });
//   }

//   // Les méthodes originales pour la compatibilité (si nécessaire)
//   Future<List<Consultation>> getConsultationsWithDoctorInfo() async {
//     try {
//       final consultationsSnapshot =
//           await _firestore.collection('consultation').get();

//       List<Consultation> consultations = [];
//       Set<String> uniqueDoctorIds = {};

//       for (var doc in consultationsSnapshot.docs) {
//         Consultation consultation = Consultation.fromFirestore(doc);
//         consultations.add(consultation);

//         if (consultation.idDocteur.isNotEmpty) {
//           uniqueDoctorIds.add(consultation.idDocteur);
//         }
//       }

//       Map<String, Docteur> doctorsMap = {};

//       if (uniqueDoctorIds.isNotEmpty) {
//         for (var chunk in _chunked(uniqueDoctorIds.toList(), 10)) {
//           final doctorsSnapshot = await _firestore
//               .collection('doctors')
//               .where(FieldPath.documentId, whereIn: chunk)
//               .get();

//           for (var doctorDoc in doctorsSnapshot.docs) {
//             doctorsMap[doctorDoc.id] = Docteur.fromFirestore(doctorDoc);
//           }
//         }
//       }

//       for (var consultation in consultations) {
//         if (doctorsMap.containsKey(consultation.idDocteur)) {
//           consultation.docteur = doctorsMap[consultation.idDocteur];
//         }
//       }

//       return consultations;
//     } catch (e) {
//       print('Erreur Firebase: $e');
//       rethrow;
//     }
//   }

//   Future<List<Consultation>> getConsultationsByDoctorId(String doctorId) async {
//     try {
//       final snapshot = await _firestore
//           .collection('consultation')
//           .where('id_doctor', isEqualTo: doctorId)
//           .get();

//       Docteur? docteur;
//       try {
//         final doctorDoc =
//             await _firestore.collection('doctors').doc(doctorId).get();
//         if (doctorDoc.exists) {
//           docteur = Docteur.fromFirestore(doctorDoc);
//         }
//       } catch (e) {
//         print('Erreur lors de la récupération du docteur: $e');
//       }

//       List<Consultation> consultations = [];
//       for (var doc in snapshot.docs) {
//         final consultation = Consultation.fromFirestore(doc);
//         consultation.docteur = docteur;
//         consultations.add(consultation);
//       }
//       return consultations;
//     } catch (e) {
//       print('Erreur Firebase: $e');
//       rethrow;
//     }
//   }

//   Future<List<Consultation>> getConsultationsByPatientId(
//       String patientId) async {
//     try {
//       final snapshot = await _firestore
//           .collection('consultation')
//           .where('patientId', isEqualTo: patientId)
//           .get();

//       List<Consultation> consultations = [];
//       Set<String> uniqueDoctorIds = {};

//       for (var doc in snapshot.docs) {
//         Consultation consultation = Consultation.fromFirestore(doc);
//         consultations.add(consultation);

//         if (consultation.idDocteur.isNotEmpty) {
//           uniqueDoctorIds.add(consultation.idDocteur);
//         }
//       }

//       Map<String, Docteur> doctorsMap = {};

//       if (uniqueDoctorIds.isNotEmpty) {
//         for (var chunk in _chunked(uniqueDoctorIds.toList(), 10)) {
//           final doctorsSnapshot = await _firestore
//               .collection('doctors')
//               .where(FieldPath.documentId, whereIn: chunk)
//               .get();

//           for (var doctorDoc in doctorsSnapshot.docs) {
//             doctorsMap[doctorDoc.id] = Docteur.fromFirestore(doctorDoc);
//           }
//         }
//       }

//       for (var consultation in consultations) {
//         if (doctorsMap.containsKey(consultation.idDocteur)) {
//           consultation.docteur = doctorsMap[consultation.idDocteur];
//         }
//       }

//       return consultations;
//     } catch (e) {
//       print('Erreur Firebase: $e');
//       rethrow;
//     }
//   }
// }

// // Widget de carte pour afficher une consultation (inchangé)
// class ConsultationCard extends StatelessWidget {
//   final String doctorName;
//   final String doctorSpecialty;
//   final String doctorImageUrl;
//   final DateTime consultationDate;
//   final String consultationReason;
//   final String roomNumber;

//   const ConsultationCard({
//     super.key,
//     required this.doctorName,
//     required this.doctorSpecialty,
//     required this.doctorImageUrl,
//     required this.consultationDate,
//     required this.consultationReason,
//     required this.roomNumber,
//   });

//   String _formatDate(DateTime date) {
//     return DateFormat('dd/MM/yyyy HH:mm').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 // Doctor image
//                 doctorImageUrl.isNotEmpty
//                     ? CircleAvatar(
//                         backgroundImage: NetworkImage(doctorImageUrl),
//                         radius: 30,
//                       )
//                     : CircleAvatar(
//                         radius: 30,
//                         backgroundColor: Colors.blue.shade100,
//                         child: Icon(Icons.person),
//                       ),
//                 const SizedBox(width: 12),
//                 // Doctor info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Dr. $doctorName',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         doctorSpecialty,
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//             // Consultation details
//             _buildInfoRow(
//                 Icons.calendar_today, 'Date', _formatDate(consultationDate)),
//             const SizedBox(height: 8),
//             _buildInfoRow(Icons.healing, 'Motif', consultationReason),
//             const SizedBox(height: 8),
//             _buildInfoRow(Icons.room, 'Salle', roomNumber),

//             // View details button
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton.icon(
//                 onPressed:
//                     null, // This is handled by the GestureDetector in parent
//                 icon: const Icon(Icons.arrow_forward),
//                 label: const Text('Voir détails'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.blue,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 16, color: Colors.blue),
//         const SizedBox(width: 8),
//         Text(
//           '$label: ',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value.isNotEmpty ? value : 'Non renseigné',
//             style: TextStyle(
//               fontSize: 14,
//               color: value.isNotEmpty ? Colors.black87 : Colors.grey,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Écran principal pour afficher la liste des consultations (modifié pour temps réel)
// class ConsultationsScreen extends StatefulWidget {
//   final String? doctorId; // Optionnel: pour filtrer par docteur
//   final String? patientId; // Optionnel: pour filtrer par patient

//   const ConsultationsScreen({
//     super.key,
//     this.doctorId,
//     this.patientId,
//   });

//   @override
//   _ConsultationsScreenState createState() => _ConsultationsScreenState();
// }

// class _ConsultationsScreenState extends State<ConsultationsScreen> {
//   final FirebaseService _service = FirebaseService();
//   Stream<List<Consultation>>? _consultationsStream;
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _setupConsultationsStream();
//   }

//   void _setupConsultationsStream() {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Sélectionner le stream approprié selon les filtres
//       if (widget.doctorId != null) {
//         _consultationsStream =
//             _service.streamConsultationsByDoctorId(widget.doctorId!);
//       } else if (widget.patientId != null) {
//         _consultationsStream =
//             _service.streamConsultationsByPatientId(widget.patientId!);
//       } else {
//         _consultationsStream = _service.streamAllConsultations();
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Colors.blue, // couleur de fond
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(25),
//               bottomRight: Radius.circular(25),
//             ),
//           ),
//           child: const SafeArea(
//             child: Center(
//               child: Text(
//                 'consultation',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       body: _buildBody(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _setupConsultationsStream,
//         tooltip: 'Rafraîchir',
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage != null) {
//       return Center(child: Text('Erreur: $_errorMessage'));
//     }

//     if (_consultationsStream == null) {
//       return const Center(child: Text('no consultation available'));
//     }

//     return StreamBuilder<List<Consultation>>(
//       stream: _consultationsStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Erreur: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('no consultation available'));
//         }

//         final consultations = snapshot.data!;

//         // Trier les consultations par date (optionnel)
//         consultations
//             .sort((a, b) => b.dateConsultation.compareTo(a.dateConsultation));

//         return ListView.builder(
//           padding: const EdgeInsets.all(8),
//           itemCount: consultations.length,
//           itemBuilder: (context, index) {
//             final consultation = consultations[index];
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ConsultationDetailScreen(
//                         consultation: consultation,
//                       ),
//                     ),
//                   );
//                 },
//                 child: ConsultationCard(
//                   doctorName:
//                       consultation.docteur?.nomComplet ?? 'Docteur inconnu',
//                   doctorSpecialty:
//                       consultation.docteur?.specialite ?? 'Spécialité inconnue',
//                   doctorImageUrl: consultation.docteur?.imageUrl ?? '',
//                   consultationDate: consultation.dateConsultation,
//                   consultationReason: consultation.reasonForVisit,
//                   roomNumber: consultation.numeroSalle,
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// // Écran de détail pour afficher les informations complètes d'une consultation (inchangé)
// class ConsultationDetailScreen extends StatelessWidget {
//   final Consultation consultation;

//   const ConsultationDetailScreen({super.key, required this.consultation});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('details Consultation'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Carte d'information du docteur
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     if (consultation.docteur?.imageUrl.isNotEmpty ?? false)
//                       CircleAvatar(
//                         backgroundImage:
//                             NetworkImage(consultation.docteur!.imageUrl),
//                         radius: 40,
//                       )
//                     else
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.blue.shade100,
//                         child: const Icon(Icons.person, size: 40),
//                       ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Dr. ${consultation.docteur?.nomComplet ?? "Inconnu"}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                             ),
//                           ),
//                           Text(
//                             consultation.docteur?.specialite ??
//                                 'Spécialité non renseignée',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Carte des détails de la consultation
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Informations of consultation',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     const Divider(height: 24),
//                     _buildInfoSection(
//                         'Date of consultation',
//                         DateFormat('dd/MM/yyyy HH:mm')
//                             .format(consultation.dateConsultation)),
//                     _buildInfoSection(
//                         'Durée', '${consultation.dureeMinutes} minutes'),
//                     _buildInfoSection('Salle', consultation.numeroSalle),
//                     _buildInfoSection(
//                         'Motif de visite', consultation.reasonForVisit),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Carte des signes vitaux
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Signes vitaux',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     const Divider(height: 24),
//                     _buildInfoSection(
//                         'Tension artérielle', consultation.bloodPressure),
//                     _buildInfoSection('Taille', consultation.height),
//                     _buildInfoSection('Poids', consultation.weight),
//                     _buildInfoSection(
//                         'Niveau de sucre', consultation.sugarLevel),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Carte du diagnostic
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Diagnostic et Observations',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     const Divider(height: 24),
//                     _buildInfoSection('Symptômes', consultation.symptoms),
//                     _buildInfoSection('Diagnostic', consultation.diagnosis),
//                     _buildInfoSection('Notes', consultation.notes),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoSection(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.blue,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value.isNotEmpty ? value : 'Non renseigné',
//             style: TextStyle(
//               color: value.isNotEmpty ? Colors.black : Colors.grey,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:async/async.dart';

// Model class for Doctors
class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.imageUrl,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      specialty: data['specialty'] ?? data['specialite'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Method to get full name
  String get fullName => '$firstName $lastName';
}

// Model class for Consultations
class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final String reasonForVisit;
  final String symptoms;
  final String notes;
  final String diagnosis;
  final String height;
  final String weight;
  final String bloodPressure;
  final String sugarLevel;
  final String time;
  final String date;
  final String type;
  final String ordonnance;
  Doctor? doctor;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.reasonForVisit,
    required this.symptoms,
    required this.notes,
    required this.diagnosis,
    required this.height,
    required this.weight,
    required this.bloodPressure,
    required this.sugarLevel,
    required this.time,
    required this.date,
    required this.type,
    required this.ordonnance,
    this.doctor,
  });

  DateTime get dateTime {
    try {
      // Try different date formats
      try {
        final dateParts = date.split('-');
        if (dateParts.length == 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final year = int.parse(dateParts[2]);

          final timeParts = time.split(':');
          int hour = 0;
          int minute = 0;

          if (timeParts.length == 2) {
            hour = int.parse(timeParts[0]);
            minute = int.parse(timeParts[1]);
          }

          return DateTime(year, month, day, hour, minute);
        }
      } catch (e) {
        print('Error parsing date/time: $e');
      }

      // Fallback: try parsing with DateFormat
      try {
        final dateObj = DateFormat('dd-MM-yyyy').parse(date);
        final timeObj = DateFormat('HH:mm').parse(time);
        return DateTime(
          dateObj.year,
          dateObj.month,
          dateObj.day,
          timeObj.hour,
          timeObj.minute,
        );
      } catch (e) {
        print('Error parsing with DateFormat: $e');
      }

      // Last resort
      return DateTime.now();
    } catch (e) {
      print('Critical date parsing error: $e');
      return DateTime.now();
    }
  }

  factory Consultation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Consultation(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      reasonForVisit: data['reason_for_visit'] ?? '',
      symptoms: data['symptoms'] ?? '',
      notes: data['notes'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      height: data['height'] ?? '',
      weight: data['weight'] ?? '',
      bloodPressure: data['blood_pressure'] ?? '',
      sugarLevel: data['sugar_level'] ?? '',
      time: data['time'] ?? '',
      date: data['date'] ?? '',
      type: data['type'] ?? '',
      ordonnance: data['ordonnance'] ?? '',
    );
  }
}

// Service for interacting with Firebase
class ConsultationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Helper method to chunk a list into batches
  List<List<T>> _chunked<T>(List<T> list, int size) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += size) {
      chunks.add(
          list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }

  // Stream consultations for current user in real-time
  Stream<List<Consultation>> streamUserConsultations() {
    if (currentUserId == null) {
      // Return empty stream if not logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('consultation')
        .where('patientId', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      // Extract consultations
      List<Consultation> consultations = [];
      Set<String> doctorIds = {};

      for (var doc in snapshot.docs) {
        final consultation = Consultation.fromFirestore(doc);
        consultations.add(consultation);

        if (consultation.doctorId.isNotEmpty) {
          doctorIds.add(consultation.doctorId);
        }
      }

      // Fetch doctor information in batches (Firestore limit is 10 items in whereIn)
      Map<String, Doctor> doctorsMap = {};

      if (doctorIds.isNotEmpty) {
        for (var chunk in _chunked(doctorIds.toList(), 10)) {
          try {
            final doctorsSnapshot = await _firestore
                .collection('doctors')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

            for (var doctorDoc in doctorsSnapshot.docs) {
              doctorsMap[doctorDoc.id] = Doctor.fromFirestore(doctorDoc);
            }
          } catch (e) {
            print('Error fetching doctors batch: $e');
          }
        }
      }

      // Associate doctors with consultations
      for (var consultation in consultations) {
        if (doctorsMap.containsKey(consultation.doctorId)) {
          consultation.doctor = doctorsMap[consultation.doctorId];
        }
      }

      // Sort by date (newest first)
      consultations.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return consultations;
    });
  }
}

// Consultation card widget
class ConsultationCard extends StatelessWidget {
  final Consultation consultation;
  final VoidCallback onTap;

  const ConsultationCard({
    Key? key,
    required this.consultation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Card color
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Doctor image
                  if (consultation.doctor?.imageUrl.isNotEmpty ?? false)
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(consultation.doctor!.imageUrl),
                      radius: 30,
                    )
                  else
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.person),
                    ),
                  const SizedBox(width: 12),
                  // Doctor info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${consultation.doctor?.fullName ?? 'Unknown Doctor'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          consultation.doctor?.specialty ?? 'Unknown Specialty',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Consultation details
              _buildInfoRow(Icons.calendar_today, 'Date',
                  '${consultation.date} at ${consultation.time}'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  Icons.medical_services,
                  'Type',
                  consultation.type.isNotEmpty
                      ? (consultation.type == 'online' ? 'Online' : 'In Person')
                      : 'Not specified'),
              const SizedBox(height: 8),
              _buildInfoRow(
                  Icons.healing, 'Reason', consultation.reasonForVisit),

              // View details button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View details'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not specified',
            style: TextStyle(
              fontSize: 14,
              color: value.isNotEmpty ? Colors.black87 : Colors.grey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Main consultations screen
class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({Key? key}) : super(key: key);

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final ConsultationService _service = ConsultationService();
  late Stream<List<Consultation>> _consultationsStream;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupConsultationsStream();
  }

  void _setupConsultationsStream() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _consultationsStream = _service.streamUserConsultations();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                ' Consultations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    return StreamBuilder<List<Consultation>>(
      stream: _consultationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No consultations available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final consultations = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: consultations.length,
          itemBuilder: (context, index) {
            final consultation = consultations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ConsultationCard(
                consultation: consultation,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsultationDetailScreen(
                        consultation: consultation,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// Detail screen for a specific consultation
class ConsultationDetailScreen extends StatelessWidget {
  final Consultation consultation;

  const ConsultationDetailScreen({
    Key? key,
    required this.consultation,
  }) : super(key: key);

  Future<void> _launchPrescriptionURL() async {
    if (consultation.ordonnance.isEmpty) {
      return;
    }

    try {
      print(
          '-----------------------------------------------------------------------------------------------------------No prescription URL available');
      final Uri url = Uri.parse(consultation.ordonnance);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch ${url.toString()}';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                'Consultation Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor information card
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (consultation.doctor?.imageUrl.isNotEmpty ?? false)
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(consultation.doctor!.imageUrl),
                        radius: 40,
                      )
                    else
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Color.fromARGB(255, 25, 118, 210),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. ${consultation.doctor?.fullName ?? "Unknown"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            consultation.doctor?.specialty ??
                                'Specialty not specified',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Consultation details card
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consultation Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoSection('Date', consultation.date),
                    _buildInfoSection('Time', consultation.time),
                    _buildInfoSection(
                        'Type',
                        consultation.type.isNotEmpty
                            ? (consultation.type == 'online'
                                ? 'Online'
                                : 'In Person')
                            : 'Not specified'),
                    _buildInfoSection(
                        'Reason for visit', consultation.reasonForVisit),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Vital signs card
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vital Signs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoSection(
                        'Blood Pressure', consultation.bloodPressure),
                    _buildInfoSection('Height', consultation.height),
                    _buildInfoSection('Weight', consultation.weight),
                    _buildInfoSection('Sugar Level', consultation.sugarLevel),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Diagnosis card
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diagnosis and Observations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoSection('Symptoms', consultation.symptoms),
                    _buildInfoSection('Diagnosis', consultation.diagnosis),
                    _buildInfoSection('Notes', consultation.notes),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Prescription button
            if (consultation.ordonnance.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _launchPrescriptionURL,
                  icon: const Icon(Icons.description),
                  label: const Text('View Prescription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'Not specified',
            style: TextStyle(
              color: value.isNotEmpty ? Colors.black : Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
