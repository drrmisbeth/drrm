import 'package:flutter/material.dart';

class SchoolMySubmissionsPage extends StatelessWidget {
  const SchoolMySubmissionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Submissions',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
        ),
        const SizedBox(height: 28),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Task')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Submitted')),
                  DataColumn(label: Text('Action')),
                ],
                rows: List.generate(3, (i) => DataRow(cells: [
                  DataCell(Text('Drill ${i + 1}')),
                  DataCell(
                    Chip(
                      label: Text(i == 0 ? 'Pending' : 'Approved'),
                      backgroundColor: i == 0 ? Colors.orange[100] : Colors.green[100],
                      labelStyle: TextStyle(
                        color: i == 0 ? Colors.orange[800] : Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    ),
                  ),
                  DataCell(Text('June ${8 + i}')),
                  DataCell(
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: StadiumBorder(),
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text('View'),
                    ),
                  ),
                ])),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
