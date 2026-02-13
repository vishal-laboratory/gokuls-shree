import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import 'package:gokul_shree_app/src/core/widgets/profile_image_picker.dart';
import 'package:gokul_shree_app/src/core/data/attendance_repository.dart';
import 'package:gokul_shree_app/src/features/auth/data/supabase_auth_service.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(supabaseAuthProvider);

    // If not authenticated, redirect to login
    if (authState is! AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final studentData = authState.studentData;

    // Get display name from auth metadata or student data
    final displayName =
        user.userMetadata?['name'] as String? ??
        studentData?['name'] as String? ??
        user.email?.split('@').first ??
        'Student';

    final regNo = studentData?['registration_number'] as String? ?? 'N/A';
    final courseName = studentData?['course_name'] as String?;
    final sessionYear = studentData?['session_year'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(supabaseAuthProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Profile Image with upload capability
                    ProfileImagePicker(
                      userId: user.id,
                      currentImageUrl: studentData?['photo_url'] as String?,
                      size: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Reg No: $regNo',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (user.email != null)
                            Text(
                              user.email!,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          if (courseName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$courseName ${sessionYear != null ? "($sessionYear)" : ""}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // Dashboard Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _DashboardCard(
                  icon: Icons.card_membership,
                  title: 'Admit Card',
                  color: Colors.blue,
                  onTap: () => _showComingSoon(context, 'Admit Card'),
                ),
                _DashboardCard(
                  icon: Icons.article,
                  title: 'View Results',
                  color: Colors.green,
                  onTap: () => _showComingSoon(context, 'Results'),
                ),
                _DashboardCard(
                  icon: Icons.verified,
                  title: 'My Documents',
                  color: Colors.orange,
                  onTap: () => _showComingSoon(context, 'My Documents'),
                ),
                _DashboardCard(
                  icon: Icons.quiz,
                  title: 'Online Exam',
                  color: Colors.purple,
                  onTap: () => _showComingSoon(context, 'Online Exam'),
                ),
                _DashboardCard(
                  icon: Icons.payment,
                  title: 'Pay Fees',
                  color: Colors.teal,
                  onTap: () => _showComingSoon(context, 'Pay Fees'),
                ),
                _DashboardCard(
                  icon: Icons.download,
                  title: 'Downloads',
                  color: Colors.indigo,
                  onTap: () => _showComingSoon(context, 'Downloads'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // My Enrolled Courses with Attendance
            Text(
              'My Courses & Attendance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildEnrolledCoursesSection(studentData?['id']?.toString(), ref),

            const SizedBox(height: 24),

            // Announcements Section
            Text(
              'Announcements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.campaign,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                title: const Text('Welcome to Student Portal!'),
                subtitle: const Text(
                  'Access your admit cards, results, and more',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.green),
                ),
                title: const Text('Session 2025-26'),
                subtitle: const Text('New session registrations open'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildEnrolledCoursesSection(String? studentId, WidgetRef ref) {
    if (studentId == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unable to load courses',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final attendanceAsync = ref.watch(
      studentCourseAttendanceProvider(studentId),
    );

    return attendanceAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No courses enrolled yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: courses.map((course) {
            final percentage =
                (course['percentage'] as num?)?.toDouble() ?? 0.0;
            final attended = course['attended'] as int? ?? 0;
            final totalClasses = course['total_classes'] as int? ?? 0;
            final color = percentage >= 75
                ? Colors.green
                : percentage >= 50
                ? Colors.orange
                : Colors.red;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Course icon with color
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.book, color: color, size: 28),
                    ),
                    const SizedBox(width: 12),
                    // Course details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['course_title'] as String? ??
                                'Unknown Course',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Attended: $attended / $totalClasses classes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Attendance percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error loading courses: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
