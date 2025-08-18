import 'package:flutter/material.dart';
import 'package:flutter_application_2/screen/appontment_details.dart';
import 'package:flutter_application_2/screen/canceldRDV.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String speciality;
  final String date;
  final String staRT_DATE;

  final VoidCallback? onCardTap;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.speciality,
    required this.date,
    required this.staRT_DATE,
    required this.onCardTap,
    required String timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onCardTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(
            //   color: Colors.grey,
            //   width: 1,
            // ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: Colors.grey,
                      //   width: 1,
                      // ),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color.fromARGB(255, 225, 241, 255),
                      child: Icon(Icons.person,
                          color: Color.fromARGB(255, 25, 118, 210), size: 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. $doctorName',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          speciality,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.present_to_all,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  // color: Colors.blue[700],
                  border: Border.all(
                    color: Colors.blue[700]!,
                    width: 1,
                  ),
                  color: const Color.fromARGB(255, 225, 241, 255),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color.fromARGB(255, 25, 118, 210),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 25, 118, 210),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Color.fromARGB(255, 25, 118, 210),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          staRT_DATE,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 25, 118, 210),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
