import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FamillauxInterface extends StatefulWidget {
  final String patientUid; // UID du patient
  
  const FamillauxInterface({
    super.key, 
    required this.patientUid
  });

  @override
  _FamillauxInterfaceState createState() => _FamillauxInterfaceState();
}

class _FamillauxInterfaceState extends State<FamillauxInterface> {
  // Définition des contrôleurs pour les champs de texte
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool isLoading = false;

  // Variables pour les checkboxes
  Map<String, bool> familyMembers = {
    'Mère': false,
    'Père': false,
    'Frères': false,
    'Sœurs': false,
    'Enfants': false,
    'Grands-parents maternels': false,
    'Grands-parents paternels': false,
    'Oncles': false,
    'Tantes': false,
    'Cousins/Cousines': false,
    'Neveux/Nièces': false,
  };

  @override
  void dispose() {
    // Libérer les ressources lors de la destruction du widget
    titleController.dispose();
    dateController.dispose();
    super.dispose();
  }
  
  // Fonction pour ajouter les données à Firestore
  Future<void> addFamilialData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Référence à la sous-collection du patient
      final familialRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientUid)
        .collection('familial');
      
      // Filtrer les membres de famille sélectionnés
      Map<String, bool> selectedMembers = {};
      familyMembers.forEach((key, value) {
        if (value) {
          selectedMembers[key] = true;
        }
      });
      
      // Ajout des données à Firestore
      await familialRef.add({
        'title': titleController.text,
        'date': dateController.text,
        'family_members': selectedMembers,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Réinitialisation des champs
      titleController.clear();
      dateController.clear();
      setState(() {
        familyMembers.updateAll((key, value) => false);
      });
      
      // Affichage d'un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Family history record added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Gestion des erreurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Antécédents Familiaux'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 120, // Ajusté pour tenir compte de l'AppBar
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add your family medical history',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Entrez la description de l\'antécédent',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Sélectionnez les membres de famille concernés:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildCheckboxList(),
                      const SizedBox(height: 25),
                      const Text(
                        'Date de diagnostic',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: dateController,
                        decoration: InputDecoration(
                          hintText: 'JJ/MM/AAAA',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : addFamilialData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'SAVE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
      ),
    );
  }
  
  Widget _buildCheckboxList() {
    return Column(
      children: familyMembers.entries.map((entry) {
        return CheckboxListTile(
          title: Text(
            entry.key,
            style: const TextStyle(fontSize: 16),
          ),
          value: entry.value,
          activeColor: Colors.blue,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[entry.key] = value ?? false;
            });
          },
        );
      }).toList(),
    );
  }
}