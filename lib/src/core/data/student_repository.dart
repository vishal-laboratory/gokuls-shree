import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/services/supabase_service.dart';

class StudentRepository {
  // Mock data for initial development
  Future<Map<String, dynamic>> getStudentProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'name': 'Gokul Kumar',
      'class_section': 'Science',
      'reg_no': 'GS-2024-08',
      'streak': 5,
      'photo_url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDFFvQQ22BKpqt_ehNksh5sfskzTDrPjqbB5FAOS284BPrDgycw6PeD-uuLuRlsy_rcsT62eQqsZREqtSHLOtouURTqnnVjOSpbnkE6_TaaYjcHupBL9-M7CgqTo7r94veV3AhaIt5_UMeR-rr-tF1V55cdACziSGixxXC6cbosJhgI1QF8gdfdwxYIo6VvMW1gOzKQTH-VN0xIg7D2BybHTlmbz7UCw_IPbEsI6xBVL-nelPfbjDNpgPLp6uKLMElQuTx3Y99p2GI',
    };
  }

  Future<Map<String, dynamic>> getAttendanceStats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {'percentage': 85, 'status': 'Great Progress!', 'trend': 'up'};
  }

  Future<List<Map<String, dynamic>>> getNotices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'title': 'Winter Vacation Schedule',
        'description':
            'The school will remain closed from Dec 24th to Jan 2nd.',
        'time': '2 hours ago',
        'type': 'campaign',
        'color': 'blue',
      },
      {
        'title': 'Final Project Deadline',
        'description': 'Please submit your science projects by next Friday.',
        'time': 'Yesterday',
        'type': 'event_note',
        'color': 'amber',
      },
    ];
  }
}

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});
