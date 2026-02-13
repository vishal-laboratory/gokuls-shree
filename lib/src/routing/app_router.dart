import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gokul_shree_app/src/features/home/presentation/public_home_screen.dart'; // NEW
import 'package:gokul_shree_app/src/features/home/presentation/menu_screen.dart';
import 'package:gokul_shree_app/src/features/auth/presentation/account_screen.dart';
import 'package:gokul_shree_app/src/features/auth/presentation/login_screen.dart';
import 'package:gokul_shree_app/src/features/auth/data/supabase_auth_service.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_panel_screen.dart';
import 'package:gokul_shree_app/src/features/student/presentation/student_dashboard_screen.dart';
import 'package:gokul_shree_app/src/features/documents/presentation/my_documents_screen.dart';
import 'package:gokul_shree_app/src/features/documents/presentation/verification_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_list_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_quiz_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_result_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_instructions_screen.dart';
import 'package:gokul_shree_app/src/features/exams/domain/exam_model.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(supabaseAuthNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier, // Listen to auth changes
    redirect: (context, state) {
      final isLoggedIn = ref.read(supabaseAuthProvider) is AuthAuthenticated;
      final isPublicRoute = state.uri.path == '/' || state.uri.path == '/login';

      // 1. If NOT logged in and trying to access protected route -> Redirect to Public Home
      if (!isLoggedIn && !isPublicRoute) {
        return '/';
      }

      // 2. If Logged in and trying to access Public Home or Login -> Redirect to Dashboard
      if (isLoggedIn && isPublicRoute) {
        return '/student-dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      // PUBLIC ROUTES (Standalone)
      GoRoute(path: '/', builder: (context, state) => const PublicHomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // PROTECTED ROUTES (Dashboard Shell)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Student Dashboard (The "Real" Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/student-dashboard',
                builder: (context, state) => const StudentDashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Exams (Replacing Courses as primary academic tab)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exams',
                builder: (context, state) => const ExamListScreen(),
              ),
            ],
          ),
          // Branch 2: Profile (Account)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
          // Branch 3: Menu (More)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) => const MenuScreen(),
              ),
            ],
          ),
        ],
      ),

      // STANDALONE PROTECTED ROUTES (Outside Shell)
      GoRoute(
        path: '/dashboard',
        redirect: (context, state) => '/student-dashboard',
      ), // Legacy redirect
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const MyDocumentsScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) => const VerificationScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              return VerificationScreen(documentId: state.pathParameters['id']);
            },
          ),
        ],
      ),
      // Exam sub-routes
      GoRoute(
        path: '/exam-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ExamResultScreen(
            score: extra['score'] as int,
            totalQuestions: extra['total'] as int,
            examTitle: extra['title'] as String,
          );
        },
      ),
      GoRoute(
        path: '/exam-instruction/:id',
        builder: (context, state) {
          final exam = state.extra as Exam;
          return ExamInstructionsScreen(exam: exam);
        },
      ),
      GoRoute(
        path: '/exam-start/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final exam = state.extra as Exam?;
          return ExamQuizScreen(examId: id, examMetadata: exam);
        },
      ),
    ],
  );
});

// Navigation Shell (Only for Logged In Students)
class ScaffoldWithNestedNavigation extends ConsumerStatefulWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithNestedNavigation> createState() =>
      _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState
    extends ConsumerState<ScaffoldWithNestedNavigation> {
  DateTime? currentBackPressTime;
  final List<int> _visitedIndices = [0];

  void _goBranch(int index) {
    if (index == widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
    } else {
      setState(() {
        _visitedIndices.add(index);
      });
      widget.navigationShell.goBranch(index, initialLocation: false);
    }
  }

  void _handleBackPress(bool didPop) {
    if (didPop) return;
    if (_visitedIndices.length > 1) {
      setState(() {
        if (_visitedIndices.isNotEmpty) _visitedIndices.removeLast();
      });
      if (_visitedIndices.isNotEmpty) {
        widget.navigationShell.goBranch(
          _visitedIndices.last,
          initialLocation: false,
        );
        return;
      }
    }
    final now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Indices must match branches above
    final tabs = [
      const GButton(icon: Icons.dashboard_rounded, text: 'Dashboard'),
      const GButton(icon: Icons.assignment_rounded, text: 'Exams'),
      const GButton(icon: Icons.person_rounded, text: 'Profile'),
      const GButton(icon: Icons.menu_rounded, text: 'Menu'),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handleBackPress(didPop),
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: 0.05)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey.shade300,
                hoverColor: Colors.grey.shade100,
                gap: 8,
                activeColor: Colors.white,
                iconSize: 24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                duration: const Duration(milliseconds: 300),
                tabBackgroundColor: AppTheme.primaryColor,
                color: Colors.grey.shade600,
                tabs: tabs,
                selectedIndex: widget.navigationShell.currentIndex,
                onTabChange: _goBranch,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
