import 'package:flutter/material.dart';

class SchoolAnnouncementsPage extends StatelessWidget {
  const SchoolAnnouncementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Announcements',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
        ),
        const SizedBox(height: 28),
        ...List.generate(3, (i) => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 18),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary.withOpacity(0.15),
              child: Icon(Icons.campaign, color: colorScheme.secondary, size: 26),
              radius: 24,
            ),
            title: Text(
              'Announcement Title $i',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            subtitle: Text('Short description for announcement $i.'),
            trailing: Text('June ${10 + i}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
        )),
      ],
    );
  }
}
