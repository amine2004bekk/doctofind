import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthProfile extends StatefulWidget {
  final String patientId;

  HealthProfile({Key? key, required this.patientId}) : super(key: key);

  @override
  State<HealthProfile> createState() => _HealthProfileState();
}

class _HealthProfileState extends State<HealthProfile> {
  final List<Color> _pageColors = [
    Colors.red.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.purple.shade100,
  ];

  Stream<DocumentSnapshot>? _medicalInfoStream;

  @override
  void initState() {
    super.initState();
    // Set up stream to listen to the patient's medical_info subcollection
    _medicalInfoStream = FirebaseFirestore.instance
        .collection('patient')
        .doc(widget.patientId)
        .collection('medical_info')
        .snapshots()
        .map(
            (snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null)
        .where((doc) => doc != null)
        .cast<DocumentSnapshot>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Health Profile'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _medicalInfoStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print(
                'Loading...........................................................................');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text('No medical information found for this patient.'),
            );
          }

          // Extract the data from the document
          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Get the arrays from the document, with fallbacks for missing data
          final List<String> bloodType = _getStringList(data, 'blood_type');
          final List<String> allergies = _getStringList(data, 'allergies');
          final List<String> chronics = _getStringList(data, 'chronics');
          final List<String> familyHistory =
              _getStringList(data, 'family_history');
          final List<String> medications = _getStringList(data, 'medications');
          final List<String> surgeries = _getStringList(data, 'surgeries');

          return _buildProfilePage(
            bloodType: bloodType,
            allergies: allergies,
            chronics: chronics,
            familyHistory: familyHistory,
            medications: medications,
            surgeries: surgeries,
          );
        },
      ),
    );
  }

  // Helper method to convert dynamic data to List<String> safely
  List<String> _getStringList(Map<String, dynamic> data, String field) {
    if (!data.containsKey(field)) return [];

    var value = data[field];
    if (value == null) return [];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    } else if (value is String) {
      return [value];
    }

    return [];
  }

  Widget _buildProfilePage({
    required List<String> bloodType,
    required List<String> allergies,
    required List<String> chronics,
    required List<String> familyHistory,
    required List<String> medications,
    required List<String> surgeries,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // const Text(
            //   'Health Profile',
            //   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            //   textAlign: TextAlign.center,
            // ),
            // const SizedBox(height: 30),

            // Blood Type section
            _buildReviewSection(
              'Blood Type',
              Icons.bloodtype,
              _pageColors[0],
              bloodType.isEmpty ? ['Not specified'] : bloodType,
            ),

            // Allergies section
            _buildReviewSection(
              'Allergies',
              Icons.warning_amber_rounded,
              _pageColors[1],
              allergies.isEmpty ? ['No allergies'] : allergies,
            ),

            // Chronics section
            _buildReviewSection(
              'Chronics',
              Icons.medical_services,
              _pageColors[2],
              chronics.isEmpty ? ['No chronics'] : chronics,
            ),

            // Family History section
            _buildReviewSection(
              'Family History',
              Icons.family_restroom,
              _pageColors[3],
              familyHistory.isEmpty ? ['No family history'] : familyHistory,
            ),

            // Medications section
            _buildReviewSection(
              'Medications',
              Icons.medication,
              _pageColors[4],
              medications.isEmpty ? ['No medications'] : medications,
            ),

            // Surgeries section
            _buildReviewSection(
              'Surgeries',
              Icons.healing,
              _pageColors[5],
              surgeries.isEmpty ? ['No surgeries'] : surgeries,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(
    String title,
    IconData icon,
    Color backgroundColor,
    List<String> items,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1.5,
              color: Colors.black38,
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '• $item',
                    style: const TextStyle(fontSize: 16),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
