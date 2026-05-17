import 'dart:convert';
import '../ai/ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../storage/local_store.dart';

// Tests
import '../tests/memory_test_screen.dart';
import '../tests/digit_span_screen.dart';
import '../tests/trail_making_screen.dart';
import '../tests/visuospatial_task_screen.dart';
import '../tests/vigilance_test_screen.dart';
import '../tests/serial_subtraction_screen.dart';


// Summary
import '../summary/clinician_summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int weeksCompleted = 0;

  String currentUserName = "";
  String currentUserId = "";

  @override
  void initState() {
    super.initState();

    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final userId =
        await LocalStore.getCurrentUser();

    if (userId == null) return;

    final prefs =
        await SharedPreferences.getInstance();

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

    final currentUser = users.firstWhere(
      (u) => u["userId"] == userId,
      orElse: () => {},
    );

    setState(() {
      currentUserId = userId;

      currentUserName =
          currentUser["name"] ?? "User";
    });

    loadStatus();
  }

  Future<void> loadStatus() async {
    if (currentUserId.isEmpty) return;

    final count =
        await LocalStore.getWeekCount(
      currentUserId,
    );

    setState(() {
      weeksCompleted = count;
    });
  }

  String insightText() {
    if (weeksCompleted < 3) {
      return "Baseline is still being established.";
    } else {
      return "Enough data collected to view clinician summary.";
    }
  }

  Color progressColor() {
    if (weeksCompleted < 2) {
      return Colors.orange;
    } else if (weeksCompleted < 4) {
      return Colors.indigo;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final displayWeek =
        weeksCompleted < 4
            ? weeksCompleted + 1
            : weeksCompleted;

    return Scaffold(
      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "NeuroSense",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =========================
            // HEADER CARD
            // =========================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                22,
              ),
              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF6366F1),
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
                  const Text(
                    "Current Patient",
                    style: TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  Text(
                    currentUserName,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                      height: 18),

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
                            width:
                                10),

                        Expanded(
                          child: Text(
                            weeksCompleted <
                                    4
                                ? "Baseline Week $displayWeek of 4"
                                : "Longitudinal Tracking Active",
                            style:
                                const TextStyle(
                              color: Colors
                                  .white,
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

            const SizedBox(height: 24),

            // =========================
            // QUICK OVERVIEW
            // =========================

            Row(
              children: [
                Expanded(
                  child: _overviewCard(
                    "Weeks",
                    weeksCompleted
                        .toString(),
                    Icons.calendar_today,
                    progressColor(),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _overviewCard(
                    "Status",
                    weeksCompleted <
                            4
                        ? "Baseline"
                        : "Tracking",
                    Icons.psychology,
                    Colors.indigo,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // =========================
            // INSIGHT CARD
            // =========================

            Container(
              width: double.infinity,
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
                      width: 16),

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

            const SizedBox(height: 30),

            // =========================
            // COGNITIVE TESTS
            // =========================

            const Text(
              "Cognitive Activities",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _modernNavButton(
              context,
              "Memory Recall",
              "Word retention and episodic memory",
              Icons.memory,
              MemoryTestScreen(),
            ),

            _modernNavButton(
              context,
              "Digit Span",
              "Attention and working memory",
              Icons.pin,
              DigitSpanScreen(),
            ),

            _modernNavButton(
              context,
              "Sequencing Task",
              "Executive function analysis",
              Icons.route,
              TrailMakingScreen(),
            ),

            _modernNavButton(
              context,
              "Visuospatial Task",
              "Visual cognition assessment",
              Icons.grid_view,
              VisuospatialTaskScreen(),
            ),

            _modernNavButton(
              context,
              "Vigilance Test",
              "Sustained attention monitoring",
              Icons.visibility,
              VigilanceTestScreen(),
            ),

            _modernNavButton(
              context,
              "Mental Calculation",
              "Processing speed and concentration",
              Icons.calculate,
              SerialSubtractionScreen(),
            ),

            const SizedBox(height: 30),

            // =========================
            // DEMO MODE
            // =========================

            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
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
                  Icons.science,
                ),

                label: const Text(
                  "Load Demo Data",
                ),

                onPressed: () async {
                  await LocalStore
                      .injectDemoData();

                  await loadStatus();

                  if (mounted) {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Demo data loaded successfully.",
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 10),

// =========================
// AI ASSISTANT
// =========================

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF111827),
        Color(0xFF1F2937),
      ],
    ),
    borderRadius:
        BorderRadius.circular(22),
  ),

  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
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
              color: Colors.white
                  .withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              "NeuroSense AI Assistant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),

      const Text(
        "Ask questions about cognitive health, memory trends, caregiver support, and NeuroSense analytics.",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 15,
          height: 1.5,
        ),
      ),

      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
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

          label: const Text(
            "Open AI Assistant",
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

            // =========================
            // SUMMARY BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
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

                label: const Text(
                  "View Clinician Summary",
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

            const SizedBox(height: 30),
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
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(
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
                builder: (_) => screen,
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

                const SizedBox(width: 16),

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
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                          height:
                              4),

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