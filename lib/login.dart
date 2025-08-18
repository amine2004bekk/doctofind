import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_application_2/RDV.dart';
import 'package:flutter_application_2/homee.dart';
import 'package:flutter_application_2/screen/complite_profile.dart';
import 'package:flutter_application_2/signup.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Les contrôleurs pour les champs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Initialiser GoogleSignIn avec les bons paramètres
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Assurez-vous que votre clientId est configuré correctement dans info.plist (iOS) et google-services.json (Android)
    scopes: ['email', 'profile'],
  );

  Future<void> signInWithGoogle() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Déclencher le flux d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si l'utilisateur annule la connexion, retourner
      if (googleUser == null) {
        Navigator.pop(context); // Fermer le dialogue de chargement
        return;
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer les identifiants Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connexion à Firebase avec les identifiants
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Fermer le dialogue de chargement
      Navigator.pop(context);

      // Naviguer vers la page d'accueil si la connexion est réussie
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompliteProfile()),
        );
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      Navigator.pop(context);

      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion Google: ${e.toString()}')),
      );
      print("Erreur de connexion Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Calculer les tailles adaptatives
    final logoHeight = screenHeight * 0.2;
    final logoWidth = screenWidth * 0.4;
    final paddingVertical = screenHeight * 0.02;
    final paddingHorizontal = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Logo avec taille adaptative
              Padding(
                padding: EdgeInsets.symmetric(vertical: paddingVertical),
                child: Image.asset(
                  'images/doctofind4_croped.png',
                  height: logoHeight,
                  width: logoWidth,
                  fit: BoxFit.contain,
                ),
              ),

              Container(
                padding: EdgeInsets.all(paddingHorizontal),
                width: screenWidth,
                // Suppression de la hauteur fixe
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: Column(
                  children: [
                    Text(
                      'Log in',
                      style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(33, 150, 243, 1)),
                    ),
                    SizedBox(height: screenHeight * 0.01),

                    // Subtitle
                    Text(
                      'Welcome back! Nice to see you again',
                      style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Email TextField
                    MyTextFiled(
                      controller: emailController,
                      hint: 'E-Mail',
                      icon: Icons.email_outlined,
                      isPassword: false,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Password TextField
                    MyTextFiled(
                      controller: passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    TextButton(
                        onPressed: () async {
                          if (emailController.text.isNotEmpty) {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(
                                      email: emailController.text.trim());
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'E-mail de réinitialisation envoyé')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Erreur: ${e.toString()}')));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Veuillez entrer votre e-mail')));
                          }
                        },
                        child: const Text('forget the password?')),

                    SizedBox(height: screenHeight * 0.01),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02),
                          backgroundColor: Colors.blue,
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            // Vérifier si les champs sont vides
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Veuillez remplir tous les champs')));
                              return;
                            }

                            // Connexion avec email et mot de passe
                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );

                            // Si la connexion réussit, naviguer vers la page d'accueil
                            if (credential.user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Example()),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String errorMessage = 'Une erreur s\'est produite';

                            if (e.code == 'user-not-found') {
                              errorMessage =
                                  'Aucun utilisateur trouvé pour cet email.';
                            } else if (e.code == 'wrong-password') {
                              errorMessage = 'Mot de passe incorrect.';
                            } else if (e.code == 'invalid-email') {
                              errorMessage = 'Format d\'email invalide.';
                            }

                            // Afficher l'erreur
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMessage)));
                          } catch (e) {
                            // Afficher l'erreur générique
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Erreur: ${e.toString()}')));
                          }
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(fontSize: screenWidth * 0.05),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Séparateur "or"
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child:
                              Text("OR", style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Bouton Google
                    GestureDetector(
                      onTap: signInWithGoogle,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Image.asset(
                          "images/google.png",
                          height: screenWidth * 0.08,
                          width: screenWidth * 0.08,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Sign Up Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const Signup(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    }));
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: screenWidth * 0.035),
                          ),
                        ),
                      ],
                    ),
                    // Ajout d'un espace en bas pour éviter que le contenu ne soit coupé
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class MyTextFiled extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const MyTextFiled({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran pour adapter les tailles
    final screenWidth = MediaQuery.of(context).size.width;

    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(fontSize: screenWidth * 0.04),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: screenWidth * 0.04),
        prefixIcon: Icon(icon, size: screenWidth * 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.03, horizontal: screenWidth * 0.03),
      ),
    );
  }
}
