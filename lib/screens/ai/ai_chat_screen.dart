import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/gemini_service.dart';
import '../../services/typing_biomarker_service.dart';
import '../../storage/local_store.dart';
import '../../localization/app_strings.dart';
class AIChatScreen
    extends StatefulWidget {
  const AIChatScreen({
    super.key,
  });

  @override
  State<AIChatScreen>
      createState() =>
          _AIChatScreenState();
}

class _AIChatScreenState
    extends State<AIChatScreen> {
  final TextEditingController
      controller =
      TextEditingController();

  final List<Map<String, dynamic>>
    messages = [];

  bool typing = false;

  String currentLanguage =
    "English";

  final TypingBiomarkerService
    biomarkerService =
        TypingBiomarkerService();

String previousText = "";
final ScrollController
    scrollController =
        ScrollController();
@override
void initState() {

  super.initState();

  initializeChat();

  biomarkerService.startSession();
}

Future<void> initializeChat()
async {

  currentLanguage =
      await LocalStore
          .getLanguage();

  String welcomeMessage =
      AppStrings.text(
    "ai_welcome",
    currentLanguage,
  );

  setState(() {

    messages.add({

      "role": "ai",

      "text":
          welcomeMessage,
    });
  });
}

void scrollToBottom() {

  Future.delayed(
    const Duration(
      milliseconds: 100,
    ),
    () {

      if (scrollController
          .hasClients) {

        scrollController.animateTo(

          scrollController
              .position
              .maxScrollExtent,

          duration: const Duration(
            milliseconds: 300,
          ),

          curve: Curves.easeOut,
        );
      }
    },
  );
}

  Future<void> sendMessage() async {
    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "role": "user",
        "text": text,
      });

      typing = true;
    });
    scrollToBottom();

    final biomarkerData =
    biomarkerService.endSession();

await LocalStore
    .saveKeyboardMetrics({

  "avg_inter_key_interval_ms":
      biomarkerData.averagePauseMs,

  "backspace_count":
      biomarkerData.backspaceCount
          .toDouble(),

  "error_bursts":
      biomarkerData.pauseCount
          .toDouble(),

  "total_keys":
      biomarkerData.totalCharacters
          .toDouble(),

  "hesitation_pauses":
      biomarkerData.pauseCount
          .toDouble(),

  "long_pauses":
      biomarkerData.pauseCount
          .toDouble(),

  "session_duration_sec":
      biomarkerData
              .sessionDurationMs /
          1000,

  "typing_speed_keys_per_sec":
      biomarkerData.typingSpeed,

  "correction_ratio":
      biomarkerData
                  .totalCharacters ==
              0
          ? 0
          : biomarkerData
                  .backspaceCount /
              biomarkerData
                  .totalCharacters,
});

biomarkerService.startSession();

    controller.clear();
    previousText = "";

    final response =
    await GeminiService
        .sendMessage(text);

    setState(() {
      typing = false;

      messages.add({
        "role": "ai",
        "text": response,
      });
    });
    scrollToBottom();
  }

  

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "NeuroSense AI",
        ),
      ),

      body: Column(
        children: [
          // =========================
          // CHAT AREA
          // =========================

          Expanded(
            child: ListView.builder(
              controller:
              scrollController,
              padding:
                  const EdgeInsets.all(
                18,
              ),
              itemCount:
                  messages.length +
                      (typing ? 1 : 0),
              itemBuilder:
                  (context, index) {
                if (typing &&
                    index ==
                        messages.length) {
                  return _typingBubble();
                }

                final message =
                    messages[index];

                final isUser =
                    message["role"] ==
                        "user";

                return _messageBubble(
                  message["text"],
                  isUser,
                )
                    .animate()
                    .fadeIn(
                      duration: 300.ms,
                    )
                    .slideY(
                      begin: 0.15,
                      end: 0,
                    );
              },
            ),
          ),

          // =========================
          // INPUT
          // =========================

          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.all(
                14,
              ),
              decoration:
                  const BoxDecoration(
                color: Colors.white,
              ),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          controller,

                      textInputAction:
                          TextInputAction
                              .send,
                              onChanged: (value) {

  biomarkerService.onTextChanged(
    previousText,
    value,
  );

  previousText = value;
},

                      onSubmitted:
                          (_) async {
                        await sendMessage();
                      },

                      decoration:
                          InputDecoration(
                        hintText:
                            "Ask NeuroSense AI...",
                        filled: true,
                        fillColor: Colors
                            .grey
                            .shade100,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        Colors.indigo,

                    child: IconButton(
                      onPressed:
                          sendMessage,

                      icon: const Icon(
                        Icons.send,
                        color:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // MESSAGE BUBBLE
  // =========================

  Widget _messageBubble(
    String text,
    bool isUser,
  ) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 340,
        ),

        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),

        padding:
            const EdgeInsets.all(
          16,
        ),

        decoration:
            BoxDecoration(
          color: isUser
              ? Colors.indigo
              : Colors.white,

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),

        child: MarkdownBody(

  data: text,

  styleSheet:
      MarkdownStyleSheet(

    p: TextStyle(
      fontSize: 16,
      color: isUser
          ? Colors.white
          : Colors.black87,
    ),

    strong: TextStyle(
      fontWeight:
          FontWeight.bold,
      color: isUser
          ? Colors.white
          : Colors.black,
    ),

    h1: TextStyle(
      fontSize: 22,
      fontWeight:
          FontWeight.bold,
      color: isUser
          ? Colors.white
          : Colors.black,
    ),

    h2: TextStyle(
      fontSize: 20,
      fontWeight:
          FontWeight.bold,
      color: isUser
          ? Colors.white
          : Colors.black,
    ),

    listBullet: TextStyle(
      color: isUser
          ? Colors.white
          : Colors.black,
    ),
  ),
),
      ),
    );
  }

  // =========================
  // TYPING BUBBLE
  // =========================

  Widget _typingBubble() {
    return Align(
      alignment:
          Alignment.centerLeft,

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),

        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
        ),

        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            _dot(),
            const SizedBox(width: 6),
            _dot(delay: 200),
            const SizedBox(width: 6),
            _dot(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _dot({
    int delay = 0,
  }) {
    return Container(
          width: 10,
          height: 10,
          decoration:
              const BoxDecoration(
            color: Colors.indigo,
            shape: BoxShape.circle,
          ),
        )
            .animate(
              onPlay:
                  (controller) =>
                      controller.repeat(),
            )
            .fadeIn(
              delay: delay.ms,
            )
            .then()
            .fadeOut();
  }
}