import 'package:flutter/material.dart';
import 'package:flutter_application_2/trail/explore.dart';

class SpecialtyCategory {
  final String name;
  final String imagePath;

  SpecialtyCategory({required this.name, required this.imagePath});
}

class SeeAllSpeciality extends StatefulWidget {
  @override
  _SeeAllSpecialityState createState() => _SeeAllSpecialityState();
}

class _SeeAllSpecialityState extends State<SeeAllSpeciality> {
  void _navigateToSpecialtyDoctors(String specialty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorListScreen(initialSpecialty: specialty),
      ),
    );
  }

  final List<SpecialtyCategory> specialtyCategories = [
    SpecialtyCategory(name: 'General', imagePath: "images/health-checkup.gif"),
    SpecialtyCategory(
        name: 'Dentist', imagePath: "images/speciality/tooth-drill.gif"),
    SpecialtyCategory(
        name: 'Cardiology', imagePath: "images/speciality/cardio.gif"),
    SpecialtyCategory(
        name: 'Orthopedics', imagePath: "images/speciality/joint.gif"),
    SpecialtyCategory(
        name: 'Neurology', imagePath: "images/speciality/neurology.gif"),
    SpecialtyCategory(
        name: 'Gastroenterology', imagePath: "images/speciality/stomach.gif"),
    SpecialtyCategory(
        name: 'Ophthalmology',
        imagePath: "images/speciality/ophtalmologue.gif"),
    SpecialtyCategory(
        name: 'Pediatrics', imagePath: "images/speciality/childrens-day.gif"),
    SpecialtyCategory(
        name: 'Gynecology', imagePath: "images/speciality/embryo.gif"),
    SpecialtyCategory(
        name: 'Dermatology', imagePath: "images/speciality/dermatology.gif"),
    SpecialtyCategory(
        name: 'Psychology', imagePath: "images/speciality/psychology.gif"),
    SpecialtyCategory(name: 'Otology', imagePath: "images/speciality/ears.gif"),
    SpecialtyCategory(
        name: 'Urology', imagePath: "images/speciality/klawi.gif"),
    SpecialtyCategory(
        name: 'Pulmonary', imagePath: "images/speciality/poumons.gif"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'All Specialities',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics:
              const ClampingScrollPhysics(), // Prevents scrolling if inside another scrollable widget
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                4, // Adjust based on how many items you want in a row
            childAspectRatio: 0.8, // Adjust for proper height/width ratio
            crossAxisSpacing: 5,
            mainAxisSpacing: 12,
          ),
          itemCount: specialtyCategories.length,
          itemBuilder: (context, index) {
            final category = specialtyCategories[index];
            return InkWell(
              onTap: () => _navigateToSpecialtyDoctors(category.name),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Container(
                        width: 55,
                        height: 55,
                        child: Image.asset(
                          category.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3),
                  Container(
                    alignment: Alignment.center,
                    width: 70,
                    child: Text(
                      category.name,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
