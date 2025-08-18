import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultationDetailScreen extends StatelessWidget {
  final Consultation consultation;

  const ConsultationDetailScreen({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    // Formatage de la date
    String formattedDate = DateFormat('dd MMMM yyyy', 'fr_FR')
        .format(consultation.dateConsultation);
    String formattedTime =
        DateFormat('HH:mm').format(consultation.dateConsultation);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: const Text(
            'Détails de la Consultation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Informations du Médecin',
                child: _buildDoctorInfo(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Détails de Consultation',
                child: _buildConsultationDetails(formattedDate, formattedTime),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Signes Vitaux',
                child: _buildVitalSigns(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Diagnostic et Observations',
                child: _buildDiagnosisInfo(),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Documents',
                child: _buildDocumentsSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Row(
      children: [
        consultation.docteur?.imageUrl != null &&
                consultation.docteur!.imageUrl.isNotEmpty
            ? CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(consultation.docteur!.imageUrl),
              )
            : CircleAvatar(
                radius: 50,
                backgroundColor: const Color.fromARGB(255, 134, 134, 134),
                child: Icon(Icons.person, size: 50),
              ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailText(
                  'Prénom', consultation.docteur?.prenom ?? 'Non renseigné'),
              _buildDetailText(
                  'Nom', consultation.docteur?.nom ?? 'Non renseigné'),
              Text(
                consultation.docteur?.specialite ?? 'Spécialité non renseignée',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationDetails(String formattedDate, String formattedTime) {
    return Column(
      children: [
        _buildInfoRow('Date', formattedDate),
        _buildInfoRow('Heure', formattedTime),
        _buildInfoRow('Durée', '${consultation.dureeMinutes} minutes'),
        _buildInfoRow('Salle', consultation.numeroSalle),
        _buildInfoRow('Raison de Consultation', consultation.reasonForVisit),
      ],
    );
  }

  Widget _buildVitalSigns() {
    return Column(
      children: [
        _buildInfoRow('Tension artérielle', consultation.bloodPressure),
        _buildInfoRow('Taille', consultation.height),
        _buildInfoRow('Poids', consultation.weight),
        _buildInfoRow('Niveau de sucre', consultation.sugarLevel),
      ],
    );
  }

  Widget _buildDiagnosisInfo() {
    return Column(
      children: [
        _buildInfoRow('Symptômes', consultation.symptoms),
        _buildInfoRow('Diagnostic', consultation.diagnosis),
        _buildInfoRow('Notes', consultation.notes),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Logique pour afficher/ajouter des documents
        },
        icon: const Icon(Icons.document_scanner),
        label: const Text('Voir Documents'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : 'Non renseigné',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.blue[900]),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

// Cette classe n'est pas modifiée, c'est la même que dans votre code initial
class Consultation {
  final String id;
  final String idDocteur;
  final String idPatient;
  final DateTime dateConsultation;
  final String bloodPressure;
  final String diagnosis;
  final String height;
  final String weight;
  final String sugarLevel;
  final String notes;
  final String reasonForVisit;
  final String symptoms;
  final String numeroSalle;
  final int dureeMinutes;
  Docteur? docteur;

  Consultation({
    required this.id,
    required this.idDocteur,
    required this.idPatient,
    required this.dateConsultation,
    required this.bloodPressure,
    required this.diagnosis,
    required this.height,
    required this.weight,
    required this.sugarLevel,
    required this.notes,
    required this.reasonForVisit,
    required this.symptoms,
    required this.numeroSalle,
    required this.dureeMinutes,
    this.docteur,
  });
}

// Cette classe n'est pas modifiée, c'est la même que dans votre code initial
class Docteur {
  final String id;
  final String prenom;
  final String nom;
  final String specialite;
  final String imageUrl;

  Docteur({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.specialite,
    required this.imageUrl,
  });

  String get nomComplet => '$prenom $nom';
}
