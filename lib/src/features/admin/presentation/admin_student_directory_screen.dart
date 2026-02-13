import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import 'package:gokul_shree_app/src/core/data/admin_repository.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_fee_collection_screen.dart';
import 'package:gokul_shree_app/src/features/admin/presentation/admin_admit_card_screen.dart';

class AdminStudentDirectoryScreen extends ConsumerStatefulWidget {
  const AdminStudentDirectoryScreen({super.key});

  @override
  ConsumerState<AdminStudentDirectoryScreen> createState() =>
      _AdminStudentDirectoryScreenState();
}

class _AdminStudentDirectoryScreenState
    extends ConsumerState<AdminStudentDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // In a real app, this would use pagination or search-as-you-type API
    // For now, we'll fetch 'all' (mocked limited list) and filter locally
    // or use the repository to fetch mock data

    // We'll create a mock list here if repo doesn't return enough for demo
    // But let's try to use the repo first if it had a getStudents method
    // checking repo... yes request said 'Student Directory List'

    setState(() => _isLoading = true);

    // Simulating a fetch of a larger directory
    await Future.delayed(const Duration(milliseconds: 800));
    final mockStudents = [
      {
        'name': 'Aarav Patel',
        'reg_no': 'REG2023001',
        'class': 'Class 5B',
        'phone': '9876543210',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCWSHhaZ8O90DgfOHsoFGzrX-t82eyc7IsSYBnqzAh4bPyFls3e-a2uTz_LDK-Wu1Quv0XONkR8mwemYReXNYLlOdi7Lak2pM-ySIxoPknF39kk-U319dmDtlZWYyyfWkSWJ_GWgsGWVebOqtbw32q2CiL056gEziBCwTUu2HVwBBxaYt2wUDcYj_gAWAyWC4Tm5B_0cgaIrvTARcgIEbDCP4Yq25YYDrQ7TFfILqiNkznnnQ0fRxycR0mxSJL6cVQvQdVibR3IGPY',
        'status': 'Active',
      },
      {
        'name': 'Sneha Gupta',
        'reg_no': 'REG2023045',
        'class': 'Class 10A',
        'phone': '9876543211',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAa-_STepkMgxKOk8C1Kck9qLnvH49pk-lZL8lvTQmgLXFjQbhxs5U9jMmqxCLmzy_kT-C1TLlc66apqhCZEbn9K244cm_FuvWavydcsj1VwwPewU2-vMxHbHs9E0T5Ja2aY8VAvqdKFcZ3SnKb3UUGP6DkKSlebBCzO-D_FRFziCKtxiPk6jhdLaMC5ORkNfxs_BYC4M9-mp2GI7QAohf0GJU_541fPpaS6f9sj2MTX-P443hJ6phW02IBTCUHECHalZdhx9r6YHM',
        'status': 'Fees Due',
      },
      {
        'name': 'Rohan Mehta',
        'reg_no': 'REG2023102',
        'class': 'Class 8C',
        'phone': '9876543212',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDc0u7vdY0MIxsFHuXCYq2-EX8vfQVLhzXEFNKMtTnhACktdNada33DXOeg5AxOkMIWHwyj-ReN9jdgowDV7fdDF3SNfyo1bP3Wns94uiEWlMb8iD5-oFg2MVK4iVLsTKtpUQetFV1i29l0Ko8stOLrtggBXg0CgMqNsAWAlY1drAV49xDZMYdUfCzisDJVMGVWHCWfDL7w4CxwnUnhoAjlKHJkJXnY_mNnVNdId0Mwk0zz-2TT3G--0iTz6g0WcB0KuJa-MFL1I-8',
        'status': 'Active',
      },
      {
        'name': 'Ananya Singh',
        'reg_no': 'REG2023088',
        'class': 'Class 6A',
        'phone': '9876543213',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAIk1G3rT8x5eH0RtpP4SWG0qaRSOMwyiKPoafwxJVguElkFy-ucp5Yy0U_9-mTPLolGPRmKBDzwIY-6R6rBMjtHsGvOVHW0dCJh9h5CDcH6HaGvzkG65tgfi7oGPyA5TFmYKvuba4nbKkD_r5LEaVhdQR30TgD89RGz6oXxrM6_T-Jzadfo1qv-4XYmdtOL9loXI24TxL8nBhIpC9iRpDOR4Qlaia4tdyRoEjwoFPc4nf18Ax5eyF1geaJInKfNQW8Lhz7167tRPk',
        'status': 'Active',
      },
      {
        'name': 'Vikram Malhotra',
        'reg_no': 'REG2023201',
        'class': 'Class 12B',
        'phone': '9876543214',
        'photo_url':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAkC_uS5QGjfCInDEUnpVBlmd5xltG7STYtEk1_QJod5Enq6IIrL5cu9IzEFPFYuLqTWsquXV_yETWA25rLQqf8c-ZjkFlM2fZCgTeY7Qdxsp6ITEXxRAVeAa-P0hz5DqIR7hru5hgHPa05dHEBwjSC-xrvEjrmIFU7pd7mBTSKrdmuNfumretW03zNw_k1FH7nuBZzmMOuUNO1WD9zD3GgyRCnUO-DQ_-nJzs2FznjylBRd8-K1WVjZYslqno9UNyV8QLiJypQdC4',
        'status': 'Active',
      },
    ];

    if (mounted) {
      setState(() {
        _allStudents = mockStudents;
        _filteredStudents = mockStudents;
        _isLoading = false;
      });
    }
  }

  void _filterStudents(String query) {
    if (query.isEmpty) {
      setState(() => _filteredStudents = _allStudents);
    } else {
      setState(() {
        _filteredStudents = _allStudents.where((student) {
          final name = student['name'].toString().toLowerCase();
          final regNo = student['reg_no'].toString().toLowerCase();
          final q = query.toLowerCase();
          return name.contains(q) || regNo.contains(q);
        }).toList();
      });
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Student Directory',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              // TODO: Advanced Filters
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStudents,
              decoration: InputDecoration(
                hintText: 'Search by Name or Reg No...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredStudents.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = _filteredStudents[index];
                      final isFeesDue = student['status'] == 'Fees Due';

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () =>
                              _showStudentActionSheet(context, student),
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(student['photo_url']),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.person),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  student['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isFeesDue)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Text(
                                    'Fees Due',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${student['reg_no']} • ${student['class']}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50], // green-50
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            onPressed: () => _makeCall(student['phone']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showStudentActionSheet(
    BuildContext context,
    Map<String, dynamic> student,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions for ${student['name']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.call, color: Colors.green),
              ),
              title: const Text('Call Parent'),
              onTap: () {
                Navigator.pop(context);
                _makeCall(student['phone']);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments, color: AppTheme.primaryColor),
              ),
              title: const Text('Collect Fee'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminFeeCollectionScreen(student: student),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge, color: Colors.blue),
              ),
              title: const Text('Admit Card'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AdminAdmitCardScreen(student: student),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.orange),
              ),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Edit Profile
              },
            ),
          ],
        ),
      ),
    );
  }
}
