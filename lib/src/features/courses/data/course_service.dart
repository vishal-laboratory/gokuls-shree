import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/services/api_client.dart';
import 'package:gokul_shree_app/src/features/courses/domain/course_entity.dart';

class CourseService {
  final ApiClient _apiClient;

  CourseService(this._apiClient);

  Future<List<Course>> getCourses({String? category}) async {
    try {
      final queryParams = category != null ? {'category': category} : null;
      final response = await _apiClient.get(
        '/courses',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> coursesJson = response.data['courses'];
        return coursesJson
            .map(
              (json) => Course(
                id: json['id'],
                title: json['title'],
                category: json['category'],
                duration: json['duration'] ?? '',
                eligibility: json['eligibility'],
                imagePath: json['imageUrl'] ?? '',
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<Course?> getCourseById(String id) async {
    try {
      final response = await _apiClient.get('/courses/$id');

      if (response.statusCode == 200) {
        final json = response.data;
        return Course(
          id: json['id'],
          title: json['title'],
          category: json['category'],
          duration: json['duration'] ?? '',
          eligibility: json['eligibility'],
          imagePath: json['imageUrl'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching course: $e');
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/courses/meta/categories');

      if (response.statusCode == 200) {
        return List<String>.from(response.data['categories']);
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}

// Provider
final courseServiceProvider = Provider<CourseService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CourseService(apiClient);
});

// Courses data provider
final coursesProvider = FutureProvider.family<List<Course>, String?>((
  ref,
  category,
) async {
  final courseService = ref.watch(courseServiceProvider);
  return courseService.getCourses(category: category);
});
