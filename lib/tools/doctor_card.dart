import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String specialty;
  final String address;
  final String imageUrl;

  final VoidCallback onCardPressed;
  final VoidCallback onAppointmentPressed;

  const DoctorCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.address,
    required this.imageUrl,
    required this.onCardPressed,
    required this.onAppointmentPressed,
  });
  onappointmentPressed() {}
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCardPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo du médecin à gauche
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Informations du médecin à droite
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge de notation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nom et prénom
                        Expanded(
                          child: Text(
                            'Dr. $firstName $lastName',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 6, vertical: 2),
                        //   decoration: BoxDecoration(
                        //     color: Colors.blue.shade700,
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: Row(
                        //     mainAxisSize: MainAxisSize.min,
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Spécialité
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Adresse
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bouton de prise de rendez-vous
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAppointmentPressed,
                        // onPressed: () {}
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size.fromHeight(36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 1,
                        ),
                        child: const Text(
                          'Make Appointment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
