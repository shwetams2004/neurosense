import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_strings.dart';
import '../../services/firestore_service.dart';
import '../../storage/local_store.dart';

import '../home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final TextEditingController
      nameController =
      TextEditingController();

  final TextEditingController
      ageController =
      TextEditingController();

  final TextEditingController
      caregiverController =
      TextEditingController();

  final TextEditingController
      relationshipController =
      TextEditingController();

  String? selectedGender;

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

  bool isValid() {

    return nameController
            .text
            .isNotEmpty &&
        ageController
            .text
            .isNotEmpty &&
        selectedGender !=
            null &&
        caregiverController
            .text
            .isNotEmpty &&
        relationshipController
            .text
            .isNotEmpty;
  }

  Future<void> saveUserProfile()
      async {

    final prefs =
        await SharedPreferences
            .getInstance();

    final userId =
        "${nameController.text.trim().replaceAll(" ", "_").toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}";

    final userData = {

      "userId": userId,

      "name":
          nameController.text
              .trim(),

      "age":
          ageController.text
              .trim(),

      "gender":
          selectedGender,

      "caregiver":
          caregiverController
              .text
              .trim(),

      "relationship":
          relationshipController
              .text
              .trim(),
    };

    final existingUsers =
        prefs.getStringList(
              "user_profiles",
            ) ??
            [];

    existingUsers.add(
      jsonEncode(userData),
    );

    await prefs.setStringList(
      "user_profiles",
      existingUsers,
    );

    await LocalStore
        .setCurrentUser(
      userId,
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "create_profile",
            currentLanguage,
          ),
        ),

        automaticallyImplyLeading:
            false,
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child:
            SingleChildScrollView(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [

              Text(

                AppStrings.text(
                  "personalize_tracking",
                  currentLanguage,
                ),

                style:
                    const TextStyle(
                  fontSize: 18,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // =========================
              // NAME
              // =========================

              TextField(

                controller:
                    nameController,

                decoration:
                    InputDecoration(

                  labelText:
                      AppStrings.text(
                    "full_name",
                    currentLanguage,
                  ),

                  border:
                      const OutlineInputBorder(),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // AGE
              // =========================

              TextField(

                controller:
                    ageController,

                keyboardType:
                    TextInputType
                        .number,

                decoration:
                    InputDecoration(

                  labelText:
                      AppStrings.text(
                    "age",
                    currentLanguage,
                  ),

                  border:
                      const OutlineInputBorder(),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // GENDER
              // =========================

              DropdownButtonFormField<
                  String>(

                value:
                    selectedGender,

                decoration:
                    InputDecoration(

                  labelText:
                      AppStrings.text(
                    "gender",
                    currentLanguage,
                  ),

                  border:
                      const OutlineInputBorder(),
                ),

                items: [

                  DropdownMenuItem(

                    value: "Male",

                    child: Text(

                      AppStrings.text(
                        "male",
                        currentLanguage,
                      ),
                    ),
                  ),

                  DropdownMenuItem(

                    value: "Female",

                    child: Text(

                      AppStrings.text(
                        "female",
                        currentLanguage,
                      ),
                    ),
                  ),

                  DropdownMenuItem(

                    value: "Other",

                    child: Text(

                      AppStrings.text(
                        "other",
                        currentLanguage,
                      ),
                    ),
                  ),
                ],

                onChanged: (value) {

                  setState(() {

                    selectedGender =
                        value;
                  });
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // CAREGIVER NAME
              // =========================

              TextField(

                controller:
                    caregiverController,

                decoration:
                    InputDecoration(

                  labelText:
                      AppStrings.text(
                    "caregiver_name",
                    currentLanguage,
                  ),

                  border:
                      const OutlineInputBorder(),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // RELATIONSHIP
              // =========================

              TextField(

                controller:
                    relationshipController,

                decoration:
                    InputDecoration(

                  labelText:
                      AppStrings.text(
                    "relationship_caregiver",
                    currentLanguage,
                  ),

                  border:
                      const OutlineInputBorder(),
                ),

                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(
                height: 40,
              ),

              // =========================
              // CONTINUE BUTTON
              // =========================

              SizedBox(

                width:
                    double.infinity,

                child:
                    ElevatedButton(

                  onPressed:
                      isValid()

                          ? () async {

                              await saveUserProfile();

                              await FirestoreService
                                  .createPatient(

                                name:
                                    nameController
                                        .text
                                        .trim(),

                                age:
                                    int.parse(
                                  ageController
                                      .text,
                                ),

                                gender:
                                    selectedGender!,

                                caregiver:
                                    caregiverController
                                        .text
                                        .trim(),

                                relationship:
                                    relationshipController
                                        .text
                                        .trim(),
                              );

                              if (mounted) {

                                Navigator.pushReplacement(

                                  context,

                                  MaterialPageRoute(

                                    builder:
                                        (_) =>
                                            const HomeScreen(),
                                  ),
                                );
                              }
                            }

                          : null,

                  child: Text(

                    AppStrings.text(
                      "continue",
                      currentLanguage,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}