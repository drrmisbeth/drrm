import 'package:flutter/material.dart';

class SchoolTasksPage extends StatelessWidget {
  const SchoolTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasks = [
      {'title': 'Earthquake Drill', 'type': 'Monthly', 'due': 'July 6, 2024', 'icon': Icons.public},
      {'title': 'Fire Drill', 'type': 'Quarterly', 'due': 'July 7, 2024', 'icon': Icons.local_fire_department},
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submission Tasks',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: isMobile ? 22 : null,
                    ),
              ),
              SizedBox(height: isMobile ? 16 : 28),
              Wrap(
                spacing: isMobile ? 12 : 28,
                runSpacing: isMobile ? 12 : 28,
                children: tasks.map((task) {
                  return SizedBox(
                    width: isMobile ? double.infinity : 350,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: colorScheme.primary.withOpacity(0.15),
                              child: Icon(task['icon'] as IconData, color: colorScheme.primary, size: 30),
                              radius: 32,
                            ),
                            const SizedBox(width: 22),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'] as String,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 15 : 18),
                                  ),
                                  Text('Type: ${task['type']}', style: TextStyle(color: Colors.grey[700], fontSize: isMobile ? 13 : 15)),
                                  Text('Due: ${task['due']}', style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 11 : 13)),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: StadiumBorder(),
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: 10),
                              ),
                              onPressed: () {},
                              icon: Icon(Icons.upload_rounded, size: 18),
                              label: Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
