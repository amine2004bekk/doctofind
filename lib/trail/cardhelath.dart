import 'package:flutter/material.dart';
import 'package:flutter_application_2/antecedans/blood_type.dart';
import 'package:flutter_application_2/antecedans/chirigucal.dart';
import 'package:flutter_application_2/antecedans/famillaux.dart';
import 'package:flutter_application_2/antecedans/vacccin.dart';
import 'package:flutter_application_2/antecedans/chirigucal.dart';
class HealthProfilePage extends StatefulWidget {
  const HealthProfilePage({super.key, required String patientId});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile Health'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildCard(
                  title: 'surgeon',
                  imagePath: 'images/surgeon_5453057.png',
                  ontab: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, Animation, secondryanimation) =>
                                     ChirigualeInterface(
                                      patientUid: '',
                                    ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            }));
                    // Ajoutez votre navigation ou action ici
                    print('Surgeon card tapped');
                  },
                ),
                _buildCard(
                  title: 'blood type',
                  imagePath: 'images/blood_5310000.png',
                  ontab: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, Animation, secondryanimation) =>
                                    const BloodTypeSelector(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            }));
                  },
                ),
                _buildCard(
                  title: 'famille hestory',
                  imagePath: 'images/family_2992462.png',
                  ontab: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, Animation, secondryanimation) =>
                                    const FamillauxInterface(
                                      patientUid: '',
                                    ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            }));
                  },
                ),
                _buildCard(
                  title: 'Medical Record',
                  imagePath: 'images/medicine_17864002.png',
                  ontab: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, Animation, secondryanimation) =>
                                    const ChirigualeInterface(
                                      patientUid: '',
                                    ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            }));
                  },
                ),
                _buildCard(
                  title: 'vaccine',
                  imagePath: 'images/syringe_4667298.png',
                  ontab: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder:
                                (context, Animation, secondryanimation) =>
                                     ChirigualeInterface(
                                      patientUid: '',
                                    ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            }));
                  },
                )
                // Add more cards as needed
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String imagePath,
    required VoidCallback ontab,
    Widget? imageWidget,
  }) {
    return InkWell(
      onTap: ontab,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageWidget ??
                  Image.asset(
                    imagePath,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                  ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
