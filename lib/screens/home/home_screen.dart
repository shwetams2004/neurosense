import 'package:flutter/material.dart';
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int weeksCompleted = 0;

  @override
  void initState() {
    super.initState();
    loadStatus();
  }

  Future<void> loadStatus() async {
    final count = await LocalStore.getWeekCount();
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

  @override
  Widget build(BuildContext context) {
    final displayWeek =
        weeksCompleted < 4 ? weeksCompleted + 1 : weeksCompleted;

    return Scaffold(
      appBar: AppBar(title: const Text("NeuroSense")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Cognitive Activities",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Short activities to track cognitive changes over time.\n"
              "Not a medical diagnosis.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // =========================
            // COGNITIVE TESTS
            // =========================
            const Text(
              "Cognitive Tests",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _navButton(context, "Memory (Word Recall)", MemoryTestScreen()),
            _navButton(context, "Attention (Digit Span)", DigitSpanScreen()),
            _navButton(
                context, "Executive Function (Sequencing)", TrailMakingScreen()),
            _navButton(context, "Visuospatial Task", VisuospatialTaskScreen()),

            const SizedBox(height: 20),

            // =========================
            // ATTENTION & PROCESSING
            // =========================
            const Text(
              "Attention & Processing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _navButton(
                context, "Sustained Attention (Vigilance)", VigilanceTestScreen()),
            _navButton(context, "Mental Calculation (Serial Subtraction)",
                SerialSubtractionScreen()),

            const SizedBox(height: 20),

            // =========================
            // DEMO MODE
            // =========================
            OutlinedButton.icon(
              icon: const Icon(Icons.science),
              label: const Text("Enable Demo Mode (Sample Data)"),
              onPressed: () async {
                await LocalStore.injectDemoData();
                await loadStatus();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Demo data loaded. Clinician summary unlocked.",
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // =========================
            // INSIGHT CARD
            // =========================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.indigo),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insightText(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // CLINICIAN SUMMARY
            // =========================
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClinicianSummaryScreen(),
                  ),
                );
              },
              child: const Text("View Clinician Summary"),
            ),

            const SizedBox(height: 8),

            Text(
              weeksCompleted < 4
                  ? "Status: Establishing baseline (Week $displayWeek of 4)"
                  : "Baseline established. Ongoing tracking enabled.",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          child: Text(label),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
            loadStatus();
          },
        ),
      ),
    );
  }
}
