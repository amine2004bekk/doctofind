import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/screen/secces_screen.dart';
import 'package:intl/intl.dart';

class AppointmentTimeSelectionScreen extends StatefulWidget {
  final String doctorId;

  const AppointmentTimeSelectionScreen({
    Key? key,
    required this.doctorId,
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
  List<String> cancelledHours = []; // Nouvelle liste pour les heures annulées
  String? selectedTime;
  bool isLoading = true;
  bool isWorkingDay = true;
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String appointmentType = 'in person'; // Valeur par défaut
  String? patientId;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    getCurrentPatientId();
    fetchDoctorAvailability();
  }

  Future<void> getCurrentPatientId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          patientId = user.uid;
        });
      } else {
        // Pour les tests, utilisez un ID fixe si l'authentification n'est pas configurée
        setState(() {
          patientId = "wPAwyqYOFELwyhFTsO9Q";
        });
      }
    } catch (e) {
      print('Error fetching patient ID: $e');
      // Définir un ID par défaut pour continuer même en cas d'erreur
      setState(() {
        patientId = "wPAwyqYOFELwyhFTsO9Q";
      });
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

  void fetchDoctorAvailability() {
    setState(() {
      isLoading = true;
    });

    try {
      // Get doctor's working days and hours (one-time fetch)
      FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get()
          .then((doctorDoc) {
        if (!doctorDoc.exists) {
          setState(() {
            isLoading = false;
            isWorkingDay = false;
          });
          return;
        }

        // Listen to availability in real time
        FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .collection('availability')
            .limit(1) // Ensure we don't hit the limit
            .snapshots()
            .listen((availabilitySnapshot) {
          if (availabilitySnapshot.docs.isEmpty) {
            setState(() {
              isLoading = false;
              isWorkingDay = false;
            });
            return;
          }

          final availabilityData = availabilitySnapshot.docs.first.data();
          final workingDays =
              List<String>.from(availabilityData['working_days'] ?? []);

          // Check if selected day is a working day
          String dayName =
              DateFormat('EEEE').format(selectedDate).toLowerCase();
          if (!workingDays.contains(dayName)) {
            setState(() {
              isLoading = false;
              isWorkingDay = false;
            });
            return;
          }

          // Generate time slots based on start time, end time and duration
          String startTimeStr = availabilityData['start_time'] ?? "08:00";
          String endTimeStr = availabilityData['end_time'] ?? "16:00";
          int duration = availabilityData['duration'] ?? 30;

          List<String> slots =
              generateTimeSlots(startTimeStr, endTimeStr, duration);

          // Filter out slots that are in the past
          DateTime now = DateTime.now();
          slots = slots.where((timeSlot) {
            // Parse the time string into just hour and minute
            DateTime parsedTime = DateFormat('HH:mm').parse(timeSlot);
            // Create a new DateTime with the selected date's year, month, day and the parsed time
            DateTime slotDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            // Keep only slots that are in the future
            return slotDateTime.isAfter(now);
          }).toList();

          // Update available hours first
          setState(() {
            availableHours = slots;
            isWorkingDay = true;
          });

          // Listen to appointments in real time
          String dateFormatted = DateFormat('dd-MM-yyyy').format(selectedDate);
          FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: widget.doctorId)
              .where('date', isEqualTo: dateFormatted)
              .snapshots()
              .listen((appointmentsSnapshot) {
            List<String> booked = [];
            List<String> cancelled = [];

            for (var doc in appointmentsSnapshot.docs) {
              if (doc['status'] == 'booked') {
                booked.add(doc['time']);
              } else if (doc['status'] == 'cancelled') {
                cancelled.add(doc['time']);
              }
            }

            print('-------------------------------------------------------------------' +
                booked.toString() +
                '-------------------------------------------------------------------');

            if (mounted) {
              setState(() {
                bookedHours = booked;
                print('Booked hours: $bookedHours');
                cancelledHours = cancelled;
                isLoading = false;
              });
            }
          }, onError: (e) {
            print('Error listening to appointments: $e');
            setState(() {
              isLoading = false;
            });
          });
        }, onError: (e) {
          print('Error listening to availability: $e');
          setState(() {
            isLoading = false;
            isWorkingDay = false;
          });
        });
      }).catchError((e) {
        print('Error fetching doctor document: $e');
        setState(() {
          isLoading = false;
          isWorkingDay = false;
        });
      });
    } catch (e) {
      print('Error setting up doctor availability listeners: $e');
      setState(() {
        isLoading = false;
        isWorkingDay = false;
      });
    }
  }

  List<String> generateTimeSlots(
      String startTime, String endTime, int durationMinutes) {
    List<String> slots = [];

    // Parse start and end times
    List<String> startParts = startTime.split(':');
    List<String> endParts = endTime.split(':');

    DateTime start = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, int.parse(startParts[0]), int.parse(startParts[1]));

    DateTime end = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, int.parse(endParts[0]), int.parse(endParts[1]));

    // Generate slots
    DateTime current = start;
    while (current.isBefore(end)) {
      slots.add(DateFormat('HH:mm').format(current));
      current = current.add(Duration(minutes: durationMinutes));
    }

    return slots;
  }

  Future<void> saveAppointment() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot')));
      return;
    }

    if (reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please provide a reason for the appointment')));
      return;
    }

    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('error: patient ID not found')));
      return;
    }

    try {
      // Format date for Firestore - format "dd-MM-yyyy" comme dans votre capture d'écran
      String dateFormatted = DateFormat('dd-MM-yyyy').format(selectedDate);

      // Formatage du temps - format "HH:mm" entouré de guillemets
      String formattedTime = '"${selectedTime!}"';

      // Create appointment document avec le format exact de votre Firestore
      await FirebaseFirestore.instance.collection('appointments').add({
        'date': dateFormatted,
        'doctorId': widget.doctorId,
        'patientId': patientId,
        'reason': reasonController.text,
        'status': 'booked',
        'time': selectedTime,
        'type': appointmentType,
      });

      // Navigate to success screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccesScreen(
            image: 'images/doctor.jpg',
            title: 'Appointment Confirmed',
            subtitle: 'Your appointment has been successfully booked.',
            onPressed: () {
              // Navigate to home or other screen
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error in reserving : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
            'Select Appointment Time',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a date and time ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Date selection field
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select a date',
                    suffixIcon:
                        const Icon(Icons.calendar_today, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Available Time Slots',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // GridView intégrée avec shrinkWrap
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !isWorkingDay
                        ? const Center(
                            child: Text(
                              'The doctor is not available on this date.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          )
                        : availableHours.isEmpty
                            ? const Center(
                                child: Text(
                                  'No available time slots for this date.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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
                                  final isBooked =
                                      bookedHours.contains(timeSlot);
                                  final isCancelled =
                                      cancelledHours.contains(timeSlot);
                                  final isSelected = selectedTime == timeSlot;

                                  return InkWell(
                                    onTap: isBooked && !isCancelled
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
                                            : isBooked && !isCancelled
                                                ? const Color.fromARGB(
                                                    255, 232, 172, 172)
                                                : isCancelled
                                                    ? Colors.white
                                                    : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blue
                                              : isBooked && !isCancelled
                                                  ? Colors.red
                                                  : isCancelled
                                                      ? const Color.fromARGB(
                                                          255, 222, 219, 219)
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
                                                : isBooked && !isCancelled
                                                    ? Colors.red
                                                    : isCancelled
                                                        ? const Color.fromARGB(
                                                            255, 41, 35, 35)
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

                const SizedBox(height: 16),
                const Text(
                  'Consultation Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        fillColor: MaterialStateProperty.all(Colors.blue),
                        activeColor: Colors.blue,
                        title: const Text('In Person'),
                        value: 'in person',
                        groupValue: appointmentType,
                        onChanged: (value) {
                          setState(() {
                            appointmentType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Video Call'),
                        value: 'online',
                        groupValue: appointmentType,
                        onChanged: (value) {
                          setState(() {
                            appointmentType = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Consultation reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        isLoading || !isWorkingDay ? null : saveAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Book Appointment',
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
        ));
  }
}
