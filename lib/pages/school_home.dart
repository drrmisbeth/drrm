import 'package:flutter/material.dart';

class SchoolHomePage extends StatelessWidget {
  const SchoolHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Padding(
          padding: EdgeInsets.all(isMobile ? 8 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, School User!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: isMobile ? 22 : null,
                    ),
              ),
              SizedBox(height: isMobile ? 18 : 32),
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
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 15 : 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Due: June 30, 2024', style: TextStyle(fontSize: isMobile ? 13 : 15)),
                  ),
                  trailing: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 18, vertical: 10),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.upload_rounded, size: 20),
                    label: Text('Submit'),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 20 : 36),
              Text(
                'Latest Announcements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.7,
                      fontSize: isMobile ? 16 : null,
                    ),
              ),
              SizedBox(height: isMobile ? 8 : 14),
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 13 : 16),
                  ),
                  subtitle: Text('Short description of the announcement...'),
                  trailing: Text('June 10', style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
