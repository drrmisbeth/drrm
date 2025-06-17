import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolTasksPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const SchoolTasksPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submission Tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 28),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .orderBy('deadline')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text('No tasks.');
                }
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: docs.map((doc) {
                    final task = doc.data() as Map<String, dynamic>;
                    final deadline = (task['deadline'] as Timestamp?)?.toDate();
                    final isActive = task['active'] ?? true;
                    IconData icon;
                    Color iconBg;
                    switch ((task['type'] as String).toLowerCase()) {
                      case 'earthquake':
                        icon = Icons.public;
                        iconBg = colorScheme.primary;
                        break;
                      case 'fire':
                        icon = Icons.local_fire_department;
                        iconBg = colorScheme.error;
                        break;
                      default:
                        icon = Icons.warning_amber;
                        iconBg = colorScheme.secondary;
                    }
                    return SizedBox(
                      width: 400,
                      child: Card(
                        elevation: 0,
                        color: colorScheme.secondary.withOpacity(isActive ? 0.13 : 0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: iconBg,
                                child: Icon(icon, color: Colors.white, size: 38),
                                radius: 36,
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          task['type'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (!isActive)
                                          Chip(
                                            label: const Text('Inactive'),
                                            backgroundColor: Colors.grey[300],
                                            labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      'Type: ${task['frequency'] ?? ''}',
                                      style: TextStyle(color: Colors.grey[700], fontSize: 15),
                                    ),
                                    Text(
                                      'Due: ${deadline != null ? "${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}" : "N/A"}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  elevation: 0,
                                ),
                                onPressed: isActive
                                    ? () {
                                        // TODO: Implement submission logic
                                      }
                                    : null,
                                icon: const Icon(Icons.upload_rounded, size: 22),
                                label: const Text('Submit'),
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
      ),
    );
  }
}
