import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/exam_model.dart';

final examRepositoryProvider = Provider((ref) {
  return ExamRepository(Supabase.instance.client);
});

class ExamRepository {
  final SupabaseClient _client;

  ExamRepository(this._client);

  /// Get available paper sets (exams) for a course
  Future<List<Exam>> getExams({int? courseId}) async {
    var query = _client
        .from('paper_sets')
        .select('*, courses(title)')
        .eq('is_active', true);

    if (courseId != null) {
      query = query.eq('course_id', courseId);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map(
          (e) => Exam.fromJson({
            'id': e['id'].toString(),
            'title': e['title'] ?? e['courses']?['title'] ?? 'Exam',
            'duration_minutes': e['duration_minutes'] ?? 60,
            'total_marks': e['total_marks'] ?? 100,
            'questions_count': e['total_questions'] ?? 0,
          }),
        )
        .toList();
  }

  /// Get questions for a paper set
  Future<List<Question>> getQuestions(String paperSetId) async {
    final response = await _client
        .from('questions')
        .select()
        .eq('paper_set_id', int.parse(paperSetId))
        .order('question_number');

    return (response as List)
        .map(
          (e) => Question.fromJson({
            'id': e['id'].toString(),
            'text': e['question_text'] ?? '',
            'options': [
              e['option_a'] ?? '',
              e['option_b'] ?? '',
              e['option_c'] ?? '',
              e['option_d'] ?? '',
            ],
            'correct_option_index': _optionToIndex(e['correct_option']),
          }),
        )
        .toList();
  }

  /// Start an exam session
  Future<String?> startExamSession({
    required String paperSetId,
    required String studentId,
  }) async {
    final response = await _client
        .from('exam_sessions')
        .insert({
          'paper_set_id': int.parse(paperSetId),
          'student_id': studentId,
          'started_at': DateTime.now().toIso8601String(),
          'status': 'in_progress',
        })
        .select('id')
        .single();

    return response['id']?.toString();
  }

  /// Submit an answer
  Future<void> submitAnswer({
    required String sessionId,
    required String questionId,
    required String selectedOption,
  }) async {
    await _client.from('exam_answers').upsert({
      'session_id': int.parse(sessionId),
      'question_id': int.parse(questionId),
      'selected_option': selectedOption,
      'answered_at': DateTime.now().toIso8601String(),
    });
  }

  /// Finish an exam session
  Future<Map<String, dynamic>?> finishExam(String sessionId) async {
    // Update session status
    await _client
        .from('exam_sessions')
        .update({
          'finished_at': DateTime.now().toIso8601String(),
          'status': 'completed',
        })
        .eq('id', int.parse(sessionId));

    // Calculate and return results
    final result = await _client
        .from('exam_results')
        .select()
        .eq('session_id', int.parse(sessionId))
        .maybeSingle();

    return result;
  }

  /// Get student's past exam results
  Future<List<Map<String, dynamic>>> getMyResults() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('exam_sessions')
        .select('*, paper_sets(title, total_marks), exam_results(*)')
        .eq('student_id', userId)
        .eq('status', 'completed')
        .order('finished_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  int _optionToIndex(String? option) {
    switch (option?.toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return 0;
    }
  }
}
