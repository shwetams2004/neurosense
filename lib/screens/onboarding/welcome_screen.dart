import 'package:flutter/material.dart';

import 'language_selection_screen.dart';

class WelcomeScreen
    extends StatelessWidget {

  const WelcomeScreen({
    super.key,
  });

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

            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [

              const Spacer(),

              const Icon(

                Icons.psychology,

                size: 110,

                color: Colors.indigo,
              ),

              const SizedBox(
                height: 24,
              ),

              const Text(

                "NeuroSense",

                style: TextStyle(
                  fontSize: 34,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(

                "AI-powered cognitive health monitoring platform designed for accessible neurological screening and longitudinal assessment.",

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              SizedBox(

                width:
                    double.infinity,

                height: 58,

                child:
                    ElevatedButton(

                  onPressed: () {

                    Navigator.pushReplacement(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const LanguageSelectionScreen(),
                      ),
                    );
                  },

                  child: const Text(
                    "Continue",
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