import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAllSubmissionsPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AdminAllSubmissionsPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tasks').orderBy('deadline').snapshots(),
          builder: (context, taskSnap) {
            if (taskSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!taskSnap.hasData || taskSnap.data!.docs.isEmpty) {
              return const Center(child: Text('No tasks found.'));
            }
            final tasks = taskSnap.data!.docs;
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'school').snapshots(),
              builder: (context, schoolSnap) {
                if (schoolSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!schoolSnap.hasData || schoolSnap.data!.docs.isEmpty) {
                  return const Center(child: Text('No schools found.'));
                }
                final schools = schoolSnap.data!.docs;
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('submissions').snapshots(),
                  builder: (context, subSnap) {
                    if (subSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final submissions = subSnap.hasData ? subSnap.data!.docs : [];
                    // Map: taskId -> {schoolId -> submission}
                    final Map<String, Map<String, dynamic>> taskSchoolSub = {};
                    for (final sub in submissions) {
                      final data = sub.data() as Map<String, dynamic>;
                      final taskId = data['taskId'] as String?;
                      final schoolId = data['schoolId'] as String?;
                      if (taskId != null && schoolId != null) {
                        taskSchoolSub.putIfAbsent(taskId, () => {})[schoolId] = data;
                      }
                    }
                    return ListView(
                      padding: EdgeInsets.all(isMobile ? 8 : 24),
                      children: [
                        Text('All Submissions', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: isMobile ? 18 : null,
                          color: colorScheme.primary,
                        )),
                        SizedBox(height: isMobile ? 8 : 16),
                        ...tasks.map((taskDoc) {
                          final task = taskDoc.data() as Map<String, dynamic>;
                          final taskId = taskDoc.id;
                          final taskTitle = '${task['type']} (${task['frequency']})';
                          final deadline = (task['deadline'] as Timestamp?)?.toDate();
                          return Card(
                            margin: EdgeInsets.only(bottom: isMobile ? 12 : 24),
                            color: colorScheme.secondary.withOpacity(0.13),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 10 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    taskTitle,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 15 : 18,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  if (deadline != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2, bottom: 8),
                                      child: Text(
                                        'Deadline: ${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}',
                                        style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey[700]),
                                      ),
                                    ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('School')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Submitted At')),
                                        DataColumn(label: Text('Action')),
                                      ],
                                      rows: schools.map((schoolDoc) {
                                        final school = schoolDoc.data() as Map<String, dynamic>;
                                        final schoolId = schoolDoc.id;
                                        final sub = taskSchoolSub[taskId]?[schoolId];
                                        final status = sub != null ? 'Complied' : 'Not Yet';
                                        final submittedAt = sub != null && sub['submittedAt'] != null
                                            ? (sub['submittedAt'] as Timestamp).toDate()
                                            : null;
                                        return DataRow(cells: [
                                          DataCell(Text(school['name'] ?? school['email'] ?? 'School')),
                                          DataCell(
                                            Chip(
                                              label: Text(status),
                                              backgroundColor: sub != null ? colorScheme.primary.withOpacity(0.18) : colorScheme.secondary.withOpacity(0.18),
                                              labelStyle: TextStyle(
                                                color: sub != null ? colorScheme.primary : colorScheme.secondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                            ),
                                          ),
                                          DataCell(Text(
                                            submittedAt != null
                                              ? '${submittedAt.year}-${submittedAt.month.toString().padLeft(2, '0')}-${submittedAt.day.toString().padLeft(2, '0')}'
                                              : '-',
                                          )),
                                          DataCell(
                                            sub != null
                                              ? TextButton(
                                                  onPressed: () {
                                                    // TODO: View submission details
                                                  },
                                                  child: const Text('View'),
                                                )
                                              : const SizedBox(),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
