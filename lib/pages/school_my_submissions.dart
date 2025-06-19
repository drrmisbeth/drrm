import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchoolMySubmissionsPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  final bool showSubmissionLink;
  const SchoolMySubmissionsPage({Key? key, this.onToggleDarkMode, this.darkMode = false, this.showSubmissionLink = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Not logged in.'));
    }
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Submissions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            if (showSubmissionLink)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    const Text('Submission successful!'),
                  ],
                ),
              ),
            const SizedBox(height: 28),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('submissions')
                    .where('schoolId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, subSnap) {
                  if (subSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final submissions = subSnap.hasData ? subSnap.data!.docs : [];
                  if (submissions.isEmpty) {
                    return const Center(child: Text('No submissions yet.'));
                  }
                  // Get all taskIds
                  final taskIds = submissions.map((s) => s['taskId'] as String).toSet().toList();
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('tasks')
                        .where(FieldPath.documentId, whereIn: taskIds.isEmpty ? ['dummy'] : taskIds)
                        .get(),
                    builder: (context, taskSnap) {
                      if (!taskSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final tasks = {for (var t in taskSnap.data!.docs) t.id: t.data() as Map<String, dynamic>};
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(colorScheme.primary.withOpacity(0.13)),
                          columns: const [
                            DataColumn(label: Text('Task', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Submitted', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: submissions.map((sub) {
                            final task = tasks[sub['taskId']] ?? {};
                            final taskTitle = '${task['type'] ?? 'Task'} (${task['frequency'] ?? ''})';
                            final submittedAt = sub['submittedAt'] != null
                                ? (sub['submittedAt'] as Timestamp).toDate()
                                : null;
                            return DataRow(cells: [
                              DataCell(Text(taskTitle, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black))),
                              DataCell(
                                Chip(
                                  label: const Text('Submitted'),
                                  backgroundColor: colorScheme.primary.withOpacity(0.18),
                                  labelStyle: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                ),
                              ),
                              DataCell(Text(
                                submittedAt != null
                                    ? '${submittedAt.year}-${submittedAt.month.toString().padLeft(2, '0')}-${submittedAt.day.toString().padLeft(2, '0')}'
                                    : '-',
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                              )),
                              DataCell(
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    side: BorderSide(color: colorScheme.primary, width: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('View'),
                                ),
                              ),
                            ]);
                          }).toList(),
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
