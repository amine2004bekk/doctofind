import 'package:flutter/material.dart';
import 'package:flutter_application_2/appwraper.dart';

import 'package:flutter_application_2/firebase_options.dart';

// import 'package:flutter_application_1/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/homee.dart';
import 'package:flutter_application_2/login.dart';
import 'package:flutter_application_2/video_call/video_call_provider.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ignore: non_constant_identifier_names
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('++++++++++++++++User is currently signed out!');
      } else {
        print('===================User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          // Provide the Firebase User reactively
          StreamProvider<User?>.value(
            value: FirebaseAuth.instance.authStateChanges(),
            initialData: null,
          ),

          // Provide the PatientVideoCallProvider with fallback to 'guest'
          ChangeNotifierProxyProvider<User?, PatientVideoCallProvider>(
            create: (_) => PatientVideoCallProvider(patientId: 'guest'),
            update: (_, user, __) =>
                PatientVideoCallProvider(patientId: user?.uid ?? 'guest'),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Cabinet Médical',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          builder: (context, child) {
            return Scaffold(body: AppWrapper(child: child!));
          },
          home: FirebaseAuth.instance.currentUser == null
              ? const Login()
              : const AppWrapper(child: Example()),
        ));
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil - Cabinet Médical'),
      ),
      body: const Center(
        child: Text(
          'Bienvenue dans le Cabinet Médical',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigator.push(context, Login());
          // Action à définir
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
