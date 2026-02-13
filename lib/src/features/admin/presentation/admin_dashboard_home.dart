import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import 'package:gokul_shree_app/src/core/data/admin_repository.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_notices_screen.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_profile_screen.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_staff_directory_screen.dart';

class AdminDashboardHome extends ConsumerStatefulWidget {
  const AdminDashboardHome({super.key});

  @override
  ConsumerState<AdminDashboardHome> createState() => _AdminDashboardHomeState();
}

class _AdminDashboardHomeState extends ConsumerState<AdminDashboardHome> {
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<Map<String, dynamic>>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final repo = ref.read(adminRepositoryProvider);
    _statsFuture = repo.getDashboardStats();
    _activitiesFuture = repo.getRecentActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8), // background-light
      body: CustomScrollView(
        slivers: [
          // Header with Welcome Message
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedDate(),
                        style: const TextStyle(
                          color: Color(0xFF64748B), // slate-500
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome, Admin',
                        style: TextStyle(
                          color: Color(0xFF0F172A), // slate-900
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.domain,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'BR-012',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminProfileScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryColor,
                          child: const Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final stats = snapshot.data ?? {};

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Primary Card: Fee Collection
                      _buildPrimaryCard(stats),
                      const SizedBox(height: 16),
                      // Secondary Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildSecondaryCard(
                              icon: Icons.groups,
                              iconColor: Colors.purple,
                              iconBg: Colors.purple.shade50,
                              label: 'Present Students',
                              value: '${stats['present_students']}',
                              subValue: '/${stats['total_students']}',
                              footerText: '${stats['attendance_rate']}% Rate',
                              footerColor: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSecondaryCard(
                              icon: Icons.assignment_late,
                              iconColor: Colors.orange,
                              iconBg: Colors.orange.shade50,
                              label: 'Pending Enquiries',
                              value: '${stats['pending_enquiries']} New',
                              subValue: '',
                              footerText: 'Action Req.',
                              footerColor: Colors.orange,
                              showBadge: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminNoticesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.campaign),
                      label: const Text('Notices'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminStaffDirectoryScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.badge),
                      label: const Text('Staff'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Recent Activity Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
              ),
            ),
          ),

          // Recent Activity List
          SliverFillRemaining(
            hasScrollBody: false, // Don't scroll inside scroll
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final activities = snapshot.data ?? [];
                  if (activities.isEmpty) {
                    return const Center(child: Text("No recent activity"));
                  }

                  return Column(
                    children: activities
                        .map((activity) => _buildActivityItem(activity))
                        .toList(),
                  );
                },
              ),
            ),
          ),
          // Padding for bottom nav
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildPrimaryCard(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            Color(0xFF2563EB), // slightly lighter blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative Circle (fake "Sparkle")
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.payments, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats['collection_growth']}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Today's Collection",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹ ${stats['todays_collection']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              // Simulated Progress Bar
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.65, // Mocked 65%
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String subValue,
    required String footerText,
    required Color footerColor,
    bool showBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)), // slate-200
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (showBadge)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B), // slate-500
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subValue.isNotEmpty)
                    Text(
                      subValue,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                footerText,
                style: TextStyle(
                  color: footerColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(activity['photo_url']),
              onBackgroundImageError: (_, __) => const Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activity['class']} • ${activity['type']}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+ ₹ ${activity['amount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  activity['time'],
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    // Simple mock date formatter
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return '${weekdays[now.weekday == 7 ? 0 : now.weekday]}, ${now.day} ${months[now.month - 1]}';
  }
}
