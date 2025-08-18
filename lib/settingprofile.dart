import 'package:flutter/material.dart';
import 'package:flutter_application_2/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  String? gender;
  bool? hasNameChanged;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _birthPlace = 'Né(e) en France';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Modifier mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),
              _buildGenderSection(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Prénom',
                controller: _firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Nom',
                controller: _lastNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildNameChangeSection(),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Date de naissance',
                controller: _birthDateController,
                hint: 'jj/mm/aaaa',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre date de naissance';
                  }
                  // Add date format validation here
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildBirthPlaceDropdown(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Vos informations seront transmises à vos soignants.',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sexe à l\'état civil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text('(requis)', style: TextStyle(color: Colors.grey)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Féminin'),
                value: 'F',
                groupValue: gender,
                onChanged: (value) => setState(() => gender = value),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Masculin'),
                value: 'M',
                groupValue: gender,
                onChanged: (value) => setState(() => gender = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameChangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre nom de famille a-t-il changé depuis votre naissance ?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text('(requis)', style: TextStyle(color: Colors.grey)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Oui'),
                value: true,
                groupValue: hasNameChanged,
                onChanged: (value) => setState(() => hasNameChanged = value),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Non'),
                value: false,
                groupValue: hasNameChanged,
                onChanged: (value) => setState(() => hasNameChanged = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text('(requis)', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildBirthPlaceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lieu de naissance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text('(requis)', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _birthPlace,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
          items: ['Né(e) en France', 'Né(e) à l\'étranger'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _birthPlace = value);
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        Mybutton(
            text: 'sign out',
            isOutlined: false,
            bgColor: Colors.blue,
            textColor: Colors.black,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            })
      ],
    );
  }
}
