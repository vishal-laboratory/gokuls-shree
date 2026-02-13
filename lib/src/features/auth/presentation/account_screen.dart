import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import 'package:gokul_shree_app/src/core/widgets/profile_image_picker.dart';
import 'package:gokul_shree_app/src/core/widgets/webview_screen.dart';
import 'package:gokul_shree_app/src/core/data/admin_repository.dart';
import 'package:gokul_shree_app/src/core/data/attendance_repository.dart';
import 'package:gokul_shree_app/src/features/auth/data/supabase_auth_service.dart';

/// Account screen that shows login/signup when not authenticated
/// and shows profile/student info when authenticated
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login form
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginPasswordVisible = false;
  bool _useRegNo = false;

  // Signup form
  final _signupFormKey = GlobalKey<FormState>();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  bool _signupPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authNotifier = ref.read(supabaseAuthProvider.notifier);

    if (_useRegNo) {
      await authNotifier.signInWithRegNo(
        registrationNumber: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
    } else {
      await authNotifier.signIn(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
    }

    final state = ref.read(supabaseAuthProvider);
    if (state is AuthError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;

    if (_signupPasswordController.text !=
        _signupConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authNotifier = ref.read(supabaseAuthProvider.notifier);
    await authNotifier.signUp(
      email: _signupEmailController.text.trim(),
      password: _signupPasswordController.text,
      name: _signupNameController.text.trim(),
      phone: _signupPhoneController.text.trim().isEmpty
          ? null
          : _signupPhoneController.text.trim(),
    );

    final state = ref.read(supabaseAuthProvider);
    if (state is AuthError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.red),
      );
    } else if (state is AuthAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(supabaseAuthProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(authState is AuthAuthenticated ? 'My Account' : 'Account'),
        actions: [
          if (authState is AuthAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
        ],
      ),
      body: authState is AuthAuthenticated
          ? _buildProfileView(authState, isAdmin)
          : _buildAuthView(authState),
    );
  }

  // ===========================================
  // PROFILE VIEW (when logged in)
  // ===========================================
  Widget _buildProfileView(
    AuthAuthenticated authState,
    AsyncValue<bool> isAdmin,
  ) {
    final user = authState.user;
    final studentData = authState.studentData;
    final userName =
        user.userMetadata?['name'] as String? ??
        studentData?['name'] as String? ??
        user.email?.split('@').first ??
        'Student';
    final regNo = studentData?['registration_number'] as String? ?? 'N/A';
    final email = user.email ?? 'N/A';
    final phone = studentData?['phone'] as String? ?? 'N/A';
    final course = studentData?['course_name'] as String? ?? 'Not enrolled';
    final photoUrl = studentData?['photo_url'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Profile Image
                ProfileImagePicker(
                  userId: user.id,
                  currentImageUrl: photoUrl,
                  size: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  regNo != 'N/A' ? 'Reg No: $regNo' : email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                // Admin badge
                isAdmin.when(
                  data: (isAdminUser) => isAdminUser
                      ? Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                size: 16,
                                color: Colors.black87,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Admin',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Student Info Cards
          _buildInfoCard(icon: Icons.email, title: 'Email', value: email),
          _buildInfoCard(icon: Icons.phone, title: 'Phone', value: phone),
          _buildInfoCard(icon: Icons.school, title: 'Course', value: course),
          _buildInfoCard(
            icon: Icons.badge,
            title: 'Registration No.',
            value: regNo,
          ),

          const SizedBox(height: 24),

          // Attendance Section
          _buildAttendanceMeter(studentData?['id']?.toString()),

          const SizedBox(height: 24),

          // Quick Actions
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                icon: Icons.assignment,
                label: 'My Results',
                color: Colors.green,
                onTap: () => _handleResults(),
              ),
              // Downloads removed as per request
              _buildActionCard(
                icon: Icons.edit,
                label: 'Edit Profile',
                color: Colors.orange,
                onTap: () => _showEditProfileDialog(),
              ),
              _buildActionCard(
                icon: Icons.verified_user,
                label: 'My Documents',
                color: Colors.indigo,
                onTap: () => context.push('/documents'),
              ),

              // Admin Panel button (only for admins)
              isAdmin.when(
                data: (isAdminUser) => isAdminUser
                    ? _buildActionCard(
                        icon: Icons.admin_panel_settings,
                        label: 'Admin Panel',
                        color: Colors.purple,
                        onTap: () => context.push('/admin'),
                      )
                    : _buildActionCard(
                        icon: Icons.help,
                        label: 'Help',
                        color: Colors.teal,
                        onTap: () {},
                      ),
                loading: () => _buildActionCard(
                  icon: Icons.help,
                  label: 'Help',
                  color: Colors.teal,
                  onTap: () {},
                ),
                error: (_, __) => _buildActionCard(
                  icon: Icons.help,
                  label: 'Help',
                  color: Colors.teal,
                  onTap: () {},
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceMeter(String? studentId) {
    if (studentId == null) return const SizedBox.shrink();

    final attendanceAsync = ref.watch(
      studentOverallAttendanceProvider(studentId),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          attendanceAsync.when(
            data: (percentage) {
              final color = percentage >= 75
                  ? Colors.green
                  : percentage >= 50
                  ? Colors.orange
                  : Colors.red;
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
            error: (_, __) =>
                const Icon(Icons.error_outline, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                attendanceAsync.when(
                  data: (percentage) => Text(
                    percentage >= 75
                        ? 'Great job! Keep it up!'
                        : percentage >= 50
                        ? 'Needs improvement'
                        : 'Critical - attend more classes!',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  loading: () => Text(
                    'Loading...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  error: (_, __) => const Text(
                    'Unable to load',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const InAppWebViewScreen(url: WebUrls.results, title: 'My Results'),
      ),
    );
  }

  void _showEditProfileDialog() {
    final authState = ref.read(supabaseAuthProvider);
    if (authState is! AuthAuthenticated) return;

    final nameController = TextEditingController(
      text:
          authState.user.userMetadata?['name'] as String? ??
          authState.studentData?['name'] as String? ??
          '',
    );
    final phoneController = TextEditingController(
      text: authState.studentData?['phone'] as String? ?? '',
    );

    final focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                16, // Ensure keyboard padding
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Color(0xFFF5F5F7),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: Color(0xFFF5F5F7),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) return;

                            setState(() => isLoading = true);
                            try {
                              await ref
                                  .read(supabaseAuthProvider.notifier)
                                  .updateProfile(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                  );
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Profile updated successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // _showEditProfileDialog

  // ===========================================
  // AUTH VIEW (login/signup when not logged in)
  // ===========================================
  Widget _buildAuthView(SupabaseAuthState authState) {
    final isLoading = authState is AuthLoading;

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ), // Reduced Padding
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.account_circle,
                size: 60,
                color: Colors.white,
              ), // Reduced Size
              SizedBox(height: 12),
              Text(
                'Welcome to Gokul Shree',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20, // Reduced Font
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Login or create an account to continue',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Sign Up'),
          ],
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildLoginForm(isLoading), _buildSignupForm(isLoading)],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toggle: Email or Registration Number
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Email'),
                  selected: !_useRegNo,
                  onSelected: (_) => setState(() => _useRegNo = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Registration No.'),
                  selected: _useRegNo,
                  onSelected: (_) => setState(() => _useRegNo = true),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _loginEmailController,
              decoration: InputDecoration(
                labelText: _useRegNo ? 'Registration Number' : 'Email',
                prefixIcon: Icon(_useRegNo ? Icons.badge : Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: _useRegNo
                  ? TextInputType.text
                  : TextInputType.emailAddress,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _loginPasswordController,
              obscureText: !_loginPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _loginPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _loginPasswordVisible = !_loginPasswordVisible,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(),
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Login', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _signupNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _signupEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _signupPhoneController,
              decoration: InputDecoration(
                labelText: 'Phone (Optional)',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _signupPasswordController,
              obscureText: !_signupPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _signupPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _signupPasswordVisible = !_signupPasswordVisible,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _signupConfirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) => v != _signupPasswordController.text
                  ? 'Passwords don\'t match'
                  : null,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isLoading ? null : _handleSignup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                await ref
                    .read(supabaseAuthProvider.notifier)
                    .resetPassword(emailController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent!')),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
