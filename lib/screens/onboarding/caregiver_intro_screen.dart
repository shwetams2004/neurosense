import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';

import 'consent_screen.dart';

class CaregiverIntroScreen
    extends StatefulWidget {

  const CaregiverIntroScreen({
    super.key,
  });

  @override
  State<CaregiverIntroScreen>
      createState() =>
          _CaregiverIntroScreenState();
}

class _CaregiverIntroScreenState
    extends State<
        CaregiverIntroScreen> {

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

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(
            24,
          ),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [

              const Spacer(),

              Text(

                AppStrings.text(
                  "home_title",
                  currentLanguage,
                ),

                style:
                    const TextStyle(

                  fontSize: 32,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Text(

                AppStrings.text(
                  "caregiver_intro_text",
                  currentLanguage,
                ),

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 18,
                ),
              ),

              const Spacer(),

              SizedBox(

                width:
                    double.infinity,

                child:
                    ElevatedButton(

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const ConsentScreen(),
                      ),
                    );
                  },

                  child: Text(

                    AppStrings.text(
                      "get_started",
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