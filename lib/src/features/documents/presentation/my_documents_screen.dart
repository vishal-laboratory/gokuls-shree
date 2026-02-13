import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/features/auth/data/supabase_auth_service.dart';
import 'package:gokul_shree_app/src/features/documents/data/document_repository.dart';
import 'package:gokul_shree_app/src/features/documents/services/certificate_service.dart';
import 'package:printing/printing.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import 'package:gokul_shree_app/src/core/widgets/pdf_viewer_screen.dart';

class MyDocumentsScreen extends ConsumerStatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  ConsumerState<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends ConsumerState<MyDocumentsScreen> {
  final _certificateService = CertificateService();

  Future<void> _generateCertificate() async {
    final authState = ref.read(supabaseAuthProvider);

    // Safely get student data
    final Map<String, dynamic>? userProfile = authState is AuthAuthenticated
        ? authState.studentData
        : null;

    // Use placeholder data if no profile is found (Demo Mode)
    final student =
        userProfile ??
        {
          'name': 'Vishal (Demo)',
          'course_name': 'Flutter Development',
          'id': '00000000-0000-0000-0000-000000000000',
        };

    final courseName =
        student['course_name'] ?? 'Diploma in Computer Application';
    final studentId = student['id'];

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final docRepo = ref.read(documentRepositoryProvider);

      // Prepare document data
      final docData = {
        'student_id': studentId,
        'course': courseName,
        'date': DateTime.now().toIso8601String(),
      };

      final docHash = _certificateService.computeHash(docData);
      String docId;

      try {
        // Try inserting into DB (Real Mode)
        final newDoc = await docRepo.generateDocument(
          studentId: studentId.toString(),
          type: 'certificate',
          data: docData,
          docHash: docHash,
          signature: 'valid_signature_placeholder',
        );
        docId = newDoc['id'];
      } catch (e) {
        // Fallback for Demo/Testing if DB fails (e.g. no student record or table, or RLS)
        debugPrint('DB Insert failed, using dummy ID: $e');
        docId = 'demo-cert-${DateTime.now().millisecondsSinceEpoch}';
      }

      // Generate PDF
      final pdfBytes = await _certificateService.generateCertificate(
        studentName: student['name'] ?? 'Student',
        courseName: courseName,
        duration: '6 Months',
        date: DateTime.now().toString().split(' ')[0],
        certificateId: docId,
        verificationUrl: 'https://gokul-shree.web.app/verify/$docId',
      );

      if (mounted) {
        Navigator.pop(context); // Close loader
        // Open PDF Preview
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'Certificate.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);
    final studentId = authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Documents'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: studentId != null
            ? ref.read(documentRepositoryProvider).getDocuments(studentId)
            : Future.value(<Map<String, dynamic>>[]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var documents = snapshot.data ?? [];
          if (documents.isEmpty) {
            // Mock data for visualization if empty
            documents = [
              {
                'id': 'cert-001',
                'type': 'certificate',
                'created_at': DateTime.now().toIso8601String(),
                'data': {'course': 'Diploma in Computer Application'},
              },
              {
                'id': 'mark-001',
                'type': 'marksheet',
                'created_at': DateTime.now().toIso8601String(),
                'data': {'course': 'Semester 1 Results'},
              },
            ];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Issued Documents Section
                Text(
                  'Issued Documents (${documents.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Vertical List of Cards (DigiLocker Style)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    final isCertificate = doc['type'] == 'certificate';
                    final title = isCertificate
                        ? 'Course Certificate'
                        : 'Marksheet';
                    final subtitle =
                        doc['data']?['course'] ??
                        'Gokul Shree Architecture College';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCertificate
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCertificate
                                ? Icons.workspace_premium
                                : Icons.description,
                            color: isCertificate ? Colors.orange : Colors.blue,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Issued: ${doc['created_at'].toString().split('T')[0]}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: const Row(
                                children: [
                                  Icon(Icons.visibility, size: 20),
                                  SizedBox(width: 8),
                                  Text('View'),
                                ],
                              ),
                              onTap: () async {
                                final authState = ref.read(
                                  supabaseAuthProvider,
                                );
                                final userProfile =
                                    authState is AuthAuthenticated
                                    ? authState.studentData
                                    : null;

                                // Show loading
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (c) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final pdfBytes = await _certificateService
                                      .generateCertificate(
                                        studentName:
                                            userProfile?['name'] ?? 'Student',
                                        courseName:
                                            doc['data']?['course'] ?? 'Course',
                                        duration: '6 Months',
                                        date: doc['created_at']
                                            .toString()
                                            .split('T')[0],
                                        certificateId: doc['id'].toString(),
                                        verificationUrl:
                                            'https://gokul-shree.web.app/verify/${doc['id']}',
                                      );

                                  if (mounted) {
                                    Navigator.pop(context); // Close loading
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerScreen(
                                          title: title,
                                          pdfBytes: pdfBytes,
                                          fileName: '${title}_${doc['id']}.pdf',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                            PopupMenuItem(
                              value: 'download',
                              child: const Row(
                                children: [
                                  Icon(Icons.download, size: 20),
                                  SizedBox(width: 8),
                                  Text('Download'),
                                ],
                              ),
                              onTap: () async {
                                final authState = ref.read(
                                  supabaseAuthProvider,
                                );
                                final userProfile =
                                    authState is AuthAuthenticated
                                    ? authState.studentData
                                    : null;

                                final pdfBytes = await _certificateService
                                    .generateCertificate(
                                      studentName:
                                          userProfile?['name'] ?? 'Student',
                                      courseName:
                                          doc['data']?['course'] ?? 'Course',
                                      duration: '6 Months',
                                      date: doc['created_at'].toString().split(
                                        'T',
                                      )[0],
                                      certificateId: doc['id'].toString(),
                                      verificationUrl:
                                          'https://gokul-shree.web.app/verify/${doc['id']}',
                                    );
                                await Printing.sharePdf(
                                  bytes: pdfBytes,
                                  filename: '${title}_${doc['id']}.pdf',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDocumentOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDocumentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Document',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.workspace_premium,
                color: Colors.orange,
              ),
              title: const Text('Download Certificate'),
              onTap: () {
                Navigator.pop(context);
                _generateCertificate(); // Currently generates demo, can be updated later
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('Download Marksheet'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marksheet feature coming soon'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
