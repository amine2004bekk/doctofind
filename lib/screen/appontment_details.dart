import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Model classes to store the fetched data
class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String address;
  final String clinicName;
  final String email;
  final String phone;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.address,
    required this.clinicName,
    required this.email,
    required this.phone,
  });

  factory Doctor.fromFirestore(Map<String, dynamic> data, String id) {
    return Doctor(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      specialty: data['specialty'] ?? '',
      address: data['address'] ?? '',
      clinicName: data['clinicName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String phone;
  final String placeOfBirth;
  final List<String> allergies;
  final String bloodType;
  final List<String> chronics;
  final List<String> familyHistory;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.phone,
    required this.placeOfBirth,
    required this.allergies,
    required this.bloodType,
    required this.chronics,
    required this.familyHistory,
  });

  factory Patient.fromFirestore(Map<String, dynamic> data, String id) {
    return Patient(
      id: id,
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      gender: data['gender'] ?? '',
      dateOfBirth: data['date_of_birth'] ?? '',
      phone: data['phone'] ?? '',
      placeOfBirth: data['place_of_birth'] ?? '',
      allergies: _convertToStringList(data['allergies']),
      bloodType: data['blood_type'] is List
          ? _convertToStringList(data['blood_type']).isNotEmpty
              ? _convertToStringList(data['blood_type'])[0]
              : ''
          : data['blood_type'] ?? '',
      chronics: _convertToStringList(data['chronics']),
      familyHistory: _convertToStringList(data['family_history']),
    );
  }

  static List<String> _convertToStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }
}

class Appointment {
  final String id;
  final String doctorId;
  final String patientId;
  final String date;
  final String time;
  final String type;
  final String status;
  final String reason;

  Doctor? doctor;
  Patient? patient;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    required this.reason,
    this.doctor,
    this.patient,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data, String id) {
    return Appointment(
      id: id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      type: data['type'] ?? '',
      status: data['status'] ?? '',
      reason: data['reason'] ?? '',
    );
  }
}

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch complete appointment details including doctor and patient information
  Future<Appointment?> fetchAppointmentDetails(String appointmentId) async {
    try {
      // Step 1: Get the appointment document
      final appointmentDoc =
          await _firestore.collection('appointments').doc(appointmentId).get();

      if (!appointmentDoc.exists || appointmentDoc.data() == null) {
        return null;
      }

      // Create the appointment object
      final appointment =
          Appointment.fromFirestore(appointmentDoc.data()!, appointmentDoc.id);

      // Step 2: Get the doctor details
      final doctorDoc = await _firestore
          .collection('doctors')
          .doc(appointment.doctorId)
          .get();

      if (doctorDoc.exists && doctorDoc.data() != null) {
        appointment.doctor =
            Doctor.fromFirestore(doctorDoc.data()!, doctorDoc.id);
      }

      // Step 3: Get the patient details
      final patientDoc = await _firestore
          .collection('patient')
          .doc(appointment.patientId)
          .get();

      if (patientDoc.exists && patientDoc.data() != null) {
        appointment.patient =
            Patient.fromFirestore(patientDoc.data()!, patientDoc.id);
      }

      // Now the appointment object contains all related information
      return appointment;
    } catch (e) {
      print('Error fetching appointment details: $e');
      return null;
    }
  }

  // Get all appointments for a specific doctor
  Future<List<Appointment>> fetchDoctorAppointments(String doctorId) async {
    try {
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return await _processAppointments(appointmentsSnapshot);
    } catch (e) {
      print('Error fetching doctor appointments: $e');
      return [];
    }
  }

  // Get all appointments for a specific patient
  Future<List<Appointment>> fetchPatientAppointments(String patientId) async {
    try {
      final appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();

      return await _processAppointments(appointmentsSnapshot);
    } catch (e) {
      print('Error fetching patient appointments: $e');
      return [];
    }
  }

  // Helper method to process appointment snapshots
  Future<List<Appointment>> _processAppointments(
      QuerySnapshot appointmentsSnapshot) async {
    List<Appointment> appointments = [];

    for (var doc in appointmentsSnapshot.docs) {
      final appointment =
          Appointment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);

      // Get doctor info
      final doctorDoc = await _firestore
          .collection('doctors')
          .doc(appointment.doctorId)
          .get();
      if (doctorDoc.exists && doctorDoc.data() != null) {
        appointment.doctor =
            Doctor.fromFirestore(doctorDoc.data()!, doctorDoc.id);
      }

      // Get patient info
      final patientDoc = await _firestore
          .collection('patient')
          .doc(appointment.patientId)
          .get();
      if (patientDoc.exists && patientDoc.data() != null) {
        appointment.patient =
            Patient.fromFirestore(patientDoc.data()!, patientDoc.id);
      }

      appointments.add(appointment);
    }

    return appointments;
  }
}

// Usage in the AppointmentDetailsScreen
class AppointmentDetailsScreenWithData extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsScreenWithData({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<AppointmentDetailsScreenWithData> createState() =>
      _AppointmentDetailsScreenWithDataState();
}

class _AppointmentDetailsScreenWithDataState
    extends State<AppointmentDetailsScreenWithData> {
  final AppointmentService _appointmentService = AppointmentService();
  Appointment? _appointment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentData();
  }

  Future<void> _fetchAppointmentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointment = await _appointmentService
          .fetchAppointmentDetails(widget.appointmentId);

      setState(() {
        _appointment = appointment;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointment: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Appointment'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_appointment == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Appointment'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Appointment not found'),
        ),
      );
    }

    final doctor = _appointment!.doctor;
    final patient = _appointment!.patient;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Appointment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info card
            if (doctor != null)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Doctor image
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person_2_outlined,
                          color: Colors.white, size: 40),
                      backgroundImage:
                          AssetImage('assets/doctor_placeholder.jpg'),
                    ),
                    const SizedBox(width: 16),
                    // Doctor details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Dr. ${doctor.firstName} ${doctor.lastName}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            doctor.specialty,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  doctor.address,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  // overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            // Scheduled Appointment
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scheduled Appointment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Date', _appointment!.date),
                  _buildInfoRow('Time', _appointment!.time),
                  _buildInfoRow('Type', _appointment!.type),
                  _buildInfoRow('Status', _appointment!.status),
                ],
              ),
            ),
            const Divider(),
            // Patient Info
            if (patient != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Info.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Full Name',
                        '${patient.firstName} ${patient.lastName}'),
                    _buildInfoRow('Gender', patient.gender),
                    _buildInfoRow('Date of Birth', patient.dateOfBirth),
                    if (patient.allergies.isNotEmpty)
                      _buildInfoRow('Allergies', patient.allergies.join(', ')),
                    if (patient.chronics.isNotEmpty)
                      _buildInfoRow(
                          'Chronic Conditions', patient.chronics.join(', ')),
                    if (patient.bloodType.isNotEmpty)
                      _buildInfoRow('Blood Type', patient.bloodType),
                    _buildInfoRow('Problem', _appointment!.reason),
                  ],
                ),
              ),
            const Divider(),
            // Payment Info

            const SizedBox(height: 16),
            // Action button

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
