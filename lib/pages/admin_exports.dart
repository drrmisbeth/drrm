import 'package:flutter/material.dart';

class AdminExportsPage extends StatelessWidget {
  const AdminExportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Exports', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Export to PDF (placeholder)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.table_chart),
              label: Text('Export to Excel (placeholder)'),
            ),
          ],
        ),
      ),
    );
  }
}
