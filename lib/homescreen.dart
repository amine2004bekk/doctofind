import 'package:flutter/material.dart';
// import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_2/RDV.dart';
import 'package:flutter_application_2/getstart.dart';
import 'package:flutter_application_2/home2.dart';
import 'package:flutter_application_2/my%20profile.dart';

import 'package:flutter_application_2/homee.dart';
// import 'package:flutter_application_2/settingprofile.dart';

// import 'package:flutter_application_1/getstart.dart';

// ignore: camel_case_types
class wananpage extends StatefulWidget {
  const wananpage({super.key});

  @override
  State<wananpage> createState() => _PageState();
}

List<Widget> liste = [
  const HomeScreen(),
  const Example(),
  const Rdv(),
  const Getstart(),
  const MonCompte(),
];

class _PageState extends State<wananpage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 25,
        backgroundColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'consultation',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
            backgroundColor: Colors.blue,
          ),
        ],
      ),
      body: Container(
        child: liste.elementAt(_selectedIndex),
      ),
    );
  }
}
