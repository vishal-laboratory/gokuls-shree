import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gokul_shree_app/src/features/home/presentation/home_screen.dart';
import 'package:gokul_shree_app/src/features/courses/presentation/courses_screen.dart';
import 'package:gokul_shree_app/src/features/home/presentation/menu_screen.dart';
import 'package:gokul_shree_app/src/features/auth/presentation/account_screen.dart';
import 'package:gokul_shree_app/src/features/auth/data/supabase_auth_service.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_panel_screen.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_login_screen.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_dashboard_screen.dart';
// import 'package:gokul_shree_app/src/features/admin/presentation/admin_login_screen.dart'; // Duplicate
import 'package:gokul_shree_app/src/features/student/presentation/student_dashboard_screen.dart';
import 'package:gokul_shree_app/src/features/documents/presentation/my_documents_screen.dart';
import 'package:gokul_shree_app/src/features/documents/presentation/verification_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_list_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_quiz_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_result_screen.dart';
import 'package:gokul_shree_app/src/features/exams/presentation/exam_instructions_screen.dart';
import 'package:gokul_shree_app/src/features/exams/domain/exam_model.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (context, state) => const CoursesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
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
      // Dashboard route redirects to account (consolidating Student Portal into My Account)
      GoRoute(path: '/dashboard', redirect: (context, state) => '/account'),
      // Student Dashboard
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      // Admin Panel route (outside shell for full screen)
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      // My Documents route
      GoRoute(
        path: '/documents',
        builder: (context, state) => const MyDocumentsScreen(),
      ),
      // Verification route (with optional ID)
      GoRoute(
        path: '/verify',
        builder: (context, state) => const VerificationScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return VerificationScreen(documentId: id);
            },
          ),
        ],
      ),

      // EXAM ROUTES
      GoRoute(
        path: '/exams',
        builder: (context, state) => const ExamListScreen(),
        routes: [
          GoRoute(
            path: 'result',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return ExamResultScreen(
                score: extra['score'] as int,
                totalQuestions: extra['total'] as int,
                examTitle: extra['title'] as String,
              );
            },
          ),
          // STEP 1: Instructions Screen
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final exam = state.extra as Exam;
              return ExamInstructionsScreen(exam: exam);
            },
            routes: [
              // STEP 2: Actual Quiz (Start)
              GoRoute(
                path: 'start',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final exam = state.extra as Exam?;
                  return ExamQuizScreen(examId: id, examMetadata: exam);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Placeholder for screens not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}

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
  final List<int> _visitedIndices = [0]; // Tracks navigation history

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

    // If we have history, go back to previous tab
    if (_visitedIndices.length > 1) {
      setState(() {
        // Remove current tab
        if (_visitedIndices.isNotEmpty) {
          _visitedIndices.removeLast();
        }
      });

      // Go to the previous tab in history
      if (_visitedIndices.isNotEmpty) {
        widget.navigationShell.goBranch(
          _visitedIndices.last,
          initialLocation: false,
        );
        return;
      }
    }

    // If history is empty (at Root), implement Double Back to Exit
    final now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);
    final isLoggedIn = authState is AuthAuthenticated;

    // Define tabs based on role
    // NOTE: The indices must match the ShellBranches defined in GoRouter routes above.
    // Branch 0: Home
    // Branch 1: Courses
    // Branch 2: Account
    // Branch 3: Menu

    final tabs = [
      const GButton(icon: Icons.home_rounded, text: 'Home'),
      GButton(
        icon: isLoggedIn ? Icons.school_rounded : Icons.library_books_rounded,
        text: isLoggedIn ? 'Academics' : 'Courses',
      ),
      GButton(
        icon: Icons.person_rounded,
        text: isLoggedIn ? 'Profile' : 'Login',
      ),
      const GButton(icon: Icons.menu_rounded, text: 'Menu'),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: _handleBackPress,
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.05)),
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
                tabBackgroundColor: const Color(0xFF1A3A5C),
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
