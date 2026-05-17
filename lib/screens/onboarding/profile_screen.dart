import 'dart:convert';

import 'package:flutter/material.dart';

import '../../storage/local_store.dart';
import '../home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController ageController =
      TextEditingController();

  final TextEditingController caregiverController =
      TextEditingController();

  final TextEditingController relationshipController =
      TextEditingController();

  String? selectedGender;

  bool isValid() {
    return nameController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        selectedGender != null &&
        caregiverController.text.isNotEmpty &&
        relationshipController.text.isNotEmpty;
  }

  Future<void> saveUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final userId =
        "${nameController.text.trim().replaceAll(" ", "_").toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}";

    final userData = {
      "userId": userId,
      "name": nameController.text.trim(),
      "age": ageController.text.trim(),
      "gender": selectedGender,
      "caregiver": caregiverController.text.trim(),
      "relationship":
          relationshipController.text.trim(),
    };

    final existingUsers =
        prefs.getStringList("user_profiles") ?? [];

    existingUsers.add(jsonEncode(userData));

    await prefs.setStringList(
      "user_profiles",
      existingUsers,
    );

    await LocalStore.setCurrentUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create User Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "This helps personalize cognitive tracking.",
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: ageController,
                keyboardType:
                    TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Male",
                    child: Text("Male"),
                  ),
                  DropdownMenuItem(
                    value: "Female",
                    child: Text("Female"),
                  ),
                  DropdownMenuItem(
                    value: "Other",
                    child: Text("Other"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextField(
                controller: caregiverController,
                decoration: const InputDecoration(
                  labelText: "Caregiver Name",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    relationshipController,
                decoration: const InputDecoration(
                  labelText:
                      "Relationship to Caregiver",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValid()
                      ? () async {
                          await saveUserProfile();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const HomeScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}