import 'package:flutter/material.dart';

class SchoolMySubmissionsPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const SchoolMySubmissionsPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Submissions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 28),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: colorScheme.secondary.withOpacity(0.13),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(colorScheme.primary.withOpacity(0.13)),
                    columns: const [
                      DataColumn(label: Text('Task', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Submitted', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List.generate(3, (i) => DataRow(cells: [
                      DataCell(Text('Drill ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black))),
                      DataCell(
                        Chip(
                          label: Text(i == 0 ? 'Pending' : 'Approved'),
                          backgroundColor: i == 0 ? colorScheme.primary.withOpacity(0.18) : colorScheme.secondary.withOpacity(0.18),
                          labelStyle: TextStyle(
                            color: i == 0 ? colorScheme.primary : colorScheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        ),
                      ),
                      DataCell(Text('June ${8 + i}', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black))),
                      DataCell(
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            side: BorderSide(color: colorScheme.primary, width: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          child: const Text('View'),
                        ),
                      ),
                    ])),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
