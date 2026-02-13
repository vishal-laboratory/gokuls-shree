import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import '../data/exam_repository.dart';
import '../domain/exam_model.dart';

final examListProvider = FutureProvider<List<Exam>>((ref) async {
  return ref.read(examRepositoryProvider).getExams();
});

class ExamListScreen extends ConsumerWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Online Exams')),
      body: examsAsync.when(
        data: (exams) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exams.length,
          itemBuilder: (context, index) {
            final exam = exams[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  exam.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('${exam.durationMinutes} mins'),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.question_answer_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('${exam.questionsCount} Questions'),
                      ],
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    context.push('/exams/${exam.id}', extra: exam);
                  },
                  child: const Text('Start'),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
