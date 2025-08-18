import 'package:flutter/material.dart';



class MedicalHistoryForm extends StatefulWidget {
  const MedicalHistoryForm({super.key});

  @override
  _MedicalHistoryFormState createState() => _MedicalHistoryFormState();
}

class _MedicalHistoryFormState extends State<MedicalHistoryForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController chronicDiseasesController = TextEditingController();
  TextEditingController familyHistoryController = TextEditingController();
  TextEditingController surgeriesController = TextEditingController();
  TextEditingController allergiesController = TextEditingController();
  TextEditingController vaccinationsController = TextEditingController();

  void _saveData() {
    if (_formKey.currentState!.validate()) {
      // Simuler une sauvegarde des données
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dossier médical sauvegardé !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dossier Médical - Antécédents')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(chronicDiseasesController, 'Maladies Chroniques'),
              _buildTextField(familyHistoryController, 'Antécédents Familiaux'),
              _buildTextField(surgeriesController, 'Chirurgies Passées'),
              _buildTextField(allergiesController, 'Allergies'),
              _buildTextField(vaccinationsController, 'Vaccinations'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez remplir ce champ';
          }
          return null;
        },
      ),
    );
  }
}
