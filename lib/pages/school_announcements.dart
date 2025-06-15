import 'package:flutter/material.dart';

class SchoolAnnouncementsPage extends StatelessWidget {
  const SchoolAnnouncementsPage({Key? key}) : super(key: key);

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
                'Announcements',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: isMobile ? 22 : null,
                    ),
              ),
              SizedBox(height: isMobile ? 16 : 28),
              ...List.generate(3, (i) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: EdgeInsets.only(bottom: isMobile ? 10 : 18),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondary.withOpacity(0.15),
                    child: Icon(Icons.campaign, color: colorScheme.secondary, size: 26),
                    radius: 24,
                  ),
                  title: Text(
                    'Announcement Title $i',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: isMobile ? 13 : 16),
                  ),
                  subtitle: Text('Short description for announcement $i.'),
                  trailing: Text('June ${10 + i}', style: TextStyle(color: Colors.grey[600], fontSize: isMobile ? 12 : 14)),
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}
