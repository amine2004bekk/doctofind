import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/classdoctor_profil.dart';
import 'package:flutter_application_2/screen/methode__RDV.dart';
import 'package:flutter_application_2/tools/doctor_card.dart';

class DoctorListScreen extends StatefulWidget {
  final String? initialSpecialty;
  const DoctorListScreen({super.key, this.initialSpecialty});

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  // Filtering options
  List<String> _specialtyOptions = [
    'No filter',
    'General',
    'Dentist',
    'Cardiology',
    'Orthopedics',
    'Neurology',
    'Gastroenterology',
    'Ophthalmology',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Psychology',
    'Otology',
    'Urology',
    'Pulmonary',
  ];

  @override
  void _filterDoctors(String query) {
    final lowercaseQuery = query.toLowerCase();

    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        // Check if a specialty filter is applied
        bool specialtyMatch = _selectedSpecialty == null ||
            _selectedSpecialty == 'No filter' || // Reset filter logic
            doctor['specialty'] == _selectedSpecialty;

        // Search across multiple fields
        bool searchMatch = (doctor['firstName']
                    ?.toString()
                    .toLowerCase()
                    .contains(lowercaseQuery) ??
                false) ||
            (doctor['lastName']
                    ?.toString()
                    .toLowerCase()
                    .contains(lowercaseQuery) ??
                false) ||
            (doctor['specialty']
                    ?.toString()
                    .toLowerCase()
                    .contains(lowercaseQuery) ??
                false) ||
            (doctor['address']
                    ?.toString()
                    .toLowerCase()
                    .contains(lowercaseQuery) ??
                false) ||
            (doctor['clinicName']
                    ?.toString()
                    .toLowerCase()
                    .contains(lowercaseQuery) ??
                false);

        return specialtyMatch && searchMatch;
      }).toList();
    });
  }

  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    if (widget.initialSpecialty != null) {
      _selectedSpecialty = widget.initialSpecialty;
    }
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      String? currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch doctors from Firestore
      QuerySnapshot querySnapshot =
          await _firestore.collection('doctors').get();

      // Transform query results into a list of doctor maps
      List<Map<String, dynamic>> doctors = querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      // Extract unique specialties and addresses
      Set<String> specialties = doctors
          .map((doctor) => doctor['specialty'] as String? ?? 'Unknown')
          .toSet();

      Set<String> addresses = doctors
          .map((doctor) => doctor['address'] as String? ?? 'Unknown')
          .toSet();

      setState(() {
        _doctors = doctors;
        _filteredDoctors = doctors;
        // _specialtyOptions = [...specialties];
        var _addressOptions = ['all addresses', ...addresses];
        _isLoading = false;
        if (_selectedSpecialty != null) {
          _filterDoctors(_searchController.text);
        }
      });
    } catch (e) {
      print('Error fetching doctors: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _filterDoctors(String query) {
  //   final lowercaseQuery = query.toLowerCase();

  //   setState(() {
  //     _filteredDoctors = _doctors.where((doctor) {
  //       // Check if a specialty filter is applied
  //       bool specialtyMatch = _selectedSpecialty == null ||
  //           _selectedSpecialty == 'see all specialty' ||
  //           doctor['specialty'] == _selectedSpecialty;

  //       // Search across multiple fields
  //       bool searchMatch = (doctor['firstName']
  //                   ?.toString()
  //                   .toLowerCase()
  //                   .contains(lowercaseQuery) ??
  //               false) ||
  //           (doctor['lastName']
  //                   ?.toString()
  //                   .toLowerCase()
  //                   .contains(lowercaseQuery) ??
  //               false) ||
  //           (doctor['specialty']
  //                   ?.toString()
  //                   .toLowerCase()
  //                   .contains(lowercaseQuery) ??
  //               false) ||
  //           (doctor['address']
  //                   ?.toString()
  //                   .toLowerCase()
  //                   .contains(lowercaseQuery) ??
  //               false) ||
  //           (doctor['clinicName']
  //                   ?.toString()
  //                   .toLowerCase()
  //                   .contains(lowercaseQuery) ??
  //               false);

  //       return specialtyMatch && searchMatch;
  //     }).toList();
  //   });
  // }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Specialty'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: _specialtyOptions.map((specialty) {
                    return RadioListTile<String>(
                      title: Text(specialty),
                      value: specialty,
                      groupValue: _selectedSpecialty,
                      onChanged: (String? value) {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedSpecialty = value;
                        });
                        _filterDoctors(_searchController.text);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
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
                const Center(
                  child: Text(
                    'Doctor Explorer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Looking for a doctor...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterDoctors('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: _filterDoctors,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon:
                            const Icon(Icons.filter_list, color: Colors.white),
                        onPressed: _showFilterDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredDoctors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 100, color: Colors.grey),
                      const Text(
                        'Aucun médecin trouvé',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _selectedSpecialty = null;
                          _filterDoctors('');
                        },
                        child: const Text('Réinitialiser la recherche'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    var doctor = _filteredDoctors[index];
                    return DoctorCard(
                      firstName: doctor['firstName'] ?? 'Unknown',
                      lastName: doctor['lastName'] ?? 'Doctor',
                      specialty: doctor['specialty'] ?? 'General Practice',
                      address: doctor['address'] ?? 'Address not available',
                      imageUrl: doctor['profileImageUrl'] ??
                          'https://via.placeholder.com/100',
                      onCardPressed: () => _navigateToDoctorDetails(doctor),
                      onAppointmentPressed: () => _bookAppointment(doctor),
                    );
                  },
                ),
    );
  }

  void _navigateToDoctorDetails(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorProfileScreen(
          doctorName: '${doctor['firstName']} ${doctor['lastName']}',
          specialty: doctor['specialty'] ?? 'Unknown',
          address: doctor['address'] ?? 'Not available',
          description: doctor['description'] ?? 'No description',
          phoneNumber: doctor['phone'] ?? 'Not available',
          locations: doctor['locations'] ?? [],
          doctorId: doctor['id_doctor'],
          firstName: null,
        ),
      ),
    );
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    // Implement appointment booking
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AppointmentTimeSelectionScreen(doctorId: doctor['id_doctor']),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
