// ignore: file_names
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController birthplaceController = TextEditingController();

  void nextPage() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  void submitForm() {
    // Ici, tu peux envoyer les données au backend
    print("Email: ${emailController.text}");
    print("Téléphone: ${phoneController.text}");
    print("Nom: ${nameController.text}");
    print("Date de naissance: ${dobController.text}");
    print("Lieu de naissance: ${birthplaceController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Désactiver le scroll manuel
        children: [
          // Écran 1
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Téléphone"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: nextPage,
                  child: const Text("Suivant"),
                ),
              ],
            ),
          ),

          // Écran 2
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nom & Prénom"),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(labelText: "Date de naissance"),
                ),
                TextField(
                  controller: birthplaceController,
                  decoration: const InputDecoration(labelText: "Lieu de naissance"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: const Text("Enregistrer"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
