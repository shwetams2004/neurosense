import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController educationController = TextEditingController();

  bool isValid() {
    return ageController.text.isNotEmpty &&
        educationController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Basic Information"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This helps personalize tracking.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: educationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Years of Education",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid()
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
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
    );
  }
}
