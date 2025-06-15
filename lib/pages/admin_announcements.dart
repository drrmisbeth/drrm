import 'package:flutter/material.dart';

class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return ListView(
          padding: EdgeInsets.all(isMobile ? 4 : 0),
          children: [
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: isMobile ? 18 : 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Announcement',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                            fontSize: isMobile ? 16 : null,
                          ),
                    ),
                    SizedBox(height: isMobile ? 10 : 18),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 14),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: isMobile ? 10 : 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.send),
                        label: Text('Create (placeholder)'),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 14 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Past Announcements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                            fontSize: isMobile ? 16 : null,
                          ),
                    ),
                    SizedBox(height: isMobile ? 10 : 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Title')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Description')),
                        ],
                        rows: List.generate(2, (i) => DataRow(cells: [
                          DataCell(Text('Announcement $i')),
                          DataCell(Text('June ${10 + i}')),
                          DataCell(Text('Description $i')),
                        ])),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
