import 'package:flutter/material.dart';
import 'package:flutter_application_2/RDV.dart';
// import 'package:flutter_application_2/getstart.dart';
import 'package:flutter_application_2/home2.dart';
import 'package:flutter_application_2/my%20profile.dart';
import 'package:flutter_application_2/screen/consultation%20.dart';
// import 'package:flutter_application_2/trail/bokking.dart';
import 'package:flutter_application_2/trail/explore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const DoctorListScreen(),
    const Rdv(),
    const ConsultationsScreen(),
    const MonCompte(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Expanded(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Flexible(
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 6,
                activeColor: Colors.blue,
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: const Color.fromARGB(255, 245, 245, 245),
                color: Colors.black,
                tabs: const [
                  GButton(
                    icon: LineIcons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: LineIcons.compass,
                    text: 'exolore',
                  ),
                  GButton(
                    icon: LineIcons.calendarAlt,
                    text: 'appointment',
                  ),
                  GButton(
                    icon: LineIcons.book,
                    text: 'consultation',
                  ),
                  GButton(
                    icon: LineIcons.user,
                    text: 'Profile',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
