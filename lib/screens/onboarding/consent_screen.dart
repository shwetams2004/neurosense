import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';

import 'user_selection_screen.dart';

class ConsentScreen
    extends StatefulWidget {

  const ConsentScreen({
    super.key,
  });

  @override
  State<ConsentScreen>
      createState() =>
          _ConsentScreenState();
}

class _ConsentScreenState
    extends State<ConsentScreen> {

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

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "before_begin",
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

        child: Column(

          children: [

            Text(

              AppStrings.text(
                "consent_description",
                currentLanguage,
              ),

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

                  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const UserSelectionScreen(),
                    ),
                  );
                },

                child: Text(

                  AppStrings.text(
                    "i_understand",
                    currentLanguage,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}