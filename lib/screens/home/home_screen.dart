import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localization/app_strings.dart';
import '../../storage/local_store.dart';

// AI
import '../ai/ai_chat_screen.dart';

// Tests
import '../tests/memory_test_screen.dart';
import '../tests/digit_span_screen.dart';
import '../tests/trail_making_screen.dart';
import '../tests/visuospatial_task_screen.dart';
import '../tests/vigilance_test_screen.dart';
import '../tests/serial_subtraction_screen.dart';

// Summary
import '../summary/clinician_summary_screen.dart';

class HomeScreen
    extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen>
      createState() =>
          _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int weeksCompleted = 0;

  String currentUserName = "";

  String currentUserId = "";

  String currentLanguage =
      "English";

  @override
  void initState() {

    super.initState();

    loadCurrentUser();

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

  Future<void> loadCurrentUser()
      async {

    final userId =
        await LocalStore
            .getCurrentUser();

    if (userId == null) return;

    final prefs =
        await SharedPreferences
            .getInstance();

    final storedUsers =
        prefs.getStringList(
              "user_profiles",
            ) ??
            [];

    final users = storedUsers

        .map(
          (e) => jsonDecode(e)
              as Map<String, dynamic>,
        )

        .toList();

    final currentUser =
        users.firstWhere(

      (u) => u["userId"] == userId,

      orElse: () => {},
    );

    setState(() {

      currentUserId = userId;

      currentUserName =
          currentUser["name"] ??
              "User";
    });

    loadStatus();
  }

  Future<void> loadStatus()
      async {

    if (currentUserId.isEmpty)
      return;

    final count =
        await LocalStore
            .getWeekCount(
      currentUserId,
    );

    setState(() {

      weeksCompleted = count;
    });
  }

  String insightText() {

  if (weeksCompleted < 3) {

    return AppStrings.text(
      "baseline_establishing",
      currentLanguage,
    );

  } else {

    return AppStrings.text(
      "enough_data_summary",
      currentLanguage,
    );
  }
}

  Color progressColor() {

    if (weeksCompleted < 2) {

      return Colors.orange;

    } else if (weeksCompleted <
        4) {

      return Colors.indigo;
    }

    return Colors.green;
  }

  @override
  Widget build(
      BuildContext context) {

    final displayWeek =
        weeksCompleted < 4

            ? weeksCompleted + 1

            : weeksCompleted;

    return Scaffold(

      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(

        elevation: 0,

        title: Text(

          AppStrings.text(
            "home_title",
            currentLanguage,
          ),
        ),
      ),

      body:
          SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            // =========================
            // HEADER CARD
            // =========================

            Container(

              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                22,
              ),

              decoration:
                  BoxDecoration(

                gradient:
                    const LinearGradient(

                  colors: [

                    Color(
                      0xFF4F46E5,
                    ),

                    Color(
                      0xFF6366F1,
                    ),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

  

                  Container(

                    padding:
                        const EdgeInsets.symmetric(

                      horizontal: 14,

                      vertical: 10,
                    ),

                    decoration:
                        BoxDecoration(

                      color: Colors
                          .white
                          .withOpacity(
                        0.15,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: Row(

                      children: [

                        const Icon(

                          Icons
                              .analytics_outlined,

                          color:
                              Colors.white,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(

                          child: Text(

                            weeksCompleted <
                                    4

                                ? "${AppStrings.text("baseline_week", currentLanguage)} $displayWeek / 4"

                                : AppStrings.text(
  "tracking_active",
  currentLanguage,
),

                            style:
                                const TextStyle(

                              color:
                                  Colors.white,

                              fontSize:
                                  16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // =========================
            // QUICK OVERVIEW
            // =========================

            Row(

              children: [

                Expanded(

                  child:
                      _overviewCard(

                    AppStrings.text(
  "weeks",
  currentLanguage,
),

                    weeksCompleted
                        .toString(),

                    Icons
                        .calendar_today,

                    progressColor(),
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(

                  child:
                      _overviewCard(

                    AppStrings.text(
  "status",
  currentLanguage,
),

                    weeksCompleted < 4

    ? AppStrings.text(
        "baseline",
        currentLanguage,
      )

    : AppStrings.text(
        "tracking",
        currentLanguage,
      ),

                    Icons
                        .psychology,

                    Colors.indigo,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 26,
            ),

            // =========================
            // INSIGHT CARD
            // =========================

            Container(

              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                18,
              ),

              decoration:
                  BoxDecoration(

                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Row(

                children: [

                  Container(

                    padding:
                        const EdgeInsets.all(
                      12,
                    ),

                    decoration:
                        BoxDecoration(

                      color: Colors
                          .indigo
                          .withOpacity(
                        0.1,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),

                    child: const Icon(

                      Icons
                          .lightbulb_outline,

                      color:
                          Colors.indigo,
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  Expanded(

                    child: Text(

                      insightText(),

                      style:
                          const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // =========================
            // COGNITIVE TESTS
            // =========================

   
            Text(

  AppStrings.text(
    "cognitive_activities",
    currentLanguage,
  ),

  style: const TextStyle(

    fontSize: 22,

    fontWeight:
        FontWeight.bold,
  ),
),

            const SizedBox(
              height: 16,
            ),

            _modernNavButton(
  context,
  AppStrings.text(
    "memory_recall",
    currentLanguage,
  ),
  AppStrings.text(
    "memory_subtitle",
    currentLanguage,
  ),
  Icons.memory,
  const MemoryTestScreen(),
),

_modernNavButton(
  context,
  AppStrings.text(
    "digit_span",
    currentLanguage,
  ),
  AppStrings.text(
    "attention_memory",
    currentLanguage,
  ),
  Icons.pin,
  const DigitSpanScreen(),
),

_modernNavButton(
  context,
  AppStrings.text(
    "sequencing_task",
    currentLanguage,
  ),
  AppStrings.text(
    "executive_analysis",
    currentLanguage,
  ),
  Icons.route,
  const TrailMakingScreen(),
),

_modernNavButton(
  context,
  AppStrings.text(
    "visuospatial_task",
    currentLanguage,
  ),
  AppStrings.text(
    "visual_cognition",
    currentLanguage,
  ),
  Icons.grid_view,
  const VisuospatialTaskScreen(),
),

_modernNavButton(
  context,
  AppStrings.text(
    "vigilance_test",
    currentLanguage,
  ),
  AppStrings.text(
    "attention_monitoring",
    currentLanguage,
  ),
  Icons.visibility,
  const VigilanceTestScreen(),
),

_modernNavButton(
  context,
  AppStrings.text(
    "mental_calculation",
    currentLanguage,
  ),
  AppStrings.text(
    "processing_speed",
    currentLanguage,
  ),
  Icons.calculate,
  const SerialSubtractionScreen(),
),

            const SizedBox(
              height: 30,
            ),

            // =========================
            // AI ASSISTANT
            // =========================

            Container(

              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                22,
              ),

              decoration:
                  BoxDecoration(

                gradient:
                    const LinearGradient(

                  colors: [

                    Color(
                      0xFF111827,
                    ),

                    Color(
                      0xFF1F2937,
                    ),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Row(

                    children: [

                      Container(

                        padding:
                            const EdgeInsets.all(
                          12,
                        ),

                        decoration:
                            BoxDecoration(

                          color: Colors
                              .white
                              .withOpacity(
                            0.12,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),

                        child: const Icon(

                          Icons.smart_toy,

                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(

                        child: Text(

                          AppStrings.text(
                            "ai_assistant",
                            currentLanguage,
                          ),

                          style:
                              const TextStyle(

                            color:
                                Colors.white,

                            fontSize: 20,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Text(

  AppStrings.text(
    "ai_description",
    currentLanguage,
  ),

  style: const TextStyle(

    color: Colors.white70,

    fontSize: 15,

    height: 1.5,
  ),
),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(

                    width:
                        double.infinity,

                    child:
                        ElevatedButton.icon(

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.white,

                        foregroundColor:
                            Colors.black,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        shape:
                            RoundedRectangleBorder(

                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),

                      icon: const Icon(
                        Icons.chat,
                      ),

                      label: Text(

                        AppStrings.text(
                          "ai_assistant",
                          currentLanguage,
                        ),
                      ),

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const AIChatScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =========================
            // SUMMARY BUTTON
            // =========================

            SizedBox(

              width:
                  double.infinity,

              child:
                  OutlinedButton.icon(

                style:
                    OutlinedButton.styleFrom(

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                icon: const Icon(
                  Icons.analytics,
                ),

                label: Text(

                  AppStrings.text(
                    "summary",
                    currentLanguage,
                  ),
                ),

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          const ClinicianSummaryScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewCard(

    String title,

    String value,

    IconData icon,

    Color color,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(

            value,

            style: TextStyle(

              fontSize: 24,

              fontWeight:
                  FontWeight.bold,

              color: color,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(

            title,

            style:
                const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernNavButton(

    BuildContext context,

    String title,

    String subtitle,

    IconData icon,

    Widget screen,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child: Material(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        child: InkWell(

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          onTap: () async {

            await Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    screen,
              ),
            );

            loadStatus();
          },

          child: Padding(

            padding:
                const EdgeInsets.all(
              18,
            ),

            child: Row(

              children: [

                Container(

                  padding:
                      const EdgeInsets.all(
                    14,
                  ),

                  decoration:
                      BoxDecoration(

                    color: Colors
                        .indigo
                        .withOpacity(
                      0.1,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  child: Icon(

                    icon,

                    color:
                        Colors.indigo,
                  ),
                ),

                const SizedBox(
                  width: 16,
                ),

                Expanded(

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(

                        title,

                        style:
                            const TextStyle(

                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        subtitle,

                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(

                  Icons
                      .arrow_forward_ios,

                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}