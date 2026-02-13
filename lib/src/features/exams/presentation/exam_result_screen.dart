import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';

class ExamResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String examTitle;

  const ExamResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.examTitle,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions) * 100;
    final isPassed = percentage >= 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 80,
                color: isPassed ? Colors.amber : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                isPassed ? 'Congratulations!' : 'Better Luck Next Time!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have completed $examTitle',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isPassed
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPassed ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  children: [
                    const Text('Your Score', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $totalQuestions',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/'); // Go Home
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
