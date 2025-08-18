import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChirigualeInterface extends StatefulWidget {
  final String patientUid; // UID du patient

  const ChirigualeInterface({super.key, required this.patientUid});

  @override
  _ChirigualeInterfaceState createState() => _ChirigualeInterfaceState();
}

class _ChirigualeInterfaceState extends State<ChirigualeInterface> {
  // Définition des contrôleurs pour les champs de texte
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    // Libérer les ressources lors de la destruction du widget
    titleController.dispose();
    dateController.dispose();
    super.dispose();
  }

  // Fonction pour ajouter les données à Firestore
  Future<void> addChirurgicalData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Référence à la sous-collection du patient
      final chirurgicalRef = FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patientUid)
          .collection('vaccin');

      // Ajout des données à Firestore
      await chirurgicalRef.add({
        'title': titleController.text,
        'date': dateController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Réinitialisation des champs
      titleController.clear();
      dateController.clear();

      // Affichage d'un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surgical record added successfully'),
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
        title: const Text('Chiriguale'),
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
                      'Add your surgical medical record',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'chirugecal',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Entrez le chirugecal',
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
                      'Entre la Date',
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
                        onPressed: isLoading ? null : addChirurgicalData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
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
    );
  }
}
