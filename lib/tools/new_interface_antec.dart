// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class MedicalHistoryManager extends StatefulWidget {
//   final String patientId;

//   const MedicalHistoryManager({
//     Key? key,
//     required this.patientId,
//   }) : super(key: key);

//   @override
//   State<MedicalHistoryManager> createState() => _MedicalHistoryManagerState();
// }

// class _MedicalHistoryManagerState extends State<MedicalHistoryManager>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _entryController = TextEditingController();
//   late TabController _tabController;
//   String _currentCategory = 'allergies';
//   bool _isLoading = false;
//   bool _isEditMode = false;
//   int _editingIndex = -1;
//   String? _selectedBloodType;

//   // Blood types list
//   final List<String> _bloodTypes = [
//     'A+',
//     'A-',
//     'B+',
//     'B-',
//     'AB+',
//     'AB-',
//     'O+',
//     'O-'
//   ];

//   // Family history checkboxes
//   final Map<String, bool> _familyHistoryCheckboxes = {
//     'Diabète': false,
//     'Hypertension': false,
//     'Maladies cardiaques': false,
//     'Cancer': false,
//     'Asthme': false,
//   };

//   final List<Map<String, dynamic>> _categories = [
//     {
//       'name': 'allergies',
//       'icon': Icons.warning_amber_rounded,
//       'color': Colors.red,
//       'title': 'Allergies',
//       'type': 'array'
//     },
//     {
//       'name': 'blood_type',
//       'icon': Icons.bloodtype,
//       'color': Colors.pink,
//       'title': 'Groupe Sanguin',
//       'type': 'radio'
//     },
//     {
//       'name': 'chronics',
//       'icon': Icons.medical_services,
//       'color': Colors.orange,
//       'title': 'Maladies Chroniques',
//       'type': 'array'
//     },
//     {
//       'name': 'family_history',
//       'icon': Icons.family_restroom,
//       'color': Colors.purple,
//       'title': 'Antécédents Familiaux',
//       'type': 'checkbox'
//     },
//     {
//       'name': 'medications',
//       'icon': Icons.medication,
//       'color': Colors.blue,
//       'title': 'Médicaments',
//       'type': 'array'
//     },
//     {
//       'name': 'surgeries',
//       'icon': Icons.healing,
//       'color': Colors.green,
//       'title': 'Chirurgies',
//       'type': 'array'
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _categories.length, vsync: this);
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) {
//         setState(() {
//           _currentCategory = _categories[_tabController.index]['name'];
//           _cancelEdit();
//         });
//       }
//     });
//     _loadData();
//   }

//   void _loadData() async {
//     try {
//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('patient')
//           .doc(widget.patientId)
//           .collection('medical_info')
//           .doc()
//           .get();

//       if (docSnapshot.exists) {
//         final data = docSnapshot.data() as Map<String, dynamic>;

//         if (data.containsKey('blood_type')) {
//           setState(() {
//             _selectedBloodType = data['blood_type'] as String;
//           });
//         }

//         if (data.containsKey('family_history') &&
//             data['family_history'] is Map) {
//           final familyHistory = data['family_history'] as Map<String, dynamic>;
//           setState(() {
//             familyHistory.forEach((key, value) {
//               if (_familyHistoryCheckboxes.containsKey(key)) {
//                 _familyHistoryCheckboxes[key] = value as bool;
//               }
//             });
//           });
//         }
//       }
//     } catch (e) {
//       _showSnackBar('Erreur lors du chargement des données: ${e.toString()}');
//     }
//   }

//   @override
//   void dispose() {
//     _entryController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _addEntry() async {
//     if (_currentCategory == 'blood_type') {
//       if (_selectedBloodType == null) {
//         _showSnackBar('Veuillez sélectionner un groupe sanguin');
//         return;
//       }

//       await _saveBloodType();
//       return;
//     } else if (_currentCategory == 'family_history') {
//       await _saveFamilyHistory();
//       return;
//     }

//     if (_entryController.text.isEmpty) {
//       _showSnackBar('Veuillez entrer une valeur');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final docRef = FirebaseFirestore.instance
//           .collection('patient')
//           .doc(widget.patientId)
//           .collection('medical_info')
//           .doc('details');

//       await docRef.set({
//         _currentCategory: FieldValue.arrayUnion([_entryController.text]),
//       }, SetOptions(merge: true));

//       _entryController.clear();
//       _showSnackBar('Entrée ajoutée avec succès');
//     } catch (e) {
//       _showSnackBar('Erreur: ${e.toString()}');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveBloodType() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final docRef = FirebaseFirestore.instance
//           .collection('patient')
//           .doc(widget.patientId)
//           .collection('medical_info')
//           .doc('details');

//       await docRef.set({
//         'blood_type': _selectedBloodType,
//       }, SetOptions(merge: true));

//       _showSnackBar('Groupe sanguin enregistré avec succès');
//     } catch (e) {
//       _showSnackBar('Erreur: ${e.toString()}');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveFamilyHistory() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final docRef = FirebaseFirestore.instance
//           .collection('patient')
//           .doc(widget.patientId)
//           .collection('medical_info')
//           .doc('details');

//       await docRef.set({
//         'family_history': _familyHistoryCheckboxes,
//       }, SetOptions(merge: true));

//       _showSnackBar('Antécédents familiaux enregistrés avec succès');
//     } catch (e) {
//       _showSnackBar('Erreur: ${e.toString()}');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _updateEntry(List<dynamic> entries) async {
//     if (_entryController.text.isEmpty) {
//       _showSnackBar('Veuillez entrer une valeur');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final docRef = FirebaseFirestore.instance
//           .collection('patient')
//           .doc(widget.patientId)
//           .collection('medical_info')
//           .doc('details');

//       final String oldValue = entries[_editingIndex].toString();
//       final String newValue = _entryController.text;

//       await docRef.update({
//         _currentCategory: FieldValue.arrayRemove([oldValue]),
//       });

//       await docRef.update({
//         _currentCategory: FieldValue.arrayUnion([newValue]),
//       });

//       _entryController.clear();
//       _showSnackBar('Entrée modifiée avec succès');
//       _cancelEdit();
//     } catch (e) {
//       _showSnackBar('Erreur lors de la modification: ${e.toString()}');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _deleteEntry(String entry) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('patient')
//           .doc(widget.patientId)
//           .collection('medical_info')
//           .doc('details')
//           .update({
//         _currentCategory: FieldValue.arrayRemove([entry]),
//       });
//       _showSnackBar('Entrée supprimée avec succès');
//     } catch (e) {
//       _showSnackBar('Erreur lors de la suppression: ${e.toString()}');
//     }
//   }

//   void _enableEditMode(int index, String value) {
//     setState(() {
//       _isEditMode = true;
//       _editingIndex = index;
//       _entryController.text = value;
//     });
//   }

//   void _cancelEdit() {
//     setState(() {
//       _isEditMode = false;
//       _editingIndex = -1;
//       _entryController.clear();
//     });
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Gérer les ${_categories[_tabController.index]['title']}'),
//         actions: [
//           if (_isEditMode)
//             IconButton(
//               icon: const Icon(Icons.cancel),
//               onPressed: _cancelEdit,
//               tooltip: 'Annuler',
//             ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: _categories.map((category) {
//             return Tab(
//               icon: Icon(category['icon'] as IconData),
//               text: category['title'] as String,
//             );
//           }).toList(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: TabBarView(
//           controller: _tabController,
//           children: _categories.map((category) {
//             return _buildTabContent(category);
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildTabContent(Map<String, dynamic> category) {
//     final String categoryName = category['name'];
//     final String categoryType = category['type'];

//     switch (categoryType) {
//       case 'radio':
//         return _buildBloodTypeSelector(category);
//       case 'checkbox':
//         return _buildFamilyHistoryCheckboxes(category);
//       case 'array':
//       default:
//         return _buildArrayEntryList(category);
//     }
//   }

//   Widget _buildBloodTypeSelector(Map<String, dynamic> category) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           'Sélectionner un groupe sanguin',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 20),
//         Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           children: _bloodTypes.map((type) {
//             return ChoiceChip(
//               label: Text(type),
//               selected: _selectedBloodType == type,
//               onSelected: (selected) {
//                 if (selected) {
//                   setState(() {
//                     _selectedBloodType = type;
//                   });
//                 }
//               },
//               selectedColor: category['color'] as Color,
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: _isLoading ? null : _saveBloodType,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             backgroundColor: category['color'] as Color,
//           ),
//           child: _isLoading
//               ? const CircularProgressIndicator(color: Colors.white)
//               : const Text('Enregistrer le groupe sanguin'),
//         ),
//         const SizedBox(height: 30),
//         StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('patient')
//               .doc(widget.patientId)
//               .collection('medical_info')
//               .doc('details')
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError) {
//               return Center(child: Text('Erreur: ${snapshot.error}'));
//             }

//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return const Center(child: Text('Aucune donnée disponible'));
//             }

//             Map<String, dynamic> data =
//                 snapshot.data!.data() as Map<String, dynamic>;
//             String bloodType = data['blood_type'] ?? 'Non spécifié';

//             return Card(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               child: ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: category['color'] as Color,
//                   child:
//                       Icon(category['icon'] as IconData, color: Colors.white),
//                 ),
//                 title: Text(
//                   'Groupe sanguin actuel',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text(bloodType),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildFamilyHistoryCheckboxes(Map<String, dynamic> category) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           'Antécédents familiaux',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 20),
//         Expanded(
//           child: ListView(
//             children: _familyHistoryCheckboxes.entries.map((entry) {
//               return CheckboxListTile(
//                 title: Text(entry.key),
//                 value: entry.value,
//                 activeColor: category['color'] as Color,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _familyHistoryCheckboxes[entry.key] = value ?? false;
//                   });
//                 },
//               );
//             }).toList(),
//           ),
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: _isLoading ? null : _saveFamilyHistory,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             backgroundColor: category['color'] as Color,
//           ),
//           child: _isLoading
//               ? const CircularProgressIndicator(color: Colors.white)
//               : const Text('Enregistrer les antécédents familiaux'),
//         ),
//       ],
//     );
//   }

//   Widget _buildArrayEntryList(Map<String, dynamic> category) {
//     final String categoryName = category['name'];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           _isEditMode
//               ? 'Modifier: ${categoryName.toUpperCase()}'
//               : 'Ajouter: ${categoryName.toUpperCase()}',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 20),
//         TextField(
//           controller: _entryController,
//           decoration: InputDecoration(
//             labelText: _isEditMode ? 'Modifier entrée' : 'Nouvelle entrée',
//             hintText:
//                 'Saisir ${_isEditMode ? "la modification" : "une nouvelle entrée"} pour ${category['title']}',
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.clear),
//               onPressed: () => _entryController.clear(),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('patient')
//               .doc(widget.patientId)
//               .collection('medical_info')
//               .doc('details')
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (_isEditMode && snapshot.hasData) {
//               Map<String, dynamic> data =
//                   snapshot.data!.data() as Map<String, dynamic>;
//               List<dynamic> entries = data[categoryName] ?? [];

//               return ElevatedButton(
//                 onPressed: _isLoading ? null : () => _updateEntry(entries),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: category['color'] as Color,
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text('Mettre à jour'),
//               );
//             } else {
//               return ElevatedButton(
//                 onPressed: _isLoading ? null : _addEntry,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: category['color'] as Color,
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : Text('Ajouter à ${category['title']}'),
//               );
//             }
//           },
//         ),
//         const SizedBox(height: 30),
//         Expanded(
//           child: StreamBuilder<DocumentSnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('patient')
//                 .doc(widget.patientId)
//                 .collection('medical_info')
//                 .doc('details')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return Center(child: Text('Erreur: ${snapshot.error}'));
//               }

//               if (!snapshot.hasData || !snapshot.data!.exists) {
//                 return const Center(child: Text('Aucune donnée disponible'));
//               }

//               Map<String, dynamic> data =
//                   snapshot.data!.data() as Map<String, dynamic>;
//               List<dynamic> entries = [];

//               if (data.containsKey(categoryName)) {
//                 if (data[categoryName] is List) {
//                   entries = data[categoryName] as List<dynamic>;
//                 }
//               }

//               if (entries.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         category['icon'] as IconData,
//                         size: 48,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Aucune entrée dans ${category['title']}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return ListView.builder(
//                 itemCount: entries.length,
//                 itemBuilder: (context, index) {
//                   final bool isEditing = _isEditMode && index == _editingIndex;

//                   return Card(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     color: isEditing ? Colors.blue.shade50 : Colors.white,
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: category['color'] as Color,
//                         child: Icon(category['icon'] as IconData,
//                             color: Colors.white),
//                       ),
//                       title: Text(
//                         entries[index].toString(),
//                         style: TextStyle(
//                           fontWeight:
//                               isEditing ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () => _enableEditMode(
//                                 index, entries[index].toString()),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () =>
//                                 _deleteEntry(entries[index].toString()),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/homee.dart';
import 'package:uuid/uuid.dart';

class MedicalInfoEntryFlow extends StatefulWidget {
  final String patientId;

  MedicalInfoEntryFlow({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  State<MedicalInfoEntryFlow> createState() => _MedicalInfoEntryFlowState();
}

class _MedicalInfoEntryFlowState extends State<MedicalInfoEntryFlow> {
  // Controllers
  final PageController _pageController = PageController();
  final TextEditingController _textController = TextEditingController();

  // Variables for tracking
  int _currentPage = 0;
  bool _isLoading = false;

  // Blood types
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  // Lists for storing data
  List<String> _selectedBloodType = [];
  List<String> _allergies = [];
  List<String> _chronics = [];
  List<String> _familyHistory = [];
  List<String> _medications = [];
  List<String> _surgeries = [];

  // Page titles
  final List<String> _pageTitles = [
    'Blood Type',
    'Allergies',
    'Chronic Diseases',
    'Family History',
    'Medications',
    'Surgeries',
    'Verification of Information',
  ];

  // Page icons
  final List<IconData> _pageIcons = [
    Icons.bloodtype,
    Icons.warning_amber_rounded,
    Icons.medical_services,
    Icons.family_restroom,
    Icons.medication,
    Icons.healing,
    Icons.check_circle
  ];

  // Page colors
  final List<Color> _pageColors = [
    Colors.red,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.indigo
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Navigation methods
  void _nextPage() {
    // Validate blood type selection on first page
    if (_currentPage == 0 && _selectedBloodType.isEmpty) {
      _showSnackBar('Please select a blood type to continue');
      return;
    }

    if (_currentPage < _pageTitles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Helper methods
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addItem(List<String> list) {
    if (_textController.text.isEmpty) {
      _showSnackBar('Please enter a value');
      return;
    }

    setState(() {
      list.add(_textController.text);
      _textController.clear();
    });
  }

  void _removeItem(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  // Firestore submission
  Future<void> _submitData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a random document ID
      final String docId = const Uuid().v4();

      final docRef = FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patientId)
          .collection('medical_info')
          .doc(docId);

      // Prepare the data to save
      final Map<String, dynamic> medicalData = {
        'blood_type': _selectedBloodType,
        'allergies': _allergies,
        'chronics': _chronics,
        'family_history': _familyHistory,
        'medications': _medications,
        'surgeries': _surgeries,
        'created_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(medicalData);

      _showSnackBar('Informations médicales enregistrées avec succès');

      // Navigate back to previous screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Example()),
      );
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_pageTitles[_currentPage]),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / _pageTitles.length,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 10,
          ),

          // Step indicator
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_pageTitles.length, (index) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage >= index
                        ? _pageColors[index]
                        : Colors.grey[300],
                  ),
                  child: Center(
                    child: Icon(
                      _pageIcons[index],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              }),
            ),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildBloodTypePage(),
                _buildListEntryPage('Allergies', _allergies, _addAllergy),
                _buildListEntryPage('Chronics', _chronics, _addChronic),
                _buildListEntryPage(
                    'Family history', _familyHistory, _addFamilyHistory),
                _buildListEntryPage(
                    'Medications', _medications, _addMedication),
                _buildListEntryPage('Surgeries', _surgeries, _addSurgery),
                _buildReviewPage(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button (hidden on first page)
                _currentPage > 0
                    ? ElevatedButton.icon(
                        onPressed: _previousPage,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          'back',
                          style: TextStyle(color: Colors.blue),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.blue),
                          ),
                          elevation: 0,
                        ),
                      )
                    : const SizedBox(width: 120),

                // Next/Submit button
                _currentPage < _pageTitles.length - 1
                    ? ElevatedButton.icon(
                        onPressed: _nextPage,
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Suivant',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitData,
                        icon: _isLoading
                            ? Container(
                                width: 24,
                                height: 24,
                                padding: const EdgeInsets.all(2.0),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          _isLoading ? 'Sending...' : 'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Blood Type Selection Page
  Widget _buildBloodTypePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sélectionnez votre groupe sanguin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _bloodTypes.length,
              itemBuilder: (context, index) {
                final type = _bloodTypes[index];
                final isSelected = _selectedBloodType.contains(type);

                return Card(
                  elevation: isSelected ? 8 : 2,
                  color: isSelected ? _pageColors[0] : Colors.white,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedBloodType.clear();
                        _selectedBloodType.add(type);
                      });
                    },
                    child: Center(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Text(
            _selectedBloodType == null
                ? 'Veuillez sélectionner un groupe sanguin pour continuer'
                : 'Groupe sanguin sélectionné: $_selectedBloodType',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _selectedBloodType == null ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Expanded(child: Container()),
        ],
      ),
    );
  }

  // Helper functions for list pages
  void _addAllergy() => _addItem(_allergies);
  void _addChronic() => _addItem(_chronics);
  void _addFamilyHistory() => _addItem(_familyHistory);
  void _addMedication() => _addItem(_medications);
  void _addSurgery() => _addItem(_surgeries);

  // Generic List Entry Page
  Widget _buildListEntryPage(
      String title, List<String> items, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.5),
                    ),
                    labelText: 'Add new element',
                    floatingLabelStyle: const TextStyle(color: Colors.blue),
                    hintText: 'add new $title',
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: onAdd,
                color: _pageColors[_currentPage],
                iconSize: 40,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? ListView(children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _pageIcons[_currentPage],
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No $title added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'You can add one or more $title',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ])
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _pageColors[_currentPage],
                            child: Text('${index + 1}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(items[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(items, index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Review Page
  Widget _buildReviewPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Verification of Information',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Blood Type section
            _buildReviewSection(
              'Blood Type',
              Icons.bloodtype,
              _pageColors[0],
              _selectedBloodType.isEmpty ? [''] : _selectedBloodType,
            ),

            // Allergies section
            _buildReviewSection(
              'Allergies',
              Icons.warning_amber_rounded,
              _pageColors[1],
              _allergies.isEmpty ? ['No allergies'] : _allergies,
            ),

            // Chronics section
            _buildReviewSection(
              'Chronics',
              Icons.medical_services,
              _pageColors[2],
              _chronics.isEmpty ? ['No chronics'] : _chronics,
            ),

            // Family History section
            _buildReviewSection(
              'Family History',
              Icons.family_restroom,
              _pageColors[3],
              _familyHistory.isEmpty ? ['No family history'] : _familyHistory,
            ),

            // Medications section
            _buildReviewSection(
              'Medications',
              Icons.medication,
              _pageColors[4],
              _medications.isEmpty ? ['No medications'] : _medications,
            ),

            // Surgeries section
            _buildReviewSection(
              'Surgeries',
              Icons.healing,
              _pageColors[5],
              _surgeries.isEmpty ? ['No surgeries'] : _surgeries,
            ),

            const SizedBox(height: 30),
            const Text(
              'Click "Submit" to save your information',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building review sections
  Widget _buildReviewSection(
      String title, IconData icon, Color color, List<String> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}










































// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:uuid/uuid.dart';

// class MedicalInfoEntryFlow extends StatefulWidget {
//   final String patientId;

//   const MedicalInfoEntryFlow({
//     Key? key,
//     required this.patientId,
//   }) : super(key: key);

//   @override
//   State<MedicalInfoEntryFlow> createState() => _MedicalInfoEntryFlowState();
// }

// class _MedicalInfoEntryFlowState extends State<MedicalInfoEntryFlow> {
//   // Controllers
//   final PageController _pageController = PageController();
//   final TextEditingController _textController = TextEditingController();

//   // Variables for tracking
//   int _currentPage = 0;
//   bool _isLoading = false;

//   // Blood types
//   String? _selectedBloodType;
//   List<String> _bloodTypeArray = [];
//   final List<String> _bloodTypes = [
//     'A+',
//     'A-',
//     'B+',
//     'B-',
//     'AB+',
//     'AB-',
//     'O+',
//     'O-'
//   ];

//   // Lists for storing data
//   List<String> _allergies = [];
//   List<String> _chronics = [];
//   List<String> _familyHistory = [];
//   List<String> _medications = [];
//   List<String> _surgeries = [];

//   // Page titles
//   final List<String> _pageTitles = [
//     'Groupe Sanguin',
//     'Allergies',
//     'Maladies Chroniques',
//     'Antécédents Familiaux',
//     'Médicaments',
//     'Chirurgies',
//     'Vérification et Soumission'
//   ];

//   // Page icons
//   final List<IconData> _pageIcons = [
//     Icons.bloodtype,
//     Icons.warning_amber_rounded,
//     Icons.medical_services,
//     Icons.family_restroom,
//     Icons.medication,
//     Icons.healing,
//     Icons.check_circle
//   ];

//   // Page colors
//   final List<Color> _pageColors = [
//     Colors.red,
//     Colors.orange,
//     Colors.blue,
//     Colors.purple,
//     Colors.green,
//     Colors.teal,
//     Colors.indigo
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   // Navigation methods
//   void _nextPage() {
//     // Validate blood type selection on first page
//     if (_currentPage == 0 && _selectedBloodType == null) {
//       _showSnackBar('Veuillez sélectionner un groupe sanguin');
//       return;
//     }

//     // Update blood type array when moving from the first page
//     if (_currentPage == 0 && _selectedBloodType != null) {
//       _bloodTypeArray = [_selectedBloodType!];
//     }

//     if (_currentPage < _pageTitles.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void _previousPage() {
//     if (_currentPage > 0) {
//       _pageController.previousPage(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   // Helper methods
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   void _addItem(List<String> list) {
//     if (_textController.text.isEmpty) {
//       _showSnackBar('Veuillez entrer une valeur');
//       return;
//     }

//     setState(() {
//       list.add(_textController.text);
//       _textController.clear();
//     });
//   }

//   void _removeItem(List<String> list, int index) {
//     setState(() {
//       list.removeAt(index);
//     });
//   }

//   // Firestore submission
//   Future<void> _submitData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Generate a random document ID
//       final String docId = const Uuid().v4();

//       final docRef = FirebaseFirestore.instance
//           .collection('patient')
//           .doc(widget.patientId)
//           .collection('medical_info')
//           .doc(docId);

//       // Prepare the data to save
//       final Map<String, dynamic> medicalData = {
//         'blood_type': _bloodTypeArray,
//         'allergies': _allergies,
//         'chronics': _chronics,
//         'family_history': _familyHistory,
//         'medications': _medications,
//         'surgeries': _surgeries,
//         'created_at': FieldValue.serverTimestamp(),
//       };

//       await docRef.set(medicalData);

//       _showSnackBar('Informations médicales enregistrées avec succès');

//       // Navigate back to previous screen
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       _showSnackBar('Erreur: ${e.toString()}');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_pageTitles[_currentPage]),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Progress indicator
//           LinearProgressIndicator(
//             value: (_currentPage + 1) / _pageTitles.length,
//             backgroundColor: Colors.grey[300],
//             color: Colors.blue,
//             minHeight: 10,
//           ),

//           // Step indicator
//           Padding(
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: List.generate(_pageTitles.length, (index) {
//                 return Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color:
//                         _currentPage >= index ? Colors.blue : Colors.grey[300],
//                   ),
//                   child: Center(
//                     child: Icon(
//                       _pageIcons[index],
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),

//           // Page content
//           Expanded(
//             child: PageView(
//               controller: _pageController,
//               physics: const NeverScrollableScrollPhysics(),
//               onPageChanged: (int page) {
//                 setState(() {
//                   _currentPage = page;
//                 });
//               },
//               children: [
//                 _buildBloodTypePage(),
//                 _buildListEntryPage('Allergies', _allergies, _addAllergy),
//                 _buildListEntryPage(
//                     'Maladies Chroniques', _chronics, _addChronic),
//                 _buildListEntryPage(
//                     'Antécédents Familiaux', _familyHistory, _addFamilyHistory),
//                 _buildListEntryPage(
//                     'Médicaments', _medications, _addMedication),
//                 _buildListEntryPage('Chirurgies', _surgeries, _addSurgery),
//                 _buildReviewPage(),
//               ],
//             ),
//           ),

//           // Navigation buttons
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Back button (hidden on first page)
//                 _currentPage > 0
//                     ? ElevatedButton.icon(
//                         onPressed: _previousPage,
//                         icon: const Icon(Icons.arrow_back),
//                         label: const Text('Précédent'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey,
//                         ),
//                       )
//                     : const SizedBox(width: 120),

//                 // Next/Submit button
//                 _currentPage < _pageTitles.length - 1
//                     ? ElevatedButton.icon(
//                         onPressed: _nextPage,
//                         icon: const Icon(Icons.arrow_forward),
//                         label: const Text('Suivant'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                         ),
//                       )
//                     : ElevatedButton.icon(
//                         onPressed: _isLoading ? null : _submitData,
//                         icon: _isLoading
//                             ? Container(
//                                 width: 24,
//                                 height: 24,
//                                 padding: const EdgeInsets.all(2.0),
//                                 child: const CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 3,
//                                 ),
//                               )
//                             : const Icon(Icons.check),
//                         label: Text(_isLoading ? 'Envoi...' : 'Soumettre'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Blood Type Selection Page
//   Widget _buildBloodTypePage() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const Text(
//             'Sélectionnez votre groupe sanguin',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemCount: _bloodTypes.length,
//               itemBuilder: (context, index) {
//                 final type = _bloodTypes[index];
//                 final isSelected = _selectedBloodType == type;

//                 return Card(
//                   elevation: isSelected ? 8 : 2,
//                   color: isSelected ? Colors.red : Colors.white,
//                   child: InkWell(
//                     onTap: () {
//                       setState(() {
//                         _selectedBloodType = type;
//                       });
//                     },
//                     child: Center(
//                       child: Text(
//                         type,
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: isSelected ? Colors.white : Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             _selectedBloodType == null
//                 ? 'Veuillez sélectionner un groupe sanguin pour continuer'
//                 : 'Groupe sanguin sélectionné: $_selectedBloodType',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: _selectedBloodType == null ? Colors.red : Colors.green,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper functions for list pages
//   void _addAllergy() => _addItem(_allergies);
//   void _addChronic() => _addItem(_chronics);
//   void _addFamilyHistory() => _addItem(_familyHistory);
//   void _addMedication() => _addItem(_medications);
//   void _addSurgery() => _addItem(_surgeries);

//   // Generic List Entry Page
//   Widget _buildListEntryPage(
//       String title, List<String> items, VoidCallback onAdd) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _textController,
//                   decoration: InputDecoration(
//                     labelText: 'Ajouter un élément',
//                     hintText: 'Saisir un nouvel élément',
//                     border: const OutlineInputBorder(),
//                   ),
//                   onSubmitted: (_) => onAdd(),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               IconButton(
//                 icon: const Icon(Icons.add_circle),
//                 onPressed: onAdd,
//                 color: Colors.blue,
//                 iconSize: 40,
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: items.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           _pageIcons[_currentPage],
//                           size: 60,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           'Aucun élément ajouté',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           'Vous pouvez ajouter un ou plusieurs éléments',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: items.length,
//                     itemBuilder: (context, index) {
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: Colors.blue,
//                             child: Text('${index + 1}'),
//                           ),
//                           title: Text(items[index]),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _removeItem(items, index),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Review Page
//   Widget _buildReviewPage() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'Vérification des informations',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),

//             // Blood Type section
//             _buildReviewSection(
//               'Groupe Sanguin',
//               Icons.bloodtype,
//               Colors.blue,
//               _bloodTypeArray.isEmpty ? ['Non spécifié'] : _bloodTypeArray,
//             ),

//             // Allergies section
//             _buildReviewSection(
//               'Allergies',
//               Icons.warning_amber_rounded,
//               Colors.blue,
//               _allergies.isEmpty ? ['Aucune allergie'] : _allergies,
//             ),

//             // Chronics section
//             _buildReviewSection(
//               'Maladies Chroniques',
//               Icons.medical_services,
//               Colors.blue,
//               _chronics.isEmpty ? ['Aucune maladie chronique'] : _chronics,
//             ),

//             // Family History section
//             _buildReviewSection(
//               'Antécédents Familiaux',
//               Icons.family_restroom,
//               Colors.blue,
//               _familyHistory.isEmpty
//                   ? ['Aucun antécédent familial']
//                   : _familyHistory,
//             ),

//             // Medications section
//             _buildReviewSection(
//               'Médicaments',
//               Icons.medication,
//               Colors.blue,
//               _medications.isEmpty ? ['Aucun médicament'] : _medications,
//             ),

//             // Surgeries section
//             _buildReviewSection(
//               'Chirurgies',
//               Icons.healing,
//               Colors.blue,
//               _surgeries.isEmpty ? ['Aucune chirurgie'] : _surgeries,
//             ),

//             const SizedBox(height: 30),
//             const Text(
//               'Cliquez sur "Soumettre" pour enregistrer vos informations médicales',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontStyle: FontStyle.italic),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper method for building review sections
//   Widget _buildReviewSection(
//       String title, IconData icon, Color color, List<String> items) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: color, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, color: color),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: items.map((item) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle, color: color, size: 16),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           item,
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
