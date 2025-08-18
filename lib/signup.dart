import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/back-end/add.dart';
import 'package:flutter_application_2/custom_button.dart';
import 'package:flutter_application_2/homee.dart';
import 'package:flutter_application_2/homescreen.dart';
import 'package:flutter_application_2/screen/complite_profile.dart';
import 'package:flutter_application_2/settingprofile.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Changed to StatefulWidget to manage state and password visibility
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController firstNameController =
      TextEditingController(); // Added
  final TextEditingController lastNameController =
      TextEditingController(); // Added
  final TextEditingController phoneController =
      TextEditingController(); // Added
  CollectionReference patient =
      FirebaseFirestore.instance.collection('patient');

  void getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      print("ID de l'utilisateur : $userId");

      // Tu peux maintenant utiliser `userId` dans ton rapport ou pour des requêtes Firestore
    } else {
      print("Aucun utilisateur connecté.");
    }
  }

  Future<void> addUser1() async {
    // Get the current user ID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Aucun utilisateur connecté.");
      return;
    }

    String userId = user.uid;

    // Use the document with ID equal to user's UID instead of auto-generated ID
    return patient
        .doc(userId) // Use userId as document ID
        .set({
          'patientId': userId, // Store user ID in the document
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'createdAt': FieldValue.serverTimestamp(),
        })
        .then((value) => print("User Added with ID: $userId"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  // Added to manage password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Center(
                child: Image.asset(
                  height: 200,
                  width: 220,
                  'images/personal-doctor-appointment-2d-isolated-illustration-vector-removebg-preview.png',
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Let's create your account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              // Removed PageView and replaced with a single column
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyTextField(
                          hint: 'First Name',
                          icon: Icons.person_outline,
                          isPassword: false,
                          controller: firstNameController, // Added controller
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyTextField(
                          hint: 'Last Name',
                          icon: Icons.person_outline,
                          isPassword: false,
                          controller: lastNameController, // Added controller
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    keyboardType: TextInputType.emailAddress,
                    hint: 'E-Mail',
                    icon: Icons.email_outlined,
                    isPassword: false,
                    controller: emailController,
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    keyboardType: TextInputType.phone,
                    hint: 'Phone',
                    icon: Icons.phone_android,
                    isPassword: false,
                    controller: phoneController, // Added controller
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword:
                        !_isPasswordVisible, // Dynamic password visibility
                    controller: passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    hint: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword:
                        !_isConfirmPasswordVisible, // Dynamic password visibility
                    controller: confirmPasswordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Mybutton(
                      text: 'Create Account',
                      bgColor: Colors.blue,
                      textColor: Colors.white,
                      isOutlined: false,
                      onPressed: _createAccount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createAccount() async {
    // More comprehensive validation
    if (_validateInputs()) {
      try {
        // Create Firebase authentication user first
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // After successful authentication, add user data to Firestore
        await addUser1();

        // Navigate to complete profile screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompliteProfile()),
        );
      } on FirebaseAuthException catch (e) {
        // More detailed error handling
        _showErrorSnackBar(e.message ?? 'An unknown error occurred.');
      }
    }
  }

  bool _validateInputs() {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields.');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match.');
      return false;
    }

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      _showErrorSnackBar('Please enter a valid email address.');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon; // Added optional suffix icon

  const MyTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.isPassword,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon, // Added suffix icon support
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 41, 92, 201),
            width: 1,
          ),
        ),
      ),
    );
  }
}
