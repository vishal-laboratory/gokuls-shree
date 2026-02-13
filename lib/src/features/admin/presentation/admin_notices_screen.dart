import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import 'package:gokul_shree_app/src/core/data/admin_repository.dart';

class AdminNoticesScreen extends ConsumerStatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  ConsumerState<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends ConsumerState<AdminNoticesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isLoading = true;
  List<Map<String, dynamic>> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() => _isLoading = true);
    // Fetch from repo
    final repo = ref.read(adminRepositoryProvider);
    final data = await repo.getNotices();
    if (mounted) {
      setState(() {
        _notices = data;
        _isLoading = false;
      });
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? notice]) {
    final isEditing = notice != null;
    if (isEditing) {
      _titleController.text = notice['title'];
      _contentController.text = notice['content'] ?? '';
      _selectedCategory = notice['category'] ?? 'General';
    } else {
      _titleController.clear();
      _contentController.clear();
      _selectedCategory = 'General';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Notice' : 'Add New Notice'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: ['General', 'Holiday', 'Exam', 'Urgent']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  final repo = ref.read(adminRepositoryProvider);
                  if (isEditing) {
                    await repo.updateNotice(
                      id: notice['id'],
                      title: _titleController.text,
                      content: _contentController.text,
                      category: _selectedCategory,
                    );
                  } else {
                    await repo.addNotice(
                      title: _titleController.text,
                      content: _contentController.text,
                      category: _selectedCategory,
                    );
                  }
                  await _loadNotices();
                } catch (e) {
                  // Handle error
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              }
            },
            child: Text(isEditing ? 'Update' : 'Post'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNotice(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this notice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() => _isLoading = true);
      await ref.read(adminRepositoryProvider).deleteNotice(id);
      await _loadNotices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Match directory style
      appBar: AppBar(
        title: const Text(
          'Notice Board',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notices.isEmpty
          ? const Center(child: Text('No notices found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notices.length,
              itemBuilder: (context, index) {
                final notice = _notices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      notice['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          notice['content'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            notice['category'] ?? 'General',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(notice),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNotice(notice['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
