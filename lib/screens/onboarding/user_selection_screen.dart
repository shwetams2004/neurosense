import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../storage/local_store.dart';
import '../home/home_screen.dart';
import 'profile_screen.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() =>
      _UserSelectionScreenState();
}

class _UserSelectionScreenState
    extends State<UserSelectionScreen> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final storedUsers =
        prefs.getStringList("user_profiles") ?? [];

    setState(() {
      users = storedUsers
          .map((e) => jsonDecode(e)
              as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> selectUser(String userId) async {
    await LocalStore.setCurrentUser(userId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select User"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: Text(
                        "No users found.\nCreate a new profile.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return Card(
                          margin:
                              const EdgeInsets.only(
                                  bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                user["name"][0]
                                    .toUpperCase(),
                              ),
                            ),
                            title: Text(
                              user["name"],
                            ),
                            subtitle: Text(
                              "Age: ${user["age"]} • ${user["gender"]}",
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                            ),
                            onTap: () => selectUser(
                              user["userId"],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label:
                    const Text("Create New User"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ProfileScreen(),
                    ),
                  ).then((_) => loadUsers());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}