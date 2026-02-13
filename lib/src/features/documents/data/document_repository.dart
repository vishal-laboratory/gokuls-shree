import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/services/supabase_service.dart';

class DocumentRepository {
  /// Get all documents issued to a student
  Future<List<Map<String, dynamic>>> getDocuments(String studentId) async {
    final response = await supabase
        .from('issued_documents')
        .select()
        .eq('student_id', studentId)
        .eq('is_revoked', false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Generate (store) a new document record
  Future<Map<String, dynamic>> generateDocument({
    required String studentId,
    required String type, // 'certificate', 'marksheet'
    required Map<String, dynamic> data,
    required String docHash,
    required String signature,
  }) async {
    final response = await supabase
        .from('issued_documents')
        .insert({
          'student_id': studentId,
          'type': type,
          'data': data,
          'doc_hash': docHash,
          'signature': signature,
        })
        .select()
        .single();
    return response;
  }

  /// Verify a document by ID and Hash
  Future<Map<String, dynamic>?> verifyDocument(
    String docId,
    String docHash,
  ) async {
    try {
      final response = await supabase
          .from('issued_documents')
          .select()
          .eq('id', docId)
          .eq('doc_hash', docHash)
          .eq('is_revoked', false)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Get document publicly by ID (for QR scanning)
  Future<Map<String, dynamic>?> getDocumentById(String docId) async {
    try {
      final response = await supabase
          .from('issued_documents')
          .select('*, students(name, registration_number, course_id)')
          .eq('id', docId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});
