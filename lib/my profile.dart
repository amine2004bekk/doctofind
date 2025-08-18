import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/1255.dart';
import 'package:flutter_application_2/antecedans/alergie.dart';
import 'package:flutter_application_2/antecedans/blood_type.dart';
import 'package:flutter_application_2/antecedans/chirigucal.dart';
import 'package:flutter_application_2/healthprofile.dart';
import 'package:flutter_application_2/login.dart';
import 'package:flutter_application_2/screen/medical__peofile1.dart';
import 'package:flutter_application_2/screen/modifieprofile.dart';
import 'package:flutter_application_2/screen/verefiy_email.dart';
import 'package:flutter_application_2/tools/alertdialog.dart';
import 'package:flutter_application_2/tools/new_interface_antec.dart';

import 'package:flutter_application_2/trail/cardhelath.dart';

class MonCompte extends StatefulWidget {
  const MonCompte({super.key});

  @override
  State<MonCompte> createState() => _MonCompteState();
}

class _MonCompteState extends State<MonCompte> {
  String patientId = '';
  String first_name = '';
  String last_name = '';
  String email = '';
  String phoneNumber = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('patient')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            // Use the exact field names as shown in your Firestore document
            patientId = userData.get('patientId') ?? '';
            first_name = userData.get('first_name') ?? '';
            last_name = userData.get('last_name') ?? '';
            email = user.email ?? ''; // Get email from Firebase Auth
            phoneNumber = userData.get('phone') ?? '';
            isLoading = false;
          });
        } else {
          // If document doesn't exist, try to get email from Firebase Auth
          setState(() {
            email = user.email ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue, // couleur de fond
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                'profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security Banner
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, color: Colors.blue.shade700, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your health. Your data.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Respecting the confidentiality of your data is our absolute priority.',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Discover our commitments',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Identity Section
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Identity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  // Profile Item
                  ListTile(
                    leading:
                        const Icon(Icons.person, color: Colors.blue, size: 30),
                    title: const Text('My profile'),
                    subtitle: Text('$first_name $last_name'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileEditScreen()),
                      ).then((_) =>
                          fetchUserData()); // Refresh data when returning
                    },
                  ),

                  // Relatives Item
                  ListTile(
                    leading:
                        const Icon(Icons.people, color: Colors.blue, size: 30),
                    title: const Text('health profile'),
                    subtitle: const Text('Add and manage your health profiles'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder:
                                  (context, Animation, secondryanimation) =>
                                      HealthProfile(patientId: patientId),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              }));
                    },
                  ),

                  const Divider(height: 32),

                  // Connection Section
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Connection',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  // Phone Item
                  ListTile(
                    leading:
                        const Icon(Icons.phone, color: Colors.blue, size: 30),
                    title: const Text('Phone'),
                    subtitle: Text('$phoneNumber'),
                    trailing: const Icon(Icons.chevron_right),
                  ),

                  // Email Item
                  ListTile(
                    leading:
                        const Icon(Icons.email, color: Colors.blue, size: 30),
                    title: const Text('Email'),
                    subtitle: Text(email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FirebaseAuth.instance.currentUser!.emailVerified
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(149, 214, 151, 1),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Color.fromARGB(255, 31, 116, 75),
                                        size: 16),
                                    SizedBox(width: 4),
                                    Text(' verified',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 31, 116, 75))),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning,
                                        color: Colors.orange, size: 16),
                                    SizedBox(width: 4),
                                    Text('Not verified',
                                        style: TextStyle(color: Colors.orange)),
                                  ],
                                ),
                              ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VerifyEmailScreen()),
                      );
                    },
                  ),

                  // Password Item
                  // ListTile(
                  //   leading:
                  //       const Icon(Icons.lock, color: Colors.blue, size: 30),
                  //   title: const Text('Password'),
                  //   subtitle: const Text('••••••••••••••'),
                  //   trailing: const Icon(Icons.chevron_right),
                  //   onTap: () {},
                  // ),
                  ListTile(
                      trailing: const Icon(Icons.chevron_right),
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                      ),
                      title: const Text('log out',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      onTap: () async {
                        CustomAlertDialog.show(
                          context: context,
                          title: '  logout',
                          content: 'really you went to log out? ',
                          icon: Icons.login_outlined,
                          iconColor: Colors.red,
                          cancelText: 'Non',
                          confirmText: 'Oui',
                          confirmButtonColor: Colors.blue,
                          onConfirm: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Login()));
                          },
                        );
                      })
                ],
              ),
            ),
    );
  }
}
