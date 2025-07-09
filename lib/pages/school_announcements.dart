import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolAnnouncementsPage extends StatelessWidget {
  final bool darkMode;
  const SchoolAnnouncementsPage({Key? key, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: Colors.white, // Use only white background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Announcements',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 500,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.black));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        title: Text('No announcements yet.', style: TextStyle(color: Colors.grey[700])),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    separatorBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Divider(
                        color: Colors.grey[300],
                        thickness: 1,
                        height: 1,
                      ),
                    ),
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                      final List<String> tags = (data['tags'] is List)
                          ? List<String>.from(data['tags'])
                          : [];
                      Color tagColor(String tag) {
                        switch (tag.toLowerCase()) {
                          case 'event':
                            return Colors.black;
                          case 'medium':
                            return Colors.grey[700]!;
                          case 'important':
                            return Colors.grey[900]!;
                          default:
                            return Colors.grey[700]!;
                        }
                      }
                      Color tagBgColor(String tag) {
                        switch (tag.toLowerCase()) {
                          case 'event':
                            return Colors.grey[200]!;
                          case 'medium':
                            return Colors.grey[100]!;
                          case 'important':
                            return Colors.grey[300]!;
                          default:
                            return Colors.grey[100]!;
                        }
                      }
                      final List<dynamic> attachmentUrls = (data['attachmentUrls'] is List)
                          ? data['attachmentUrls']
                          : [];
                      final List<dynamic> attachmentNames = (data['attachmentNames'] is List)
                          ? data['attachmentNames']
                          : [];

                      // Email-style fields
                      final sender = data['sender'] ?? 'Admin';
                      final subject = data['title'] ?? '';
                      final body = data['description'] ?? '';
                      final cc = data['cc'] ?? '';
                      final bcc = data['bcc'] ?? '';
                      final extraFields = Map<String, dynamic>.from(data)..removeWhere((k, v) =>
                        ['title', 'description', 'createdAt', 'tags', 'attachmentUrls', 'attachmentNames', 'sender', 'cc', 'bcc'].contains(k));

                      void showDetails() {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 24,
                                    offset: Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 24, right: 24,
                                  top: 28,
                                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.black,
                                            child: Icon(Icons.campaign, color: Colors.white, size: 28),
                                            radius: 24,
                                          ),
                                          SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(subject, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
                                                SizedBox(height: 2),
                                                Text('From: $sender', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                                                if (createdAt != null)
                                                  Text(
                                                    '${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}/${createdAt.year}',
                                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 18),
                                      if (tags.isNotEmpty)
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: tags.map((tag) {
                                            return Chip(
                                              label: Text(tag, style: TextStyle(fontWeight: tag.toLowerCase() == 'important' ? FontWeight.bold : FontWeight.normal)),
                                              backgroundColor: tagBgColor(tag),
                                              labelStyle: TextStyle(color: tagColor(tag)),
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            );
                                          }).toList(),
                                        ),
                                      SizedBox(height: 16),
                                      if (body.isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(body, style: TextStyle(fontSize: 15, color: Colors.black87)),
                                        ),
                                      if (extraFields.isNotEmpty) ...[
                                        SizedBox(height: 16),
                                        ...extraFields.entries.map((e) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text('${e.key}: ${e.value}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                                        )),
                                      ],
                                      if (attachmentUrls.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 18),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Attachments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                              ...List.generate(attachmentUrls.length, (idx) {
                                                final url = attachmentUrls[idx]?.toString() ?? '';
                                                final name = (idx < attachmentNames.length)
                                                    ? (attachmentNames[idx]?.toString() ?? 'Attachment')
                                                    : 'Attachment';
                                                if (url.isEmpty) return const SizedBox.shrink();
                                                return Padding(
                                                  padding: const EdgeInsets.only(bottom: 4),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (await canLaunchUrl(Uri.parse(url))) {
                                                        await launchUrl(Uri.parse(url));
                                                      }
                                                    },
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.attach_file, size: 16, color: Colors.black),
                                                        Flexible(
                                                          child: Text(
                                                            name,
                                                            style: const TextStyle(
                                                              color: Colors.black,
                                                              decoration: TextDecoration.underline,
                                                              fontSize: 14,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: showDetails,
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email-style header
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.yellow[600],
                                        child: Icon(Icons.campaign, color: Colors.white, size: 28),
                                        radius: 26,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Subject
                                            Text(
                                              subject,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            // Sender
                                            Text(
                                              'From: $sender',
                                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                            ),
                                            // Date
                                            if (createdAt != null)
                                              Text(
                                                '${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}/${createdAt.year}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 13,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Short body preview
                                  if (body.isNotEmpty)
                                    Text(
                                      body.length > 120 ? body.substring(0, 120) + '...' : body,
                                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                                    ),
                                  // Tags row
                                  if (tags.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: tags.map((tag) {
                                          return Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: tagBgColor(tag),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                color: tagColor(tag),
                                                fontWeight: tag.toLowerCase() == 'important'
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  // Attachments preview
                                  if (attachmentUrls.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.attach_file, size: 16, color: Colors.blue),
                                          Text('${attachmentUrls.length} attachment(s)', style: TextStyle(color: Colors.blue, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
