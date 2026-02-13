import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/services/supabase_service.dart';

/// Admin repository for CRUD operations on courses, notices, and students
/// Only accessible by admin users
class AdminRepository {
  // ===========================================
  // COURSES CRUD
  // ===========================================

  /// Get all courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await supabase
        .from('courses')
        .select()
        .order('category')
        .order('title');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add a new course
  Future<Map<String, dynamic>> addCourse({
    required String title,
    required String category,
    required String duration,
    required String eligibility,
    String? imageUrl,
    String? description,
    int totalClasses = 0,
  }) async {
    final response = await supabase
        .from('courses')
        .insert({
          'title': title,
          'category': category,
          'duration': duration,
          'eligibility': eligibility,
          'image_url': imageUrl,
          'description': description,
          'total_classes': totalClasses,
          'is_active': true,
        })
        .select()
        .single();
    return response;
  }

  /// Update a course
  Future<Map<String, dynamic>> updateCourse({
    required String id,
    String? title,
    String? category,
    String? duration,
    String? eligibility,
    String? imageUrl,
    String? description,
    int? totalClasses,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (category != null) updates['category'] = category;
    if (duration != null) updates['duration'] = duration;
    if (eligibility != null) updates['eligibility'] = eligibility;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (description != null) updates['description'] = description;
    if (totalClasses != null) updates['total_classes'] = totalClasses;

    final response = await supabase
        .from('courses')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete a course
  Future<void> deleteCourse(String id) async {
    await supabase.from('courses').delete().eq('id', id);
  }

  // ===========================================
  // NOTICES CRUD
  // ===========================================

  /// Get all notices
  Future<List<Map<String, dynamic>>> getNotices() async {
    final response = await supabase
        .from('notices')
        .select()
        .order('published_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add a new notice
  Future<Map<String, dynamic>> addNotice({
    required String title,
    required String category,
    String? content,
    String? link,
    String status = 'published',
    bool showAuthor = false,
  }) async {
    final user = supabase.auth.currentUser;
    final authorName = user?.userMetadata?['name'] ?? user?.email ?? 'Admin';

    final response = await supabase
        .from('notices')
        .insert({
          'title': title,
          'category': category,
          'content': content,
          'link': link,
          'status': status,
          'show_author': showAuthor,
          'author_name': authorName,
          'is_active': true,
          'published_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return response;
  }

  /// Update a notice
  Future<Map<String, dynamic>> updateNotice({
    required String id,
    String? title,
    String? category,
    String? content,
    String? link,
    String? status,
    bool? showAuthor,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (category != null) updates['category'] = category;
    if (content != null) updates['content'] = content;
    if (link != null) updates['link'] = link;
    if (status != null) updates['status'] = status;
    if (showAuthor != null) updates['show_author'] = showAuthor;

    final response = await supabase
        .from('notices')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete a notice
  Future<void> deleteNotice(String id) async {
    await supabase.from('notices').delete().eq('id', id);
  }

  // ===========================================
  // STUDENTS CRUD
  // ===========================================

  /// Get all students
  Future<List<Map<String, dynamic>>> getStudents() async {
    final response = await supabase.from('students').select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add a new student
  Future<Map<String, dynamic>> addStudent({
    required String name,
    required String email,
    required String registrationNumber,
    String? phone,
    String? courseId,
    String? photoUrl,
  }) async {
    final response = await supabase
        .from('students')
        .insert({
          'name': name,
          'email': email,
          'registration_number': registrationNumber,
          'phone': phone,
          'course_id': courseId,
          'photo_url': photoUrl,
          'is_active': true,
        })
        .select()
        .single();
    return response;
  }

  /// Update a student
  Future<Map<String, dynamic>> updateStudent({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? courseId,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (courseId != null) updates['course_id'] = courseId;
    if (photoUrl != null) updates['photo_url'] = photoUrl;

    final response = await supabase
        .from('students')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete a student
  Future<void> deleteStudent(String id) async {
    await supabase.from('students').delete().eq('id', id);
  }

  // ===========================================
  // DOWNLOADS CRUD
  // ===========================================

  /// Get all downloads
  Future<List<Map<String, dynamic>>> getDownloads() async {
    final response = await supabase.from('downloads').select().order('title');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add a new download
  Future<Map<String, dynamic>> addDownload({
    required String title,
    required String category,
    required String url,
    String? description,
  }) async {
    final response = await supabase
        .from('downloads')
        .insert({
          'title': title,
          'category': category,
          'url': url,
          'description': description,
        })
        .select()
        .single();
    return response;
  }

  /// Delete a download
  Future<void> deleteDownload(String id) async {
    await supabase.from('downloads').delete().eq('id', id);
  }
  // ===========================================
  // DASHBOARD STATS (MOCK)
  // ===========================================

  Future<Map<String, dynamic>> getDashboardStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    return {
      'todays_collection': 45200,
      'collection_growth': 12, // percentage
      'present_students': 845,
      'total_students': 900,
      'attendance_rate': 94,
      'pending_enquiries': 12,
      'new_enquiries': true,
    };
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    return [
      {
        'name': 'Aarav Patel',
        'class': 'Class 5B',
        'type': 'Tuition Fee',
        'amount': 12000,
        'time': '10:30 AM',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCWSHhaZ8O90DgfOHsoFGzrX-t82eyc7IsSYBnqzAh4bPyFls3e-a2uTz_LDK-Wu1Quv0XONkR8mwemYReXNYLlOdi7Lak2pM-ySIxoPknF39kk-U319dmDtlZWYyyfWkSWJ_GWgsGWVebOqtbw32q2CiL056gEziBCwTUu2HVwBBxaYt2wUDcYj_gAWAyWC4Tm5B_0cgaIrvTARcgIEbDCP4Yq25YYDrQ7TFfILqiNkznnnQ0fRxycR0mxSJL6cVQvQdVibR3IGPY',
      },
      {
        'name': 'Sneha Gupta',
        'class': 'Class 10A',
        'type': 'Exam Fee',
        'amount': 8500,
        'time': '10:15 AM',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAa-_STepkMgxKOk8C1Kck9qLnvH49pk-lZL8lvTQmgLXFjQbhxs5U9jMmqxCLmzy_kT-C1TLlc66apqhCZEbn9K244cm_FuvWavydcsj1VwwPewU2-vMxHbHs9E0T5Ja2aY8VAvqdKFcZ3SnKb3UUGP6DkKSlebBCzO-D_FRFziCKtxiPk6jhdLaMC5ORkNfxs_BYC4M9-mp2GI7QAohf0GJU_541fPpaS6f9sj2MTX-P443hJ6phW02IBTCUHECHalZdhx9r6YHM',
      },
      {
        'name': 'Rohan Mehta',
        'class': 'Class 8C',
        'type': 'Transport',
        'amount': 4200,
        'time': '09:45 AM',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDc0u7vdY0MIxsFHuXCYq2-EX8vfQVLhzXEFNKMtTnhACktdNada33DXOeg5AxOkMIWHwyj-ReN9jdgowDV7fdDF3SNfyo1bP3Wns94uiEWlMb8iD5-oFg2MVK4iVLsTKtpUQetFV1i29l0Ko8stOLrtggBXg0CgMqNsAWAlY1drAV49xDZMYdUfCzisDJVMGVWHCWfDL7w4CxwnUnhoAjlKHJkJXnY_mNnVNdId0Mwk0zz-2TT3G--0iTz6g0WcB0KuJa-MFL1I-8',
      },
      {
        'name': 'Ananya Singh',
        'class': 'Class 6A',
        'type': 'Library Fine',
        'amount': 150,
        'time': '09:20 AM',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAIk1G3rT8x5eH0RtpP4SWG0qaRSOMwyiKPoafwxJVguElkFy-ucp5Yy0U_9-mTPLolGPRmKBDzwIY-6R6rBMjtHsGvOVHW0dCJh9h5CDcH6HaGvzkG65tgfi7oGPyA5TFmYKvuba4nbKkD_r5LEaVhdQR30TgD89RGz6oXxrM6_T-Jzadfo1qv-4XYmdtOL9loXI24TxL8nBhIpC9iRpDOR4Qlaia4tdyRoEjwoFPc4nf18Ax5eyF1geaJInKfNQW8Lhz7167tRPk',
      },
    ];
  }

  Future<void> collectFee({
    required String studentId,
    required double amount,
    required String date,
    required String paymentMode,
    String? remarks,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // In a real app, this would POST to /new/fee_submit.php
    // with data: {'id': studentId, 'newamt': amount, 'doj': date, 'cheque': paymentMode, 'remarks': remarks}

    // Success implied if no error thrown
  }

  Future<Map<String, dynamic>> generateAdmitCard({
    required String studentId,
    required String examId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    // Simulate generation
    return {
      'url':
          'https://www.gokulshreeschool.com/admit_cards/2025/REG$studentId.pdf',
      'generated_at': DateTime.now().toIso8601String(),
      'status': 'Generated',
    };
  }

  Future<Map<String, dynamic>> verifyAdmitCard(String qrCode) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Mock logic: Valid if starts with 'ADM'
    final isValid = qrCode.startsWith('ADM');
    return {
      'is_valid': isValid,
      'student_name': isValid ? 'Verified Student' : null,
      'exam_date': isValid ? '2025-03-15' : null,
      'message': isValid ? 'Entry Allowed' : 'Invalid Admit Card QR',
    };
  }

  // ===========================================
  // STAFF CRUD
  // ===========================================

  /// Get all staff members
  Future<List<Map<String, dynamic>>> getStaff() async {
    final response = await supabase.from('staff').select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Add a new staff member
  Future<Map<String, dynamic>> addStaff({
    required String name,
    required String email,
    required String role,
    required String phone,
    String? photoUrl,
    String? joiningDate,
  }) async {
    final response = await supabase
        .from('staff')
        .insert({
          'name': name,
          'email': email,
          'role': role,
          'phone': phone,
          'photo_url': photoUrl,
          'joining_date': joiningDate ?? DateTime.now().toIso8601String(),
          'is_active': true,
        })
        .select()
        .single();
    return response;
  }

  /// Update a staff member
  Future<Map<String, dynamic>> updateStaff({
    required String id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (role != null) updates['role'] = role;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photo_url'] = photoUrl;

    final response = await supabase
        .from('staff')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete a staff member
  Future<void> deleteStaff(String id) async {
    await supabase.from('staff').delete().eq('id', id);
  }
}

/// Provider for AdminRepository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

/// Check if current user is admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = supabase.auth.currentUser;
  if (user == null) return false;

  // Check if user has admin role in metadata or in a separate admins table
  final isAdminMeta = user.userMetadata?['is_admin'] == true;
  if (isAdminMeta) return true;

  // Check hardcoded admin email first (for testing/bootstrap)
  if (user.email == 'admin@gokulshreeschool.com') return true;

  // Check admins table
  try {
    final response = await supabase
        .from('admins')
        .select('id')
        .eq('user_id', user.id)
        .maybeSingle();
    return response != null;
  } catch (e) {
    return false;
  }
});
