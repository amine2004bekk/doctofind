import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/classdoctor_profil.dart';
import 'package:flutter_application_2/doctorprofile.dart';
import 'package:flutter_application_2/screen/appontment_details.dart';
import 'package:flutter_application_2/screen/canceldRDV.dart';
import 'package:flutter_application_2/tools/card__rdv.dart';

class Rdv extends StatefulWidget {
  const Rdv({super.key});

  @override
  State<Rdv> createState() => _RdvState();
}

class _RdvState extends State<Rdv> {
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSearchVisible = false;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  String _sortBy = 'time'; // Default sort by time

  // Méthode pour récupérer les rendez-vous d'un patient avec tri
  Stream<QuerySnapshot> getAppointmentsByStatus(String status) {
    String? patientUid = _auth.currentUser?.uid;

    if (patientUid == null) return const Stream.empty();

    Query query = _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientUid)
        .where('status', isEqualTo: status);

    // Appliquer le tri
    if (_sortBy == 'time') {
      query = query.orderBy('time', descending: false);
    } else if (_sortBy == 'name') {
      query = query.orderBy('doctorName', descending: false);
    }

    return query.snapshots();
  }

  // Méthode pour rechercher des rendez-vous
  Stream<QuerySnapshot> searchAppointments(String searchText) {
    String? patientUid = _auth.currentUser?.uid;

    if (patientUid == null || searchText.isEmpty) return const Stream.empty();

    // Recherche par nom de docteur (conversion en minuscule pour une recherche insensible à la casse)
    Query query = _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientUid)
        .where('doctorName', isGreaterThanOrEqualTo: searchText)
        .where('doctorName', isLessThanOrEqualTo: searchText + '\uf8ff');

    return query.snapshots();
  }

  // Méthode pour récupérer les informations complètes du médecin
  Future<Map<String, dynamic>> getDoctorInfo(String doctorId) async {
    try {
      DocumentSnapshot doctorDoc =
          await _firestore.collection('doctors').doc(doctorId).get();

      if (doctorDoc.exists) {
        return doctorDoc.data() as Map<String, dynamic>;
      } else {
        return {
          'firstName': 'Médecin inconnu',
          'specialty': 'Spécialité inconnue'
        };
      }
    } catch (e) {
      print('Erreur lors de la récupération du médecin: $e');
      return {'firstName': 'Erreur', 'specialty': 'Erreur'};
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldkey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(_isSearchVisible ? 200 : 100),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _sortBy = _sortBy == 'time' ? 'firstName' : 'time';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Tri par ${_sortBy == 'time' ? 'heure' : 'nom'}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                          _sortBy == 'time'
                              ? Icons.access_time
                              : Icons.sort_by_alpha,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      // IconButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       _isSearchVisible = !_isSearchVisible;
                      //       if (!_isSearchVisible) {
                      //         _searchController.clear();
                      //         _searchQuery = '';
                      //       }
                      //     });
                      //   },
                      //   icon: Icon(
                      //     _isSearchVisible ? Icons.close : Icons.search,
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                  if (_isSearchVisible)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Rechercher par nom, spécialité ou date',
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          filled: true,
                          fillColor: Colors.blue[700],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.white),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  const TabBar(
                    dividerHeight: 0,
                    labelColor: Colors.white,
                    labelStyle: TextStyle(fontSize: 18),
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'booked'),
                      Tab(text: 'completed'),
                      Tab(text: 'cancelled'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _searchQuery.isNotEmpty
            ? _buildSearchResults()
            : TabBarView(
                children: [
                  _buildAppointmentsList('booked'),
                  _buildAppointmentsList('completed'),
                  _buildAppointmentsList('cancelled'),
                ],
              ),
      ),
    );
  }

  // Widget pour afficher les résultats de recherche
  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: searchAppointments(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('no appointments found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            var appointment = snapshot.data!.docs[index];
            var appointmentData = appointment.data() as Map<String, dynamic>;

            return FutureBuilder<Map<String, dynamic>>(
              future: getDoctorInfo(appointmentData['doctorId'] ?? ''),
              builder: (context, doctorSnapshot) {
                if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                var doctorData = doctorSnapshot.data ??
                    {'firstName': 'Chargement...', 'specialty': ''};

                return _buildAppointmentCard(
                  appointment.id,
                  appointmentData,
                  doctorData,
                );
              },
            );
          },
        );
      },
    );
  }

  // Widget pour afficher la liste des rendez-vous par statut
  Widget _buildAppointmentsList(String status) {
    // Conversion de statut en valeur Firestore
    String firestoreStatus = status;
    if (status == 'booked') firestoreStatus = 'booked';
    if (status == 'completed') firestoreStatus = 'completed';
    if (status == 'cancelled') firestoreStatus = 'cancelled';

    return StreamBuilder<QuerySnapshot>(
      stream: getAppointmentsByStatus(firestoreStatus),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('no appontment  ${_getStatusText(status)}'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            var appointment = snapshot.data!.docs[index];
            var appointmentData = appointment.data() as Map<String, dynamic>;

            return FutureBuilder<Map<String, dynamic>>(
              future: getDoctorInfo(appointmentData['doctorId'] ?? ''),
              builder: (context, doctorSnapshot) {
                if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 80,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                var doctorData = doctorSnapshot.data ??
                    {'firstName': 'Chargement...', 'specialty': ''};

                if (status == 'booked') {
                  return _buildAppointmentCard(
                    appointment.id,
                    appointmentData,
                    doctorData,
                  );
                } else {
                  // Rendez-vous terminés ou annulés
                  return AppointmentCard(
                    doctorName: doctorData['firstName'] ?? 'Inconnu',
                    speciality:
                        doctorData['specialty'] ?? 'Spécialité inconnue',
                    date: formatDate(appointmentData['date']),
                    staRT_DATE: appointmentData['time'] ??
                        appointmentData['heure'] ??
                        '00:00',
                    timeSlot: appointmentData['time'] ??
                        appointmentData['heure'] ??
                        '00:00',
                    onCardTap: () {
                      _navigateToDoctorProfile(doctorData);
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // Widget pour construire une carte de rendez-vous active
  Widget _buildAppointmentCard(
    String appointmentId,
    Map<String, dynamic> appointmentData,
    Map<String, dynamic> doctorData,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          _navigateToDoctorProfile(doctorData);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Color.fromARGB(255, 225, 241, 255),
                      backgroundImage: doctorData['photoUrl'] != null &&
                              doctorData['photoUrl'].toString().isNotEmpty
                          ? NetworkImage(doctorData['photoUrl'])
                          : null,
                      child: doctorData['photoUrl'] == null ||
                              doctorData['photoUrl'].toString().isEmpty
                          ? const Icon(Icons.person,
                              color: Color.fromARGB(255, 25, 118, 210),
                              size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${doctorData['firstName'] ?? 'Inconnu'} ${doctorData['lastName'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          doctorData['specialty'] ?? 'Spécialité inconnue',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: appointmentData['type'] == 'in person'
                        ? const Icon(
                            Icons.people,
                            color: Colors.blue,
                          )
                        : const Icon(Icons.video_call, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue[700]!,
                    width: 1,
                  ),
                  color: const Color.fromARGB(255, 225, 241, 255),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color.fromARGB(255, 25, 118, 210),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(appointmentData['date']),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 25, 118, 210),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color.fromARGB(255, 25, 118, 210),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appointmentData['time'] ??
                              appointmentData['heure'] ??
                              '00:00',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 25, 118, 210),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          cancelAppointment(appointmentId);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 30),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 225, 225),
                            border: Border.all(
                              color: const Color.fromARGB(255, 255, 0, 0),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      AppointmentDetailsScreenWithData(
                                          appointmentId: appointmentId),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 25),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 225, 241, 255),
                            border: Border.all(
                              color: const Color.fromARGB(255, 25, 118, 210),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "See Details",
                            style: TextStyle(
                                color: Color.fromARGB(255, 25, 118, 210),
                                fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation vers le profil du médecin
  void _navigateToDoctorProfile(Map<String, dynamic> doctorData) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DoctorProfileScreen(
          firstName: doctorData['firstName'] ?? '',
          specialty: doctorData['specialty'] ?? '',
          address: doctorData['address'] ?? '',
          description: doctorData['description'] ?? '',
          phoneNumber: doctorData['phoneNumber'] ?? '',
          locations: doctorData['locations'] ?? [],
          doctorId: doctorData['id_doctor'] ?? doctorData['doctorId'] ?? '',
          doctorName: doctorData['name'] ?? '',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // Méthode pour annuler un rendez-vous
  void cancelAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': 'cancelled'});
    } catch (e) {
      print('Erreur lors de l\'annulation du rendez-vous: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors de l\'annulation du rendez-vous')));
    }
  }

  // Méthode pour formater la date
  String formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date inconnue';

    try {
      if (dateValue is Timestamp) {
        DateTime date = dateValue.toDate();
        return '${date.day}/${date.month}/${date.year}';
      } else if (dateValue is String) {
        return dateValue;
      }
      return 'Date inconnue';
    } catch (e) {
      print('Erreur de formatage de la date: $e');
      return 'Date inconnue';
    }
  }

  // Méthode pour obtenir le texte du statut
  String _getStatusText(String status) {
    switch (status) {
      case 'booked':
        return 'booked';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return '';
    }
  }
}

Future<void> getAppointmentIds() async {
  List<String> appointmentIds = []; // La variable pour stocker les IDs

  try {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('appointments').get();

    appointmentIds = snapshot.docs.map((doc) => doc.id).toList();

    print(appointmentIds); // Affiche la liste des IDs
  } catch (e) {
    print('Erreur : $e');
  }
}
