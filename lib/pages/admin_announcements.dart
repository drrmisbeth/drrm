import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAnnouncementsPage extends StatefulWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AdminAnnouncementsPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  State<AdminAnnouncementsPage> createState() => _AdminAnnouncementsPageState();
}

class _AdminAnnouncementsPageState extends State<AdminAnnouncementsPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String? _category;
  String? _priority;
  bool _isImportant = false;
  PlatformFile? _attachment;
  bool _uploading = false;

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachment = result.files.first;
      });
    }
  }

  Future<void> addAnnouncement() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();
    if (title.isEmpty || desc.isEmpty) return;
    setState(() => _uploading = true);
    try {
      String? attachmentName;
      if (_attachment != null) {
        attachmentName = _attachment!.name;
      }
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title,
        'description': desc,
        'createdAt': FieldValue.serverTimestamp(),
        'category': _category,
        'priority': _priority,
        'isImportant': _isImportant,
        'attachmentName': attachmentName,
        'createdBy': user?.uid,
        'createdByEmail': user?.email,
      });
      titleController.clear();
      descController.clear();
      setState(() {
        _category = null;
        _priority = null;
        _isImportant = false;
        _attachment = null;
      });
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: isMobile ? 8 : 24, top: isMobile ? 12 : 24, bottom: 8),
            child: Text(
              'Announcements Manager',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24, vertical: 8),
            child: isMobile
                ? Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _category,
                              items: ['Maintenance', 'Event', 'Update', 'Other']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _category = v),
                              decoration: InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _priority,
                              items: ['High', 'Medium', 'Low']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _priority = v),
                              decoration: InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _isImportant,
                        onChanged: (v) => setState(() => _isImportant = v ?? false),
                        title: const Text('Mark as Important'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickAttachment,
                        icon: const Icon(Icons.attach_file),
                        label: Text(_attachment == null ? 'Add Attachment' : _attachment!.name),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _uploading ? null : addAnnouncement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary.withOpacity(0.18),
                            foregroundColor: colorScheme.primary,
                            shape: const StadiumBorder(),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          child: _uploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Add'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: descController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _category,
                          items: ['Maintenance', 'Event', 'Update', 'Other']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _priority,
                          items: ['High', 'Medium', 'Low']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => _priority = v),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: _isImportant,
                        onChanged: (v) => setState(() => _isImportant = v ?? false),
                      ),
                      const Text('Important'),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _pickAttachment,
                        icon: const Icon(Icons.attach_file),
                        label: Text(_attachment == null ? 'Add Attachment' : _attachment!.name),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _uploading ? null : addAnnouncement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary.withOpacity(0.18),
                          foregroundColor: colorScheme.primary,
                          shape: const StadiumBorder(),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: _uploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Add'),
                      ),
                    ],
                  ),
          ),
          // Show announcements from Firestore
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('announcements')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No announcements yet.'),
                );
              }
              final docs = snapshot.data!.docs;
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24, vertical: 6),
                    child: Material(
                      elevation: 0,
                      borderRadius: BorderRadius.circular(24),
                      color: colorScheme.secondary.withOpacity(0.13),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        title: Text(
                          data['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            data['description'] ?? '',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('announcements').doc(doc.id).delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}