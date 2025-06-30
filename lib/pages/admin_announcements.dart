import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<PlatformFile> _attachments = [];
  bool _uploading = false;
  bool _showAddForm = false;

  Future<List<String?>> _uploadAttachmentsToSupabase(List<PlatformFile> files) async {
    final supabase = Supabase.instance.client;
    final user = FirebaseAuth.instance.currentUser;
    List<String?> urls = [];
    for (final file in files) {
      final path = '${user?.uid ?? "unknown"}/announcements/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final res = await supabase.storage.from('attachments').uploadBinary(
        path,
        file.bytes!,
        fileOptions: FileOptions(upsert: true),
      );
      if (res.isNotEmpty) {
        urls.add(supabase.storage.from('attachments').getPublicUrl(path));
      } else {
        urls.add(null);
      }
    }
    return urls;
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(withData: true, allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachments = result.files;
      });
    }
  }

  Future<void> addAnnouncement() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();
    if (title.isEmpty || desc.isEmpty) return;
    setState(() => _uploading = true);
    try {
      List<String>? attachmentNames;
      List<String?>? attachmentUrls;
      if (_attachments.isNotEmpty) {
        attachmentNames = _attachments.map((f) => f.name).toList();
        attachmentUrls = await _uploadAttachmentsToSupabase(_attachments);
      }
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title,
        'description': desc,
        'createdAt': FieldValue.serverTimestamp(),
        'category': _category,
        'priority': _priority,
        'isImportant': _isImportant,
        'attachmentNames': attachmentNames,
        'attachmentUrls': attachmentUrls,
        'createdBy': user?.uid,
        'createdByEmail': user?.email,
      });
      titleController.clear();
      descController.clear();
      setState(() {
        _category = null;
        _priority = null;
        _isImportant = false;
        _attachments = [];
        _showAddForm = false;
      });
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  Widget _buildAddForm(BuildContext context, bool isMobile, ColorScheme colorScheme) {
    // Use only black, white, grey
    final Color borderColor = Colors.grey[300]!;
    final Color bgColor = Colors.white;
    final Color accent = Colors.grey[100]!;
    final Color iconColor = Colors.grey[800]!;
    final Color buttonColor = Colors.black;
    final Color buttonText = Colors.white;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 0,
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: borderColor, width: 1.2),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 28, horizontal: isMobile ? 12 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign_rounded, color: iconColor, size: 28),
                    const SizedBox(width: 10),
                    Text('Add Announcement',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.grey[700],
                      onPressed: _uploading ? null : () => setState(() => _showAddForm = false),
                      tooltip: 'Cancel',
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1.2, color: Colors.grey),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                    prefixIcon: Icon(Icons.title, color: iconColor),
                    filled: true,
                    fillColor: accent,
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                    prefixIcon: Icon(Icons.description, color: iconColor),
                    filled: true,
                    fillColor: accent,
                  ),
                  minLines: 2,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        items: ['Maintenance', 'Event', 'Update', 'Other']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black))))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                          prefixIcon: Icon(Icons.category, color: iconColor),
                          filled: true,
                          fillColor: accent,
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _priority,
                        items: ['High', 'Medium', 'Low']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black))))
                            .toList(),
                        onChanged: (v) => setState(() => _priority = v),
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                          prefixIcon: Icon(Icons.flag, color: iconColor),
                          filled: true,
                          fillColor: accent,
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _isImportant,
                      onChanged: (v) => setState(() => _isImportant = v ?? false),
                      activeColor: Colors.grey[800],
                    ),
                    const Text('Mark as Important', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickAttachments,
                  icon: Icon(Icons.attach_file, color: iconColor),
                  label: const Text('Add Attachments', style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    backgroundColor: accent,
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 18, vertical: isMobile ? 6 : 10),
                  ),
                ),
                if (_attachments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._attachments.map((f) => Row(
                              children: [
                                Icon(Icons.insert_drive_file, size: 16, color: iconColor),
                                const SizedBox(width: 4),
                                Expanded(child: Text(f.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black))),
                                Text('${(f.size / 1024).toStringAsFixed(1)} KB', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            )),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _uploading ? null : addAnnouncement,
                      icon: _uploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                        child: Text(_uploading ? 'Adding...' : 'Add Announcement',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonText,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 18, vertical: isMobile ? 6 : 10),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> data, ColorScheme colorScheme, bool isMobile) {
    // Use only black, white, grey
    final Color borderColor = Colors.grey[300]!;
    final Color bgColor = Colors.white;
    final Color iconColor = Colors.grey[800]!;
    final Color chipBg = Colors.grey[200]!;
    final Color chipText = Colors.grey[900]!;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final attachments = data['attachmentUrls'] as List<dynamic>? ?? [];
    final attachmentNames = data['attachmentNames'] as List<dynamic>? ?? [];
    final chips = <Widget>[];
    if (data['category'] != null && (data['category'] as String).isNotEmpty) {
      chips.add(
        Chip(
          label: Text(data['category'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          backgroundColor: chipBg,
          labelStyle: TextStyle(color: chipText),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    }
    if (data['priority'] != null && (data['priority'] as String).isNotEmpty) {
      chips.add(
        Chip(
          label: Text(data['priority'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          backgroundColor: chipBg,
          labelStyle: TextStyle(color: chipText),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    }
    if (data['isImportant'] == true) {
      chips.add(
        Chip(
          label: const Text('Important', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
          backgroundColor: Colors.grey[300],
          labelStyle: const TextStyle(color: Colors.black),
          avatar: Icon(Icons.priority_high, color: Colors.black, size: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      );
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      color: bgColor,
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 18, left: 2, right: 2),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 18, horizontal: isMobile ? 12 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.campaign, color: iconColor, size: 24),
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16 : 19,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (createdAt != null)
                  Text(
                    '${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}/${createdAt.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                  tooltip: 'Delete',
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('announcements').doc(data['id']).delete();
                  },
                ),
              ],
            ),
            if (chips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: chips,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                data['description'] ?? '',
                style: TextStyle(fontSize: isMobile ? 13 : 15, color: Colors.black87),
              ),
            ),
            if (attachments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    attachments.length,
                    (i) {
                      final url = attachments[i];
                      final name = (attachmentNames.isNotEmpty && i < attachmentNames.length)
                          ? attachmentNames[i]
                          : 'Attachment';
                      return InkWell(
                        onTap: () async {
                          if (url != null && url.toString().isNotEmpty) {
                            final uri = Uri.parse(url.toString());
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          }
                        },
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, size: 16, color: iconColor),
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use only black, white, grey
    final colorScheme = ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey[700]!,
      background: Colors.white,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black,
      brightness: Brightness.light,
    );
    final isMobile = MediaQuery.of(context).size.width < 700;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: isMobile ? 8 : 24, top: isMobile ? 8 : 24, bottom: isMobile ? 4 : 8),
            child: Row(
              children: [
                Icon(Icons.campaign_rounded, color: colorScheme.primary, size: isMobile ? 22 : 28),
                const SizedBox(width: 10),
                Text(
                  'Announcements Manager',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: isMobile ? 18 : null,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 24, vertical: isMobile ? 4 : 8),
            child: !_showAddForm
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Announcement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onPressed: () => setState(() => _showAddForm = true),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (_showAddForm)
            _buildAddForm(context, isMobile, colorScheme),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('announcements')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(isMobile ? 8 : 24),
                  child: const Text('No announcements yet.'),
                );
              }
              final docs = snapshot.data!.docs;
              // Attach doc.id to each data for delete
              final dataList = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).toList();
              return Column(
                children: dataList
                    .map((data) => _buildAnnouncementCard(data, colorScheme, isMobile))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}