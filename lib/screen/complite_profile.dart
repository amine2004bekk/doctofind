import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/custom_button.dart';
import 'package:flutter_application_2/homee.dart';
import 'package:flutter_application_2/tools/new_interface_antec.dart';

class CompliteProfile extends StatefulWidget {
  const CompliteProfile({super.key});

  @override
  State<CompliteProfile> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<CompliteProfile> {
  String gender = '';
  String first_name = '';
  String last_name = '';
  String date_of_birth = '';
  String place_of_birth = '';
  String emergency_name = '';
  String emergency_contact = '';

  // ✅ Controllers
  late TextEditingController first_nameController;
  late TextEditingController last_nameController;
  late TextEditingController date_of_birthController;
  late TextEditingController place_of_birthController;
  late TextEditingController emergencyNameController;
  late TextEditingController emergencyContactController;

  @override
  void initState() {
    super.initState();
    first_nameController = TextEditingController(text: first_name);
    last_nameController = TextEditingController(text: last_name);
    date_of_birthController = TextEditingController(text: date_of_birth);
    place_of_birthController = TextEditingController(text: place_of_birth);
    emergencyNameController = TextEditingController(text: emergency_name);
    emergencyContactController = TextEditingController(text: emergency_contact);

    // ✅ Charger les données Firestore
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('User not logged in');
      return;
    }

    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('patient').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        print(
            '================================================================User data: $data');

        setState(() {
          // Check if the fields exist and use them if available
          first_nameController.text = data?['first_name'] ?? '';
          last_nameController.text = data?['last_name'] ?? '';
          date_of_birthController.text = data?['date_of_birth'] ?? '';
          place_of_birthController.text = data?['place_of_birth'] ?? '';
          emergencyNameController.text = data?['emergencyName'] ?? '';
          emergencyContactController.text = data?['emergencyContact'] ?? '';
          gender = data?['gender'] ?? '';
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  void dispose() {
    first_nameController.dispose();
    last_nameController.dispose();
    date_of_birthController.dispose();
    place_of_birthController.dispose();
    emergencyNameController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        centerTitle: true,
        actions: const [],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      'Your information can be updated at any time.',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Gender
            _buildSectionTitle('Gender', true),
            Row(
              children: [
                Expanded(
                  child: _buildRadioOption('Women', 'women', gender, (value) {
                    setState(() => gender = value!);
                  }),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildRadioOption('Man', 'man', gender, (value) {
                    setState(() => gender = value!);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // First Name
            _buildSectionTitle('First Name', true),
            _buildTextField(first_nameController, (value) {
              setState(() => first_name = value);
            }),
            const SizedBox(height: 16.0),

            // Last Name
            _buildSectionTitle('Last Name', true),
            _buildTextField(last_nameController, (value) {
              setState(() => last_name = value);
            }),
            const SizedBox(height: 16.0),

            // Birth Date
            _buildSectionTitle('Birth Date', true),
            Text('Format : dd-mm-yyyy',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8.0),
            _buildTextField(date_of_birthController, (value) {
              setState(() => date_of_birth = value);
            }),
            const SizedBox(height: 16.0),

            // Birth Place
            _buildSectionTitle('Birth Place', true),
            _buildTextField(place_of_birthController, (value) {
              setState(() => place_of_birth = value);
            }),
            const SizedBox(height: 16.0),

            // Emergency Name
            _buildSectionTitle('Emergency Contact Name', false),
            _buildTextField(emergencyNameController, (value) {
              setState(() => emergency_name = value);
            }),
            const SizedBox(height: 16.0),

            // Emergency Contact
            _buildSectionTitle('Emergency Contact Number', false),
            _buildTextField(emergencyContactController, (value) {
              setState(() => emergency_contact = value);
            }),
            const SizedBox(height: 24.0),

            // SAVE button
            Mybutton(
              text: "Continue",
              isOutlined: false,
              bgColor: Colors.blue,
              textColor: Colors.white,
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;

                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not logged in.")),
                  );
                  return;
                }

                // Validate required fields
                if (gender.isEmpty ||
                    first_nameController.text.isEmpty ||
                    last_nameController.text.isEmpty ||
                    date_of_birthController.text.isEmpty ||
                    place_of_birthController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please fill in all required fields.")),
                  );
                  return;
                }

                // Prepare user data to update
                Map<String, dynamic> userData = {
                  'first_name': first_nameController.text,
                  'last_name': last_nameController.text,
                  'gender': gender,
                  'date_of_birth': date_of_birthController.text,
                  'place_of_birth': place_of_birthController.text,
                  'emergencyName': emergencyNameController.text,
                  'emergencyContact': emergencyContactController.text,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                try {
                  // Update the existing patient document using the user's UID
                  await FirebaseFirestore.instance
                      .collection('patient')
                      .doc(uid)
                      .set({
                    'patientId': uid,
                    ...userData,
                  }, SetOptions(merge: true));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Profile Created successfully.")),
                  );

                  // Navigate to the home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MedicalInfoEntryFlow(
                              patientId: FirebaseAuth.instance.currentUser!.uid,
                            )),
                  );
                } catch (e) {
                  // Handle errors when the document doesn't exist yet
                  if (e is FirebaseException && e.code == 'not-found') {
                    try {
                      // If document doesn't exist, create it with set()
                      await FirebaseFirestore.instance
                          .collection('patient')
                          .doc(uid)
                          .set({
                        'patientId': uid,
                        ...userData,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Profile created successfully.")),
                      );

                      // Navigate to the home screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalInfoEntryFlow(
                                  patientId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                )),
                      );
                    } catch (innerError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Error creating profile: $innerError")),
                      );
                    }
                  } else {
                    // Handle other errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error updating profile: $e")),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // UI building methods
  Widget _buildSectionTitle(String title, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRequired) const SizedBox(width: 4.0),
          if (isRequired)
            Text(
              '(required)',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, Function(String) onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, dynamic value, dynamic groupValue,
      Function(dynamic) onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: value == groupValue ? Colors.blue : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: RadioListTile(
        title: Text(label),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Colors.blue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      ),
    );
  }
}
