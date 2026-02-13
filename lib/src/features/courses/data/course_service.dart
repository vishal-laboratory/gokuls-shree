import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gokul_shree_app/src/features/courses/domain/course_entity.dart';

class CourseService {
  final SupabaseClient _client;

  CourseService(this._client);

  Future<List<Course>> getCourses({String? category}) async {
    try {
      var query = _client.from('courses').select().eq('is_active', true);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query.order('title');

      return (response as List)
          .map(
            (json) => Course(
              id: json['id'].toString(),
              title: json['title'] ?? '',
              category: json['category'] ?? '',
              duration: json['duration'] ?? '',
              eligibility: json['eligibility'],
              imagePath: json['image_url'] ?? '',
            ),
          )
          .toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<Course?> getCourseById(String id) async {
    try {
      final json = await _client
          .from('courses')
          .select()
          .eq('id', int.parse(id))
          .single();

      return Course(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        category: json['category'] ?? '',
        duration: json['duration'] ?? '',
        eligibility: json['eligibility'],
        imagePath: json['image_url'] ?? '',
      );
    } catch (e) {
      print('Error fetching course: $e');
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _client
          .from('courses')
          .select('category')
          .eq('is_active', true);

      final categories = <String>{};
      for (final row in response) {
        if (row['category'] != null) {
          categories.add(row['category'] as String);
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}

// Provider
final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService(Supabase.instance.client);
});

// Courses data provider
final coursesProvider = FutureProvider.family<List<Course>, String?>((
  ref,
  category,
) async {
  final courseService = ref.watch(courseServiceProvider);
  return courseService.getCourses(category: category);
});
