import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/custom_button.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String gender = '';
  String firstName = '';
  String lastName = '';
  String birthDate = '';
  String birthPlace = '';
  String emergency_name = '';
  String emergency_contact = '';

  // ✅ Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController birthDateController;
  late TextEditingController birthPlaceController;
  late TextEditingController emergencyNameController;
  late TextEditingController emergencyContactController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: firstName);
    lastNameController = TextEditingController(text: lastName);
    birthDateController = TextEditingController(text: birthDate);
    birthPlaceController = TextEditingController(text: birthPlace);
    emergencyNameController = TextEditingController(text: emergency_name);
    emergencyContactController = TextEditingController(text: emergency_contact);

    // ✅ Charger les données Firestore
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print('User not  in');
      return;
    }

    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('patient').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        setState(() {
          firstNameController.text = data?['first_name'] ?? '';
          lastNameController.text = data?['last_name'] ?? '';
          birthDateController.text = data?['date_of_birth'] ?? '';
          birthPlaceController.text = data?['place_of_birth'] ?? '';
          emergencyNameController.text = data?['emergencyName'] ?? '';
          emergencyContactController.text = data?['emergencyContact'] ?? '';
          gender = data?['gender'] ?? '';
        });
      } else {
        print('User document mot not exist');
      }
    } catch (e) {
      print('Error fetching  data: $e');
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    birthPlaceController.dispose();
    emergencyNameController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('update profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
                      'your information can update in any time.',
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
                  child: _buildRadioOption('women', 'women', gender, (value) {
                    setState(() => gender = value!);
                  }),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildRadioOption('man', 'man', gender, (value) {
                    setState(() => gender = value!);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // First Name
            _buildSectionTitle('First Name', true),
            _buildTextField(firstNameController, (value) {
              setState(() => firstName = value);
            }),
            const SizedBox(height: 16.0),

            // Last Name
            _buildSectionTitle('Name', true),
            _buildTextField(lastNameController, (value) {
              setState(() => lastName = value);
            }),
            const SizedBox(height: 16.0),

            // Birth Date
            _buildSectionTitle('Birth Date', true),
            Text('Format : jj/mm/aaaa',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8.0),
            _buildTextField(birthDateController, (value) {
              setState(() => birthDate = value);
            }),
            const SizedBox(height: 16.0),

            // Birth Place
            _buildSectionTitle('Birth Place', true),
            _buildTextField(birthPlaceController, (value) {
              setState(() => birthPlace = value);
            }),
            const SizedBox(height: 16.0),

            // Emergency Name
            _buildSectionTitle('Emergency Name', false),
            _buildTextField(emergencyNameController, (value) {
              setState(() => emergency_name = value);
            }),
            const SizedBox(height: 16.0),

            // Emergency Contact
            _buildSectionTitle('Emergency Contact', false),
            _buildTextField(emergencyContactController, (value) {
              setState(() => emergency_contact = value);
            }),
            const SizedBox(height: 24.0),

            // SAVE button
            Mybutton(
              text: "SAVE",
              isOutlined: false,
              bgColor: Colors.blue,
              textColor: Colors.white,
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;

                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Utilisateur non connecté.")),
                  );
                  return;
                }

                Map<String, dynamic> userData = {
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'gender': gender,
                  'date_of_birth': birthDateController.text,
                  'place_of_birth': birthPlaceController.text,
                  'emergencyName': emergencyNameController.text,
                  'emergencyContact': emergencyContactController.text,
                };

                try {
                  //⁡⁢⁣⁣​‌‌‍la funtction de modifie​⁡
                  await FirebaseFirestore.instance
                      .collection('patient')
                      .doc(uid)
                      .set(userData, SetOptions(merge: true));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profil mis à jour.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur : $e")),
                  );
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
              '(requis)',
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
