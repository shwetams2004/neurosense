import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../services/firestore_service.dart';
import '../../storage/current_patient.dart';
import '../../storage/local_store.dart';

import '../home/home_screen.dart';
import 'profile_screen.dart';

class UserSelectionScreen
    extends StatefulWidget {

  const UserSelectionScreen({
    super.key,
  });

  @override
  State<UserSelectionScreen>
      createState() =>
          _UserSelectionScreenState();
}

class _UserSelectionScreenState
    extends State<
        UserSelectionScreen> {

  String currentLanguage =
      "English";

  @override
  void initState() {

    super.initState();

    loadLanguage();
  }

  Future<void> loadLanguage()
      async {

    currentLanguage =
        await LocalStore
            .getLanguage();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> selectPatient(

  BuildContext context,

  String patientId,
) async {

  CurrentPatient.patientId =
      patientId;

  await LocalStore.setCurrentUser(
    patientId,
  );

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

        title: Text(

          AppStrings.text(
            "select_patient",
            currentLanguage,
          ),
        ),

        automaticallyImplyLeading:
            false,
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

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

                    return Center(

                      child: Text(

                        AppStrings.text(
                          "no_patients_found",
                          currentLanguage,
                        ),

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  final patients =
                      snapshot
                          .data!
                          .docs;

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

                            "${AppStrings.text(
                              "age",
                              currentLanguage,
                            )}: ${data["age"]} • ${data["gender"]}",
                          ),

                          trailing:
                              const Icon(

                            Icons
                                .arrow_forward_ios,
                          ),

                          onTap: () {

                            selectPatient(

                              context,

                              patient.id,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(

              width:
                  double.infinity,

              child:
                  ElevatedButton.icon(

                icon: const Icon(
                  Icons.add,
                ),

                label: Text(

                  AppStrings.text(
                    "create_new_patient",
                    currentLanguage,
                  ),
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