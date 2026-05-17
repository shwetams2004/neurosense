import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../storage/current_patient.dart';
import '../home/home_screen.dart';
import 'profile_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({
    super.key,
  });

  void selectPatient(
    BuildContext context,
    String patientId,
  ) {
    CurrentPatient.patientId =
        patientId;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Patient",
        ),
        automaticallyImplyLeading:
            false,
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<
                  QuerySnapshot>(
                stream:
                    FirestoreService
                        .getPatients(),

                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot
                          .hasData ||
                      snapshot
                          .data!
                          .docs
                          .isEmpty) {
                    return const Center(
                      child: Text(
                        "No patients found.\nCreate a patient profile.",
                        textAlign:
                            TextAlign
                                .center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  final patients =
                      snapshot
                          .data!.docs;

                  return ListView.builder(
                    itemCount:
                        patients.length,

                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final patient =
                          patients[index];

                      final data =
                          patient.data()
                              as Map<
                                  String,
                                  dynamic>;

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),

                        child: ListTile(
                          leading:
                              CircleAvatar(
                            child: Text(
                              data["name"][0]
                                  .toUpperCase(),
                            ),
                          ),

                          title: Text(
                            data["name"],
                          ),

                          subtitle: Text(
                            "Age: ${data["age"]} • ${data["gender"]}",
                          ),

                          trailing:
                              const Icon(
                            Icons
                                .arrow_forward_ios,
                          ),

                          onTap: () =>
                              selectPatient(
                            context,
                            patient.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(
                height: 20),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton.icon(
                icon: const Icon(
                  Icons.add,
                ),

                label: const Text(
                  "Create New Patient",
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}