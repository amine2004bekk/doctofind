import 'package:flutter/material.dart';

class BloodTypeSelector extends StatefulWidget {
  const BloodTypeSelector({super.key});

  @override
  State<BloodTypeSelector> createState() => _BloodTypeSelectorState();
}

class _BloodTypeSelectorState extends State<BloodTypeSelector> {
  String? selectedBloodType;
  
  // Liste des groupes sanguins disponibles
  final List<Map<String, String>> bloodTypes = [
    {"name": "A+", "value": "A+"},
    {"name": "A-", "value": "A-"},
    {"name": "B+", "value": "B+"},
    {"name": "B-", "value": "B-"},
    {"name": "O+", "value": "O+"},
    {"name": "O-", "value": "O-"},
    {"name": "AB+", "value": "AB+"},
    {"name": "AB-", "value": "AB-"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Type'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Blood Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input Your Blood Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Groupe A
                  _buildBloodTypeGroup('A', ['A+', 'A-']),
                  const Divider(),
                  
                  // Groupe B
                  _buildBloodTypeGroup('B', ['B+', 'B-']),
                  const Divider(),
                  
                  // Groupe O
                  _buildBloodTypeGroup('O', ['O+', 'O-']),
                  const Divider(),
                  
                  // Groupe AB
                  _buildBloodTypeGroup('AB', ['AB+', 'AB-']),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedBloodType != null 
                  ? () {
                      // Action à effectuer lors de l'enregistrement
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Blood type $selectedBloodType saved successfully!')),
                      );
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeGroup(String groupTitle, List<String> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: types.map((type) {
            return Expanded(
              child: RadioListTile<String>(
                title: Text(type),
                value: type,
                groupValue: selectedBloodType,
                onChanged: (value) {
                  setState(() {
                    selectedBloodType = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}