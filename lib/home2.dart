import 'package:flutter/material.dart';
import 'package:flutter_application_2/RDV.dart';
import 'package:flutter_application_2/back-end/fetchdatadoctor.dart';
import 'package:flutter_application_2/classdoctor_profil.dart';
import 'package:flutter_application_2/fav.dart';
import 'package:flutter_application_2/screen/complite_profile.dart';
import 'package:flutter_application_2/see_all_speciality.dart';
import 'package:flutter_application_2/tools/doctor_card.dart';
import 'package:flutter_application_2/trail/explore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> favoriteDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteDoctors();
  }

  void _navigateToSpecialtyDoctors(String specialty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorListScreen(initialSpecialty: specialty),
      ),
    );
  }

  Future<void> _loadFavoriteDoctors() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Corrected: using user.uid instead of patientid.uid
        final QuerySnapshot snapshot = await _firestore
            .collection('patient')
            .doc(user.uid)
            .collection('favorites')
            .orderBy('addedAt', descending: true)
            .get();

        List<Doctor> doctors = [];
        for (var doc in snapshot.docs) {
          // Create Doctor object from document data
          final doctorData = doc.data() as Map<String, dynamic>;
          doctors.add(Doctor(
            id: doctorData['doctorId'] ?? '',
            name: doctorData['doctorName'] ?? '',
            imageUrl: doctorData['imageUrl'] ?? '',
            specialty: doctorData['specialty'] ?? '',
            address: doctorData['address'] ?? '',
            description: doctorData['description'] ?? '',
            phoneNumber: doctorData['phoneNumber'] ?? '',
            locations: doctorData['locations'] ?? [],
          ));
        }

        setState(() {
          favoriteDoctors = doctors;
          isLoading = false;
        });
      } else {
        setState(() {
          favoriteDoctors = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorite doctors: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search button
            Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue,
                      Color.fromRGBO(95, 118, 196, 1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(13),
                    child: Text(
                      'Take your\nhealth to the next level',
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DoctorListScreen()),
                        );
                      },
                      child: Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 25,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'search',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content with padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Favorite Doctors Section (only shown if user is logged in)

                  // Upcoming Schedule Section
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Upcomming Schedule',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to see all appointments
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Rdv(),
                            ),
                          );
                        },
                        child: const Text('See All',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Schedule card
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('patientId',
                            isEqualTo: _auth.currentUser!
                                .uid) // Replace with your actual patient ID variable
                        .where('status', isEqualTo: 'booked')
                        .orderBy('date')
                        .orderBy('time')
                        .limit(1)
                        .snapshots(),
                    builder: (context, appointmentSnapshot) {
                      if (appointmentSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (appointmentSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${appointmentSnapshot.error}'));
                      }

                      if (!appointmentSnapshot.hasData ||
                          appointmentSnapshot.data!.docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade200,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text('No upcoming appointments')],
                              ),
                            ],
                          ),
                        );
                      }

                      // Get the next appointment
                      final appointmentData = appointmentSnapshot.data!.docs[0]
                          .data() as Map<String, dynamic>;
                      final doctorId = appointmentData['doctorId'];
                      final appointmentDate = DateFormat('dd-MM-yyyy')
                          .parse(appointmentData['date']);
                      final appointmentTime = appointmentData['time'] as String;
                      final appointmentType = appointmentData['type'] as String;

                      // Format the date
                      final date =
                          DateFormat('EEEE, dd MMMM').format(appointmentDate);

                      // Time might be stored in different formats, adjust as needed
                      final time =
                          appointmentTime; // Adjust formatting if needed

                      // Now fetch the doctor information
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('doctors')
                            .doc(doctorId)
                            .snapshots(),
                        builder: (context, doctorSnapshot) {
                          if (doctorSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (doctorSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${doctorSnapshot.error}'));
                          }

                          if (!doctorSnapshot.hasData ||
                              !doctorSnapshot.data!.exists) {
                            return const Center(
                                child: Text('Doctor information not found'));
                          }

                          // Get doctor data
                          final doctorData = doctorSnapshot.data!.data()
                              as Map<String, dynamic>;
                          print(
                              '==================================================================');
                          print(doctorData);
                          print(
                              '==================================================================');

                          final doctorfirstName =
                              doctorData['firstName'] as String;
                          final doctorlastName =
                              doctorData['lastName'] as String;
                          final doctorSpecialty =
                              doctorData['specialty'] as String;
                          // You can get doctor's profile image URL if available
                          final doctorImageUrl =
                              doctorData['profileImageUrl'] as String?;

                          // Now build the UI with real data
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(73, 0, 0, 0),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.white,
                                      backgroundImage: doctorImageUrl != null
                                          ? NetworkImage(doctorImageUrl)
                                          : null,
                                      child: doctorImageUrl == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dr. $doctorfirstName $doctorlastName',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '$doctorSpecialty Consultation',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: appointmentType == 'in person'
                                              ? Icon(
                                                  Icons.person,
                                                  color: Colors.blue,
                                                  size: 27,
                                                )
                                              : Icon(
                                                  Icons.video_call,
                                                  color: Colors.blue,
                                                )),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Expanded(child: SizedBox()),
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        time,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Expanded(child: SizedBox()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Doctor Speciality Section
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Doctor Speciality',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SeeAllSpeciality(),
                                ),
                              );
                            },
                            child: const Text('See All',
                                style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            Container(
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        _navigateToSpecialtyDoctors('General'),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                          // Color.fromARGB(255, 227, 242, 253),
                                          // border:
                                          //     Border.all(color: Colors.blue, width: 1),
                                          ),
                                      child: ClipOval(
                                        child: Container(
                                          // Ensures visibility
                                          width: 60,
                                          height: 60,
                                          child: Image.asset(
                                            "images/health-checkup.gif",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: 70,
                                    child: Text(
                                      'General',
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () =>
                                  _navigateToSpecialtyDoctors('Dentist'),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                          color: Colors.white // border:
                                          //     Border.all(color: Colors.blue, width: 1),
                                          ),
                                      child: ClipOval(
                                        child: Container(
                                          // Ensures visibility
                                          width: 60,
                                          height: 60,
                                          child: Image.asset(
                                            "images/speciality/tooth-drill.gif",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 70,
                                      child: Text(
                                        'Dentist',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () =>
                                  _navigateToSpecialtyDoctors('Cardiology'),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                          // border:
                                          //     Border.all(color: Colors.blue, width: 1),
                                          ),
                                      child: ClipOval(
                                        child: Container(
                                          // Ensures visibility
                                          width: 60,
                                          height: 60,
                                          child: Image.asset(
                                            "images/speciality/cardio.gif",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 70,
                                      child: Text(
                                        'Cardiology',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () =>
                                  _navigateToSpecialtyDoctors('Orthopedics'),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                          // border:
                                          //     Border.all(color: Colors.blue, width: 1),
                                          ),
                                      child: ClipOval(
                                        child: Container(
                                          // Ensures visibility
                                          width: 60,
                                          height: 60,
                                          child: Image.asset(
                                            "images/speciality/joint.gif",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 70,
                                      child: Text(
                                        'Orthopedics',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () =>
                                  _navigateToSpecialtyDoctors('Neurology'),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                          // border:
                                          //     Border.all(color: Colors.blue, width: 1),
                                          ),
                                      child: ClipOval(
                                        child: Container(
                                          // Ensures visibility
                                          width: 60,
                                          height: 60,
                                          child: Image.asset(
                                            "images/speciality/neurology.gif",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 70,
                                      child: Text(
                                        'Neurology',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () => _navigateToSpecialtyDoctors(
                                  'Gastroenterology'),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                          // border:
                                          //     Border.all(color: Colors.blue, width: 1),
                                          ),
                                      child: ClipOval(
                                        child: Container(
                                          // Ensures visibility
                                          width: 60,
                                          height: 60,
                                          child: Image.asset(
                                            "images/speciality/stomach.gif",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 70,
                                      child: Text(
                                        'Gastroenterology',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: () =>
                                  _navigateToSpecialtyDoctors('Ophthalmology'),
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          shape: BoxShape.circle,
                                          color: Colors.white
                                          // border:
                                          //     Border.all(color: Colors.blue, width: 1),
                                          ),
                                      child: ClipOval(
                                        child: Container(
                                          // Ensures visibility
                                          width: 60,
                                          height: 60,
                                          child: Image.asset(
                                            "images/speciality/ophtalmologue.gif",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 70,
                                      child: Text(
                                        'Ophthalmology',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      if (_auth.currentUser != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Favorite Doctors',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    '${favoriteDoctors.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to see all favorite doctors
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoriteDoctorsScreen(),
                                  ),
                                ).then((_) => _loadFavoriteDoctors());
                              },
                              child: const Text('See All',
                                  style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),

                        // Display favorite doctors
                        if (isLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (favoriteDoctors.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'No favorite doctors yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          // Display list of favorite doctors
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: favoriteDoctors.length > 2
                                ? 2
                                : favoriteDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = favoriteDoctors[index];
                              return FavoriteDoctorCard(
                                doctorId: doctor.id,
                                name: doctor.name,
                                specialty: doctor.specialty,
                                imageUrl: doctor.imageUrl,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorProfileScreen(
                                        doctorId: doctor.id,
                                        doctorName: doctor.name,
                                        specialty: doctor.specialty,
                                        imageUrl: doctor.imageUrl,
                                        address: doctor.address,
                                        description: doctor.description,
                                        phoneNumber: doctor.phoneNumber,
                                        locations: [],
                                        firstName: doctor.name,
                                      ),
                                    ),
                                  ).then((_) => _loadFavoriteDoctors());
                                },
                              );
                            },
                          ),

                        const SizedBox(height: 10),
                      ],
                    ],
                  ),

                  // Special Doctor Section

                  const SizedBox(height: 16),
                  Column(
                    children: [],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Make sure you have this class defined somewhere in your project
class FavoriteDoctorCard extends StatelessWidget {
  final String doctorId;
  final String name;
  final String specialty;
  final String imageUrl;
  final VoidCallback onTap;

  const FavoriteDoctorCard({
    super.key,
    required this.doctorId,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Doctor image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey.shade200,
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                ),
                const SizedBox(width: 12),
                // Doctor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Make sure your Doctor class is properly defined
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final String address;
  final String description;
  final String phoneNumber;
  final List<dynamic> locations;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.address,
    required this.description,
    required this.phoneNumber,
    required this.locations,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Doctor(
      id: data['doctorId'] ?? '',
      name: data['doctorName'] ?? '',
      specialty: data['specialty'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      address: data['address'] ?? '',
      description: data['description'] ?? 'No description',
      phoneNumber: data['phoneNumber'] ?? 'Not available',
      locations: data['locations'] ?? [],
    );
  }
}

// Optional: Create a new screen for displaying all favorite doctors
class FavoriteDoctorsScreen extends StatefulWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  State<FavoriteDoctorsScreen> createState() => _FavoriteDoctorsScreenState();
}

class _FavoriteDoctorsScreenState extends State<FavoriteDoctorsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> favoriteDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllFavoriteDoctors();
  }

  Future<void> _loadAllFavoriteDoctors() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final QuerySnapshot snapshot = await _firestore
            .collection('patient')
            .doc(user.uid)
            .collection('favorites')
            .orderBy('addedAt', descending: true)
            .get();

        List<Doctor> doctors = [];
        for (var doc in snapshot.docs) {
          doctors.add(Doctor.fromFirestore(doc));
        }

        setState(() {
          favoriteDoctors = doctors;
          isLoading = false;
        });
      } else {
        setState(() {
          favoriteDoctors = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading favorite doctors: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('doctors favoris'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : favoriteDoctors.isEmpty
              ? const Center(
                  child: Text('No favorite doctors yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = favoriteDoctors[index];
                    return FavoriteDoctorCard(
                      doctorId: doctor.id,
                      name: doctor.name,
                      specialty: doctor.specialty,
                      imageUrl: doctor.imageUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorProfileScreen(
                              doctorId: doctor.id,
                              doctorName: doctor.name,
                              specialty: doctor.specialty,
                              imageUrl: doctor.imageUrl,
                              address: doctor.address,
                              description: doctor.description,
                              phoneNumber: doctor.phoneNumber,
                              locations: doctor.locations.cast<String>(),
                              firstName: doctor.name,
                            ),
                          ),
                        ).then((_) => _loadAllFavoriteDoctors());
                      },
                    );
                  },
                ),
    );
  }
}
