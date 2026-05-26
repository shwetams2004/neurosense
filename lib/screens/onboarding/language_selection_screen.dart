import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../../localization/app_language.dart';
import '../../storage/local_store.dart';

class LanguageSelectionScreen
    extends StatefulWidget {

  const LanguageSelectionScreen({
    super.key,
  });

  @override
  State<LanguageSelectionScreen>
      createState() =>
          _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<
        LanguageSelectionScreen> {

  String selectedLanguage =
      AppLanguage.english;

  @override
  void initState() {

    super.initState();

    loadLanguage();
  }

  Future<void>
      loadLanguage() async {

    selectedLanguage =
        await LocalStore
            .getLanguage();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> continueApp()
      async {

    await LocalStore.setLanguage(
      selectedLanguage,
    );

    if (!mounted) return;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) =>
    const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Choose Language",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(

          children: [

            const SizedBox(
              height: 20,
            ),

            const Text(

              "Select your preferred language",

              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Expanded(

              child: ListView.builder(

                itemCount:
                    AppLanguage
                        .all
                        .length,

                itemBuilder:
                    (context, index) {

                  final language =
                      AppLanguage
                          .all[index];

                  return Card(

                    child:
                        RadioListTile<

                            String>(

                      value: language,

                      groupValue:
                          selectedLanguage,

                      title: Text(
                        language,
                      ),

                      onChanged:
                          (value) {

                        setState(() {

                          selectedLanguage =
                              value!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton(

                onPressed:
                    continueApp,

                child: const Text(
                  "Continue",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}