import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultationCard extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImageUrl;
  final DateTime consultationDate;
  final String consultationReason;
  final String roomNumber;
  final int? durationMinutes;

  const ConsultationCard({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImageUrl,
    required this.consultationDate,
    required this.consultationReason,
    required this.roomNumber,
    this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(162, 166, 169, 1).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(2, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête compact avec photo à gauche et nom à droite
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Photo du médecin (à gauche)
                CircleAvatar(
                  radius: 25,
                  backgroundImage: doctorImageUrl.isNotEmpty
                      ? NetworkImage(doctorImageUrl)
                      : null,
                  backgroundColor: Colors.blue[100],
                  child: doctorImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 25, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),

                // Nom et spécialité du médecin (à droite)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        doctorSpecialty,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ligne de séparation
          Container(
            height: 1,
            color: Colors.blue[100],
          ),

          // Contenu principal de la carte
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Motif de consultation (centré et compact)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        consultationReason,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Détails compacts en deux colonnes
                Row(
                  children: [
                    // Colonne gauche
                    Expanded(
                      child: Column(
                        children: [
                          _buildCompactDetail(
                            Icons.calendar_today,
                            DateFormat('dd/MM/yyyy').format(consultationDate),
                          ),
                          _buildCompactDetail(
                            Icons.access_time,
                            DateFormat('HH:mm').format(consultationDate),
                          ),
                        ],
                      ),
                    ),
                    // Colonne droite
                    Expanded(
                      child: Column(
                        children: [
                          _buildCompactDetail(
                            Icons.room,
                            "Room $roomNumber",
                          ),
                          if (durationMinutes != null)
                            _buildCompactDetail(
                              Icons.timer,
                              "$durationMinutes minutes",
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Boutons d'action (2 boutons)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(
              children: [
                // Bouton Reschedule
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     PageRouteBuilder(
                      //         pageBuilder:
                      //             (context, animation, secondaryAnimation) =>
                      //                 ConsultationDetailScreen(),
                      //         transitionsBuilder: (context, animation,
                      //             secondaryAnimation, child) {
                      //           return FadeTransition(
                      //             opacity: animation,
                      //             child: child,
                      //           );
                      //         }));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                    ),
                    child: const Text(
                      "Reschedule",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Bouton Annuler
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Action pour annuler la consultation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Consultation annulée")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour construire un détail compact
  Widget _buildCompactDetail(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Exemple d'utilisation de la carte
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes consultations")),
      body: SingleChildScrollView(
        child: ConsultationCard(
          doctorName: "Dr. Sophie Martin",
          doctorSpecialty: "Cardiologie",
          doctorImageUrl: "https://example.com/doctor_photo.jpg",
          consultationDate: DateTime(2025, 3, 15, 14, 30),
          consultationReason: "Consultation de suivi cardiaque",
          roomNumber: "B-204",
          durationMinutes: 30,
        ),
      ),
    );
  }
}
