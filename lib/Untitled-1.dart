import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentTimeSelectionScreen extends StatefulWidget {
  final String doctorId;
  final String appointmentType; // "Video Call" ou "In Person"
  final String duration; // durée sélectionnée ("15 minute" ou "30 minute")

  const AppointmentTimeSelectionScreen({
    Key? key,
    required this.doctorId,
    required this.appointmentType,
    required this.duration,
  }) : super(key: key);

  @override
  State<AppointmentTimeSelectionScreen> createState() =>
      _AppointmentTimeSelectionScreenState();
}

class _AppointmentTimeSelectionScreenState
    extends State<AppointmentTimeSelectionScreen> {
  DateTime selectedDate = DateTime.now();
  List<String> availableHours = [];
  List<String> bookedHours = [];
  String? selectedTime;
  bool isLoading = true;
  bool isWorkingDay = true;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Variables pour les rendez-vous du patient
  List<Map<String, dynamic>> patientAppointments = [];
  String? patientId;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    _getCurrentPatientId();
  }

  // Obtenir l'ID du patient actuel
  Future<void> _getCurrentPatientId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        patientId = user.uid;
      } else {
        // Pour les tests, utilisez un ID fixe si l'authentification n'est pas configurée
        patientId = "test_patient_id";
      }

      // Une fois l'ID du patient obtenu, on charge les données
      fetchDoctorAvailability();
      fetchPatientAppointments();
    } catch (e) {
      print('Erreur lors de la récupération de l\'ID patient: $e');
    }
  }

  // Récupérer les rendez-vous existants du patient
  Future<void> fetchPatientAppointments() async {
    if (patientId == null) return;

    try {
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .orderBy('date', descending: false)
          .get();

      List<Map<String, dynamic>> appointments = [];
      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data();
        appointments.add({
          'id': doc.id,
          'doctorId': data['doctorId'],
          'date': data['date'],
          'time': data['time'],
          'type': data['type'] ?? 'N/A',
          'status': data['status'] ?? 'pending',
        });
      }

      setState(() {
        patientAppointments = appointments;
      });
    } catch (e) {
      print('Erreur lors de la récupération des rendez-vous du patient: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
        isLoading = true;
        selectedTime = null;
      });
      fetchDoctorAvailability();
    }
  }

  Future<void> fetchDoctorAvailability() async {
    try {
      // Récupérer les jours et heures de travail du docteur
      final doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      final availabilityRef = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .collection('availability')
          .get();

      if (!doctorDoc.exists || availabilityRef.docs.isEmpty) {
        setState(() {
          isLoading = false;
          isWorkingDay = false;
        });
        return;
      }

      final availabilityData = availabilityRef.docs.first.data();
      final workingDays =
          List<String>.from(availabilityData['working_days'] ?? []);

      // Vérifier si le jour sélectionné est un jour de travail
      String dayName = DateFormat('EEEE').format(selectedDate).toLowerCase();
      if (!workingDays.contains(dayName)) {
        setState(() {
          isLoading = false;
          isWorkingDay = false;
        });
        return;
      }

      // Générer les créneaux horaires selon l'heure de début, de fin et la durée
      String startTimeStr = availabilityData['start_time'] ?? "08:00";
      String endTimeStr = availabilityData['end_time'] ?? "16:00";

      // Utiliser la durée sélectionnée par l'utilisateur (convertir en minutes)
      int duration = int.parse(widget.duration.split(' ')[0]);

      List<String> slots =
          generateTimeSlots(startTimeStr, endTimeStr, duration);

      // Récupérer les rendez-vous déjà pris pour ce médecin à cette date
      String dateFormatted = DateFormat('yyyy-MM-dd').format(selectedDate);
      final appointmentsRef = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: widget.doctorId)
          .where('date', isEqualTo: dateFormatted)
          .get();

      List<String> booked = [];
      for (var doc in appointmentsRef.docs) {
        booked.add(doc['time']);
      }

      setState(() {
        availableHours = slots;
        bookedHours = booked;
        isLoading = false;
        isWorkingDay = true;
      });
    } catch (e) {
      print(
          'Erreur lors de la récupération de la disponibilité du médecin: $e');
      setState(() {
        isLoading = false;
        isWorkingDay = false;
      });
    }
  }

  List<String> generateTimeSlots(
      String startTime, String endTime, int durationMinutes) {
    List<String> slots = [];

    // Parser les heures de début et de fin
    List<String> startParts = startTime.split(':');
    List<String> endParts = endTime.split(':');

    DateTime start = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, int.parse(startParts[0]), int.parse(startParts[1]));

    DateTime end = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, int.parse(endParts[0]), int.parse(endParts[1]));

    // Générer les créneaux
    DateTime current = start;
    while (current.isBefore(end)) {
      slots.add(DateFormat('HH:mm').format(current));
      current = current.add(Duration(minutes: durationMinutes));
    }

    return slots;
  }

  Future<void> saveAppointment() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez sélectionner une heure de rendez-vous')));
      return;
    }

    if (reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez entrer une raison pour la visite')));
      return;
    }

    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur d\'identification du patient')));
      return;
    }

    try {
      // Formater la date pour Firestore
      String dateFormatted = DateFormat('yyyy-MM-dd').format(selectedDate);

      // Extraire seulement la durée en minutes
      String durationMinutes = widget.duration.split(' ')[0];

      // Enregistrer le rendez-vous dans Firestore
      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': widget.doctorId,
        'patientId': patientId,
        'date': dateFormatted,
        'time': selectedTime,
        'reason': reasonController.text,
        'type': widget.appointmentType, // Type de RDV (Video Call ou In Person)
        'duration': durationMinutes, // Durée en minutes
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Naviguer vers l'écran de succès
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccesScreen(
            image: 'images/doctor.jpg',
            title: 'Rendez-vous Réservé',
            subtitle: 'Votre rendez-vous a été programmé avec succès',
            onPressed: () {
              // Naviguer vers l'accueil ou un autre écran
              // Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de la réservation du rendez-vous: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sélectionner l\'heure',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête d'information pour le type de rendez-vous
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.appointmentType == "online"
                        ? Icons.videocam
                        : Icons.person,
                    color: Colors.blue,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appointmentType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Durée: ${widget.duration}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Sélectionner Date et Heure',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Champ de sélection de date
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Sélectionner une date',
                suffixIcon: const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () => _selectDate(context),
            ),

            const SizedBox(height: 24),
            const Text(
              'Créneaux Disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Affichage des créneaux horaires ou message
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !isWorkingDay
                      ? const Center(
                          child: Text(
                            'Le médecin n\'est pas disponible ce jour. Veuillez sélectionner une autre date.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        )
                      : availableHours.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun créneau disponible pour cette date.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: availableHours.length,
                              itemBuilder: (context, index) {
                                final timeSlot = availableHours[index];
                                final isBooked = bookedHours.contains(timeSlot);
                                final isSelected = selectedTime == timeSlot;

                                return InkWell(
                                  onTap: isBooked
                                      ? null
                                      : () {
                                          setState(() {
                                            selectedTime = timeSlot;
                                          });
                                        },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue
                                          : isBooked
                                              ? Colors.grey.shade200
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : isBooked
                                                ? Colors.red
                                                : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        timeSlot,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : isBooked
                                                  ? Colors.red
                                                  : Colors.black,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            // Champ de raison de la visite
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Raison de la visite',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Bouton de réservation
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading || !isWorkingDay ? null : saveAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text(
                  'Réserver le Rendez-vous',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe fictive pour éviter les erreurs - remplacez par votre SuccesScreen réelle
class SuccesScreen extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const SuccesScreen({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 200),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(subtitle),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
