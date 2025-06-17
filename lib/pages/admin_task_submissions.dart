import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTaskSubmissionsPage extends StatelessWidget {
  final String taskId;
  final String taskTitle;
  const AdminTaskSubmissionsPage({Key? key, required this.taskId, required this.taskTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Submissions for "$taskTitle"'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'school')
            .get(),
        builder: (context, schoolSnap) {
          if (!schoolSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final schools = schoolSnap.data!.docs;
          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('submissions')
                .where('taskId', isEqualTo: taskId)
                .get(),
            builder: (context, subSnap) {
              if (!subSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final submissions = subSnap.data!.docs;
              final submittedSchoolIds = submissions.map((s) => s['schoolId'] as String).toSet();
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  for (final school in schools)
                    Card(
                      color: colorScheme.secondary.withOpacity(0.13),
                      child: ListTile(
                        leading: Icon(
                          submittedSchoolIds.contains(school.id)
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: submittedSchoolIds.contains(school.id)
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        title: Text(((school.data() as Map<String, dynamic>)['name'] ?? (school.data() as Map<String, dynamic>)['email']) ?? 'School'),
                        subtitle: Text((school.data() as Map<String, dynamic>)['email'] ?? ''),
                        trailing: Text(
                          submittedSchoolIds.contains(school.id) ? 'Complied' : 'Not Yet',
                          style: TextStyle(
                            color: submittedSchoolIds.contains(school.id) ? colorScheme.primary : colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
