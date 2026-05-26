import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';

class SpeechSampleScreen
    extends StatefulWidget {

  const SpeechSampleScreen({
    super.key,
  });

  @override
  State<SpeechSampleScreen>
      createState() =>
          _SpeechSampleScreenState();
}

class _SpeechSampleScreenState
    extends State<
        SpeechSampleScreen> {

  final Record recorder = Record();

  bool recording = false;

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

  Future<void> startRecording()
      async {

    if (await recorder
        .hasPermission()) {

      await recorder.start();

      if (mounted) {

        setState(() {

          recording = true;
        });
      }
    }
  }

  Future<void> stopRecording()
      async {

    final path =
        await recorder.stop();

    if (mounted) {

      setState(() {

        recording = false;
      });
    }

    final currentUser =
        await LocalStore
            .getCurrentUser();

    if (currentUser == null) {
      return;
    }

    if (path != null) {

      await LocalStore
          .saveSpeechMetrics(

        userId: currentUser,

        metrics: {

          "pause_ratio": 0.32,

          "speech_rate": 110,

          "hesitation_events": 5,
        },
      );

      if (mounted) {

        ScaffoldMessenger.of(
                context)
            .showSnackBar(

          SnackBar(

            content: Text(

              AppStrings.text(
                "speech_completed",
                currentLanguage,
              ),
            ),
          ),
        );
      }
    }

    if (mounted) {

      Navigator.pop(
        context,
      );
    }
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(

          AppStrings.text(
            "speech_title",
            currentLanguage,
          ),
        ),
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
                "speech_instruction",
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

            Container(

              height: 180,

              decoration:
                  BoxDecoration(

                color:
                    Colors.grey
                        .shade300,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: const Center(

                child: Text(

                  "Picture Placeholder",

                  style:
                      TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 40,
            ),

            SizedBox(

              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed:
                    recording

                        ? stopRecording

                        : startRecording,

                child: Text(

                  recording

                      ? AppStrings.text(
                          "stop_recording",
                          currentLanguage,
                        )

                      : AppStrings.text(
                          "start_recording",
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