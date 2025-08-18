import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Modèle pour représenter un docteur
class Docteur {
  final String id;
  final String nom;
  final String specialite;
  // Ajoutez d'autres champs selon votre structure de données

  Docteur({
    required this.id,
    required this.nom,
    required this.specialite,
  });

  factory Docteur.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Docteur(
      id: doc.id,
      nom: data['nom'] ?? '',
      specialite: data['specialite'] ?? '',
      // Initialisez d'autres champs ici
    );
  }
}

// Modèle pour représenter une consultation
class Consultation {
  final String id;
  final String idDocteur;
  final DateTime dateConsultation;
  final String description;
  Docteur? docteur;
  // Ajoutez d'autres champs selon votre structure de données

  Consultation({
    required this.id,
    required this.idDocteur,
    required this.dateConsultation,
    required this.description,
    this.docteur,
  });

  factory Consultation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Consultation(
      id: doc.id,
      idDocteur: data['id_docteur'] ?? '',
      dateConsultation: (data['date_consultation'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      // Initialisez d'autres champs ici
    );
  }
}

// Service pour gérer les opérations Firebase
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer toutes les consultations avec les informations des docteurs
  Future<List<Consultation>> getConsultationsWithDoctorInfo() async {
    try {
      // Récupérer toutes les consultations
      QuerySnapshot consultationSnapshot = await _firestore.collection('consultations').get();
      
      List<Consultation> consultations = [];
      
      for (var doc in consultationSnapshot.docs) {
        Consultation consultation = Consultation.fromFirestore(doc);
        
        // Récupérer les informations du docteur si l'ID existe
        if (consultation.idDocteur.isNotEmpty) {
          DocumentSnapshot docteurDoc = await _firestore
              .collection('docteurs')
              .doc(consultation.idDocteur)
              .get();
          
          if (docteurDoc.exists) {
            consultation.docteur = Docteur.fromFirestore(docteurDoc);
          }
        }
        
        consultations.add(consultation);
      }
      
      return consultations;
    } catch (e) {
      print('Erreur lors de la récupération des consultations: $e');
      rethrow;
    }
  }

  // Récupérer les consultations d'un docteur spécifique
  Future<List<Consultation>> getConsultationsByDoctorId(String doctorId) async {
    try {
      // Récupérer les consultations filtrées par ID de docteur
      QuerySnapshot consultationSnapshot = await _firestore
          .collection('consultations')
          .where('id_docteur', isEqualTo: doctorId)
          .get();
      
      List<Consultation> consultations = [];
      
      // Récupérer les informations du docteur une seule fois
      DocumentSnapshot docteurDoc = await _firestore
          .collection('docteurs')
          .doc(doctorId)
          .get();
      
      Docteur? docteur;
      if (docteurDoc.exists) {
        docteur = Docteur.fromFirestore(docteurDoc);
      }
      
      // Créer des objets Consultation avec les informations du docteur
      for (var doc in consultationSnapshot.docs) {
        Consultation consultation = Consultation.fromFirestore(doc);
        consultation.docteur = docteur;
        consultations.add(consultation);
      }
      
      return consultations;
    } catch (e) {
      print('Erreur lors de la récupération des consultations par docteur: $e');
      rethrow;
    }
  }
}

// Widget principal pour afficher la liste des consultations
class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  _ConsultationsScreenState createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Consultation> _consultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultations();
  }

  Future<void> _loadConsultations() async {
    try {
      List<Consultation> consultations = await _firebaseService.getConsultationsWithDoctorInfo();
      setState(() {
        _consultations = consultations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  // Fonction pour charger les consultations d'un docteur spécifique
  Future<void> _loadConsultationsByDoctor(String doctorId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<Consultation> consultations = await _firebaseService.getConsultationsByDoctorId(doctorId);
      setState(() {
        _consultations = consultations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _consultations.isEmpty
              ? const Center(child: Text('Aucune consultation trouvée'))
              : ListView.builder(
                  itemCount: _consultations.length,
                  itemBuilder: (context, index) {
                    Consultation consultation = _consultations[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Date: ${consultation.dateConsultation.toString().substring(0, 16)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${consultation.description}'),
                            if (consultation.docteur != null)
                              Text('Docteur: ${consultation.docteur!.nom} (${consultation.docteur!.specialite})'),
                            if (consultation.docteur == null)
                              const Text('Docteur: Information non disponible'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadConsultations,
        tooltip: 'Rafraîchir',
        child: Icon(Icons.refresh),
      ),
    );
  }
}

// Configuration et exécution de l'application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Consultations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConsultationsScreen(),
    );
  }
}