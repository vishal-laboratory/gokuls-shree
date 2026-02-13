import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gokul_shree_app/src/features/exams/domain/exam_model.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';

class ExamInstructionsScreen extends StatefulWidget {
  final Exam exam;

  const ExamInstructionsScreen({super.key, required this.exam});

  @override
  State<ExamInstructionsScreen> createState() => _ExamInstructionsScreenState();
}

class _ExamInstructionsScreenState extends State<ExamInstructionsScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Instructions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.exam.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Duration: ${widget.exam.durationMinutes} Minutes  |  Questions: ${widget.exam.questionsCount}",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 32),

            const Text(
              "Read Instructions Carefully:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildInstructionPoint(
              "1. Ensure you have a stable internet connection.",
            ),
            _buildInstructionPoint(
              "2. Do NOT switch tabs or minimize the app. Doing so may auto-submit your exam.",
            ),
            _buildInstructionPoint("3. Screenshots are strictly prohibited."),
            _buildInstructionPoint(
              "4. Once submitted, you cannot re-attempt the questions.",
            ),
            _buildInstructionPoint(
              "5. The timer will start immediately after you click 'Start Exam'.",
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Warning: App switching is monitored. Any attempt to leave the exam screen will be recorded.",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "I have read the instructions nicely and want to proceed.",
              ),
              value: _agreed,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) {
                setState(() {
                  _agreed = val ?? false;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _agreed
                    ? () {
                        // Navigate to Quiz (Start)
                        // Route: /exams/:id/start
                        context.pushReplacement(
                          '/exams/${widget.exam.id}/start',
                          extra: widget.exam,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Start Exam"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
