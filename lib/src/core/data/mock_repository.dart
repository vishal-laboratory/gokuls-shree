import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/features/courses/domain/course_entity.dart';
import 'package:gokul_shree_app/src/features/home/domain/notice.dart';

/// Mock repository providing real data from gokulshreeschool.com
/// Used when backend is unavailable or for offline mode
class MockRepository {
  // ============================================
  // DIPLOMA COURSES (from gokulshreeschool.com)
  // ============================================
  List<Course> getCourses() {
    return [
      // Certificates
      const Course(
        id: '1',
        title: 'Certificate In Computer Awareness (CCA)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '2',
        title: 'Certificate In Internet Application (CIA)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '3',
        title: 'Certificate In Typing Master (CTM)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '4',
        title: 'Certificate In Office Applications (COA)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '5',
        title: 'Certificate In Computer Fundamentals (CCF)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '6',
        title: 'Certificate In Information Technology (CIT)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '7',
        title: 'Certificate In Desk Top Publishing (CDTP)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '8',
        title: 'Certificate In Financial Accounting (CFA)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '9',
        title: 'Certificate In Tally (CTALLY)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '10',
        title: 'Certificate In Python (CIP)',
        category: 'Diploma',
        duration: '3 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      // Diplomas
      const Course(
        id: '11',
        title: 'Diploma In Information Technology (DIT)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '12',
        title: 'Diploma In Computer Application (DCA)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '13',
        title: 'Diploma In Computer Programming (DCP)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '14',
        title: 'Diploma in AutoCad (DAC)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '15',
        title: 'Diploma Course In Web Designing (DCWD)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '16',
        title: 'Diploma In Computer Science (DCS)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '17',
        title: 'Diploma in Data Entry Operation (DDEO)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '18',
        title: 'Diploma In MS-OFFICE (DMSO)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '19',
        title: 'Diploma in Financial Accounting (DFA)',
        category: 'Diploma',
        duration: '6 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      // Advanced Diplomas
      const Course(
        id: '20',
        title: 'Advance Diploma In Computer Application (ADCA)',
        category: 'Diploma',
        duration: '1 Year',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '21',
        title: 'Advance Diploma In Information Technology (ADIT)',
        category: 'Diploma',
        duration: '1 Year',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '22',
        title: 'Advance Diploma In Computer Hardware & Networking (ADCHN)',
        category: 'Diploma',
        duration: '1 Year',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '23',
        title: 'PGDCA (Post Graduation Diploma in Computer Application)',
        category: 'Diploma',
        duration: '1 Year',
        eligibility: 'Graduation',
        imagePath: '',
      ),
      const Course(
        id: '24',
        title: 'PGDBA (Post Graduation Diploma in Business Administration)',
        category: 'Diploma',
        duration: '1 Year',
        eligibility: 'Graduation',
        imagePath: '',
      ),

      // VOCATIONAL COURSES
      const Course(
        id: '30',
        title: 'Certificate in Mobile Repairing Course (CMRC)',
        category: 'Vocational',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '31',
        title: 'Certificate in AC Repairing & Maintenance (CARM)',
        category: 'Vocational',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '32',
        title: 'Diploma in Fashion Designing (DFD)',
        category: 'Vocational',
        duration: '1 Year',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '33',
        title: 'Diploma in Interior Designing (DID)',
        category: 'Vocational',
        duration: '1 Year',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '34',
        title: 'Diploma in Beautician (DIB)',
        category: 'Vocational',
        duration: '6 Months',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '35',
        title: 'Diploma in Dress Designing (DDD)',
        category: 'Vocational',
        duration: '1 Year',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '36',
        title: 'Advanced Diploma in Cutting & Tailoring (ADACT)',
        category: 'Vocational',
        duration: '1 Year',
        eligibility: '10th Pass',
        imagePath: '',
      ),
      const Course(
        id: '37',
        title: 'Advance Diploma in Fashion Designing (ADFD)',
        category: 'Vocational',
        duration: '18 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '38',
        title: 'Diploma in Retail Management (DRM)',
        category: 'Vocational',
        duration: '6 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '39',
        title: 'Diploma in Dance and Music (DDM)',
        category: 'Vocational',
        duration: '1 Year',
        eligibility: '10th Pass',
        imagePath: '',
      ),

      // YOGA COURSES
      const Course(
        id: '50',
        title: 'Diploma In Yoga Teacher Training (DYTT)',
        category: 'Yoga',
        duration: '1 Year',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '51',
        title: 'Advance Diploma In Yoga Teacher Training (ADYTT)',
        category: 'Yoga',
        duration: '18 Months',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '52',
        title: 'Post Graduate Diploma In Yoga (PGDY)',
        category: 'Yoga',
        duration: '1 Year',
        eligibility: 'Graduation',
        imagePath: '',
      ),

      // UNIVERSITY COURSES
      const Course(
        id: '60',
        title: 'Bachelor of Arts (B.A.)',
        category: 'University',
        duration: '3 Years',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '61',
        title: 'Bachelor of Computer Application (BCA)',
        category: 'University',
        duration: '3 Years',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '62',
        title: 'Bachelor of Business Administration (BBA)',
        category: 'University',
        duration: '3 Years',
        eligibility: '12th Pass',
        imagePath: '',
      ),
      const Course(
        id: '63',
        title: 'Bachelor of Science (B.Sc)',
        category: 'University',
        duration: '3 Years',
        eligibility: '12th Pass (Science)',
        imagePath: '',
      ),
      const Course(
        id: '64',
        title: 'Master of Information Technology (M.Sc.IT)',
        category: 'University',
        duration: '2 Years',
        eligibility: 'Graduation',
        imagePath: '',
      ),
      const Course(
        id: '65',
        title: 'Master of Science (M.Sc)',
        category: 'University',
        duration: '2 Years',
        eligibility: 'B.Sc',
        imagePath: '',
      ),
      const Course(
        id: '66',
        title: 'Master of Arts (MA)',
        category: 'University',
        duration: '2 Years',
        eligibility: 'B.A.',
        imagePath: '',
      ),
      const Course(
        id: '67',
        title: 'Post Graduate Diploma in Computer Application (PGDCA)',
        category: 'University',
        duration: '1 Year',
        eligibility: 'Graduation',
        imagePath: '',
      ),
      const Course(
        id: '68',
        title: 'Post Graduate Diploma in Human Resource Management (PGDHRM)',
        category: 'University',
        duration: '1 Year',
        eligibility: 'Graduation',
        imagePath: '',
      ),
    ];
  }

  List<Notice> getLatestNotices() {
    final now = DateTime.now();
    return [
      Notice(
        id: '1',
        title: 'CCC, BCC & O LEVEL - ADMISSION OPEN',
        date: now.subtract(const Duration(days: 1)),
      ),
      Notice(
        id: '2',
        title: 'New Session 2025-26 Registration Started',
        date: now.subtract(const Duration(days: 3)),
      ),
      Notice(
        id: '3',
        title: 'O-Level Examination Schedule Released',
        date: now.subtract(const Duration(days: 5)),
      ),
      Notice(
        id: '4',
        title: 'ADCA Result Declared - Check Now',
        date: now.subtract(const Duration(days: 7)),
      ),
      Notice(
        id: '5',
        title: 'Certificate Distribution Program - 15th Feb',
        date: now.subtract(const Duration(days: 10)),
      ),
      Notice(
        id: '6',
        title: 'Python Programming Workshop - Register Now',
        date: now.subtract(const Duration(days: 14)),
      ),
    ];
  }
}

final mockRepositoryProvider = Provider<MockRepository>((ref) {
  return MockRepository();
});
