import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_panel_screen.dart'; // Reusing for content
import 'package:gokul_shree_app/src/features/admin/presentation/admin_dashboard_home.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_qr_scanner_screen.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_student_directory_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AdminDashboardHome(),
    AdminStudentDirectoryScreen(),
    AdminQRScannerScreen(),
    AdminPanelScreen(), // Reusing the exist CMS screen as 'More'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: AppTheme.primaryColor,
            color: Colors.grey[600], // unselected icon color
            tabs: const [
              GButton(icon: Icons.dashboard_rounded, text: 'Home'),
              GButton(icon: Icons.people_alt_rounded, text: 'Students'),
              GButton(icon: Icons.qr_code_scanner_rounded, text: 'Scan'),
              GButton(icon: Icons.grid_view_rounded, text: 'Menu'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
