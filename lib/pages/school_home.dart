import 'package:flutter/material.dart';

class SchoolHomePage extends StatelessWidget {
  const SchoolHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, School User!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
        ),
        const SizedBox(height: 32),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.15),
              child: Icon(Icons.warning_amber, color: colorScheme.primary, size: 28),
              radius: 28,
            ),
            title: Text(
              'Upcoming Submission: Earthquake Drill',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Due: June 30, 2024', style: TextStyle(fontSize: 15)),
            ),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {},
              icon: Icon(Icons.upload_rounded, size: 20),
              label: Text('Submit'),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Text(
          'Latest Announcements',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
              ),
        ),
        const SizedBox(height: 14),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondary.withOpacity(0.15),
              child: Icon(Icons.campaign, color: colorScheme.secondary, size: 26),
              radius: 24,
            ),
            title: Text(
              'Fire Drill Reminder',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text('Short description of the announcement...'),
            trailing: Text('June 10', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
