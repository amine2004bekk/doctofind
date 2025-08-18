import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/methode__RDV.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorId; // Add doctorId for Firebase reference
  final String doctorName;
  final String specialty;
  final String imageUrl;
  final String address;
  final String description;
  final String phoneNumber;
  final List<String> locations;

  const DoctorProfileScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    this.imageUrl = '',
    required this.address,
    required this.description,
    required this.phoneNumber,
    required this.locations,
    required firstName,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isFavorite = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Working hours data
  String? startTime;
  String? endTime;
  int? duration;
  List<String> workingDays = [];
  String? clinicName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _fetchDoctorWorkingHours();
  }

  // Fetch doctor working hours from Firestore
  Future<void> _fetchDoctorWorkingHours() async {
    try {
      // First, get the main doctor document for the clinic name
      final doctorData =
          await _firestore.collection('doctors').doc(widget.doctorId).get();

      // Get the first (and only) document from the medical_info subcollection
      final medicalInfoSnapshot = await _firestore
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('availability')
          .limit(1)
          .get();

      if (doctorData.exists) {
        final Map<String, dynamic> doctorDataMap =
            doctorData.data() as Map<String, dynamic>;

        // Set the clinic name from the main doctor document
        setState(() {
          clinicName = doctorDataMap['clinicName'] ?? 'Not Available';
        });

        // Check if medical info exists and process it
        if (medicalInfoSnapshot.docs.isNotEmpty) {
          final medicalInfoDoc = medicalInfoSnapshot.docs.first;
          final Map<String, dynamic> medicalData = medicalInfoDoc.data();

          setState(() {
            startTime = medicalData['start_time'] ?? '09:00';
            endTime = medicalData['end_time'] ?? '17:00';
            duration = medicalData['duration'] ?? 10;

            // Parse working days from medical_info
            if (medicalData['working_days'] != null) {
              final List<dynamic> days = medicalData['working_days'];
              workingDays = days.map((day) => day.toString()).toList();
            } else {
              workingDays = [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday'
              ];
            }

            isLoading = false;
          });
        } else {
          // If medical_info doesn't exist, set default values
          setState(() {
            startTime = '09:00';
            endTime = '17:00';
            duration = 10;
            workingDays = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday'
            ];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Doctor document not found');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching doctor working hours: $e');
    }
  }

  // Check if the doctor is already favorited by the current user
  Future<void> _checkIfFavorite() async {
    final User? patient = _auth.currentUser;
    if (patient != null) {
      final docSnapshot = await _firestore
          .collection('patient')
          .doc(patient.uid)
          .collection('favorites')
          .doc(widget.doctorId)
          .get();

      setState(() {
        isFavorite = docSnapshot.exists;
      });
    }
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      // Show login prompt if user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour ajouter aux favoris'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    final userFavoritesRef = _firestore
        .collection('patient')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.doctorId);

    if (isFavorite) {
      // Add to favorites
      await userFavoritesRef.set({
        'doctorId': widget.doctorId,
        'doctorName': widget.doctorName,
        'specialty': widget.specialty,
        'imageUrl': widget.imageUrl,
        'address': widget.address,
        'description': widget.description,
        'phoneNumber': widget.phoneNumber,
        'locations': widget.locations,
        'addedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('added to favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Remove from favorites
      await userFavoritesRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('deleted from favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Doctor Header Info
            Container(
              width: double.infinity,
              color: const Color(0xFF0D6EFD),
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: widget.imageUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 38,
                            backgroundImage: NetworkImage(widget.imageUrl),
                          )
                        : const CircleAvatar(
                            radius: 38,
                            child: Icon(Icons.person, size: 40),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Dr ${widget.doctorName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.specialty,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today,
                        color: Color(0xFF0D6EFD)),
                    label: const Text(
                      'take an appointment',
                      style: TextStyle(
                          color: Color(0xFF0D6EFD),
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  (context, Animation, secondryanimation) =>
                                      AppointmentTimeSelectionScreen(
                                        doctorId: widget.doctorId,
                                      ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              }));
                    },
                  ),
                ],
              ),
            ),

            // Warning message
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFECB5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFDDA122)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This caregiver reserves online appointment booking for patients already being followed.',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Vous pouvez le contacter au ${widget.phoneNumber}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Working Hours Section (New)
            _buildSectionWithHeader(
              icon: Icons.access_time,
              title: 'Working Hours',
              content: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.schedule,
                                size: 16, color: Color(0xFF0D6EFD)),
                            const SizedBox(width: 8),
                            Text(
                              '$startTime - $endTime',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Working Days:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: workingDays
                              .map((day) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F0FF),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: const Color(0xFF0D6EFD),
                                          width: 1),
                                    ),
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                        color: Color(0xFF0D6EFD),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            const Icon(Icons.timer,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Appointment Duration: $duration minutes',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 128, 128, 128)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
            ),

            // Addresses section
            _buildSectionWithHeader(
              icon: Icons.location_on_outlined,
              title: 'Adresses',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location chips
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.locations
                          .map((location) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A5F),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  location,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                      ),
                      Expanded(
                        child: Text(
                          widget.address,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(
              height: 0,
            ),

            // Clinic Information (Updated to fetch from Firestore)
            _buildSectionWithHeader(
              icon: Icons.info_outline,
              title: 'Clinic Information',
              content: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              
                            ),
                            Text(
                              'Clinic Name: $clinicName',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithHeader({
    required IconData icon,
    required String title,
    String? actionText,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (actionText != null)
                    Text(
                      actionText,
                      style: const TextStyle(
                        color: Color(0xFF0D6EFD),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: content,
            ),
            const Divider(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleListItem(IconData icon, String title, String? actionText) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(title),
                ],
              ),
              if (actionText != null)
                Text(
                  actionText,
                  style: const TextStyle(
                    color: Color(0xFF0D6EFD),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
