import 'package:flutter/material.dart';

class AdminAllSubmissionsPage extends StatelessWidget {
  const AdminAllSubmissionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('All Submissions', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        DataTable(
          columns: const [
            DataColumn(label: Text('School')),
            DataColumn(label: Text('Task')),
            DataColumn(label: Text('Submitted')),
            DataColumn(label: Text('Action')),
          ],
          rows: List.generate(3, (i) => DataRow(cells: [
            DataCell(Text('School ${i + 1}')),
            DataCell(Text('Drill ${i + 1}')),
            DataCell(Text(i % 2 == 0 ? 'Y' : 'N')),
            DataCell(TextButton(onPressed: () {}, child: Text('View'))),
          ])),
        ),
      ],
    );
  }
}
