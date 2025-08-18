import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurgicalInfoPage extends StatefulWidget {
  final String patientId;

  const SurgicalInfoPage({Key? key, required this.patientId}) : super(key: key);

  @override
  State<SurgicalInfoPage> createState() => _SurgicalInfoPageState();
}

class _SurgicalInfoPageState extends State<SurgicalInfoPage> {
  bool isLoading = true;
  Map<String, dynamic>? patientData;
  List<Map<String, dynamic>> surgicalInfo = [];

  @override
  void initState() {
    super.initState();
    fetchPatientSurgicalInfo();
  }

  Future<void> fetchPatientSurgicalInfo() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch patient basic info
      final patientDoc = await FirebaseFirestore.instance
          .collection('patient')
          .doc(widget.patientId)
          .get();

      if (patientDoc.exists) {
        patientData = patientDoc.data();
      }

      // Fetch surgical info for this patient
      final surgicalDocs = await FirebaseFirestore.instance
          .collection('chirurgical')
          .where('patientId', isEqualTo: widget.patientId)
          .get();

      surgicalInfo = surgicalDocs.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations Chirurgicales'),
        backgroundColor: Colors.blueGrey[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patientData == null
              ? const Center(child: Text('Patient non trouvé'))
              : PatientSurgicalInfoView(
                  patientData: patientData!,
                  surgicalInfo: surgicalInfo,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add navigation to add surgical info form
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PatientSurgicalInfoView extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final List<Map<String, dynamic>> surgicalInfo;

  const PatientSurgicalInfoView({
    Key? key,
    required this.patientData,
    required this.surgicalInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientInfoCard(),
          const SizedBox(height: 20),
          Text(
            'Historique Chirurgical',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          surgicalInfo.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Aucune information chirurgicale disponible'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: surgicalInfo.length,
                  itemBuilder: (context, index) {
                    return _buildSurgicalInfoCard(surgicalInfo[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    final firstName = patientData['first_name'] ?? 'N/A';
    final lastName = patientData['last_name'] ?? 'N/A';
    final birthDate = patientData['date_of_birth'] ?? 'N/A';
    final gender = patientData['gender'] ?? 'N/A';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  radius: 30,
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${patientData['patientId'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Date de naissance', birthDate),
            _buildInfoRow('Genre', gender == 'man' ? 'Homme' : 'Femme'),
            _buildInfoRow(
                'Lieu de naissance', patientData['place_of_birth'] ?? 'N/A'),
            if (patientData['emergencyContact'] != null)
              _buildInfoRow(
                  'Contact d\'urgence', patientData['emergencyContact']),
          ],
        ),
      ),
    );
  }

  Widget _buildSurgicalInfoCard(Map<String, dynamic> info) {
    final date = info['date'] ?? 'Date inconnue';
    final title = info['title'] ?? 'Type inconnu';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Date: $date'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info['surgeon'] != null)
                  _buildInfoRow('Chirurgien', info['surgeon']),
                if (info['hospital'] != null)
                  _buildInfoRow('Hôpital', info['hospital']),
                if (info['notes'] != null)
                  _buildInfoRow('Notes', info['notes']),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      onPressed: () {
                        // Navigate to edit page
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        // Show delete confirmation
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
