import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/services/api_client.dart';
import '../domain/exam_model.dart';

final examRepositoryProvider = Provider((ref) {
  return ExamRepository(ref.read(apiClientProvider));
});

class ExamRepository {
  final ApiClient _apiClient;

  ExamRepository(this._apiClient);

  Future<List<Exam>> getExams() async {
    final response = await _apiClient.get('/exams');
    // Handle Dio Response or Map
    final data = response.data;
    if (data['status'] == 'success') {
      return (data['data'] as List).map((e) => Exam.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Question>> getQuestions(String examId) async {
    final response = await _apiClient.get(
      '/exams/questions',
      queryParameters: {'exam_id': examId},
    );
    final data = response.data;
    if (data['status'] == 'success') {
      return (data['data'] as List).map((e) => Question.fromJson(e)).toList();
    }
    return [];
  }
}
