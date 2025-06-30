import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AdminDashboardPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 32, horizontal: isMobile ? 14 : 32),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.school, color: colorScheme.primary, size: isMobile ? 32 : 48),
                  SizedBox(width: isMobile ? 10 : 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to DRRMIS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 28,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your dashboard for disaster risk reduction and management in schools.',
                          style: TextStyle(fontSize: isMobile ? 13 : 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 18 : 32),
            // Quick Summary Cards
            Wrap(
              spacing: isMobile ? 10 : 24,
              runSpacing: isMobile ? 10 : 18,
              children: [
                GestureDetector(
                  onTap: () {
                    DefaultTabController.of(context)?.animateTo(0);
                  },
                  child: _summaryCard(
                    icon: Icons.assignment_turned_in,
                    label: 'Submission Tasks',
                    value: 'View and submit required drills',
                    color: colorScheme.primary,
                    context: context,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                  child: _summaryCard(
                    icon: Icons.campaign_rounded,
                    label: 'Announcements',
                    value: 'See latest updates',
                    color: colorScheme.secondary,
                    context: context,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 18 : 32),
            // Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Use',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 15 : 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Check for new submission tasks regularly.\n'
                      '• Submit your drill reports before the deadline.\n'
                      '• Review announcements for important updates.\n'
                      '• Track your previous submissions in "My Submissions".',
                      style: TextStyle(fontSize: isMobile ? 13 : 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isMobile ? 18 : 32),
            // --- Active & Recent Tasks Table ---
            Text(
              'Active & Recent Tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 15 : 20,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 8),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .orderBy('deadline', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, taskSnap) {
                if (!taskSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = taskSnap.data!.docs
                    .where((doc) => (doc['active'] ?? true) == true || (doc['archived'] ?? false) == false)
                    .toList();
                if (tasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No active or recent tasks.'),
                  );
                }
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('role', isEqualTo: 'school')
                      .snapshots(),
                  builder: (context, schoolSnap) {
                    if (!schoolSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final schools = schoolSnap.data!.docs;
                    final schoolIds = schools.map((s) => s.id).toSet();
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('submissions').snapshots(),
                      builder: (context, subSnap) {
                        if (!subSnap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final submissions = subSnap.data!.docs;
                        // Map: taskId -> Set<schoolId> that submitted
                        final Map<String, Set<String>> taskToSubmitted = {};
                        for (final sub in submissions) {
                          final data = sub.data() as Map<String, dynamic>;
                          final taskId = data['taskId'] as String?;
                          final schoolId = data['schoolId'] as String?;
                          if (taskId != null && schoolId != null) {
                            taskToSubmitted.putIfAbsent(taskId, () => {}).add(schoolId);
                          }
                        }
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: isMobile ? 10 : 28,
                            dataRowMinHeight: isMobile ? 36 : 44,
                            columns: const [
                              DataColumn(label: Text('Task')),
                              DataColumn(label: Text('Deadline')),
                              DataColumn(label: Text('Drill Date')),
                              DataColumn(label: Text('Submitted')),
                              DataColumn(label: Text('Not Submitted')),
                            ],
                            rows: tasks.map((doc) {
                              final task = doc.data() as Map<String, dynamic>;
                              final taskId = doc.id;
                              final submittedSet = taskToSubmitted[taskId] ?? {};
                              final submittedCount = submittedSet.length;
                              final notSubmittedCount = schoolIds.length - submittedCount;
                              final deadline = (task['deadline'] as Timestamp?)?.toDate();
                              final drillDate = (task['drillDate'] as Timestamp?)?.toDate();
                              String formatDate(DateTime? d) => d == null
                                  ? 'N/A'
                                  : "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
                              return DataRow(
                                cells: [
                                  DataCell(Text('${task['type'] ?? ''} (${task['frequency'] ?? ''})')),
                                  DataCell(Text(formatDate(deadline))),
                                  DataCell(Text(formatDate(drillDate))),
                                  DataCell(Text('$submittedCount')),
                                  DataCell(Text('$notSubmittedCount')),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return SizedBox(
      width: isMobile ? double.infinity : 260,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white, // Remove dark/grey background
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 18, horizontal: isMobile ? 10 : 18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: isMobile ? 22 : 28),
                radius: isMobile ? 20 : 26,
              ),
              SizedBox(width: isMobile ? 10 : 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16, color: color)),
                    SizedBox(height: 2),
                    Text(value, style: TextStyle(fontSize: isMobile ? 11 : 13, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}