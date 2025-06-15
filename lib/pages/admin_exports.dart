import 'package:flutter/material.dart';

class AdminExportsPage extends StatelessWidget {
  const AdminExportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 8 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Exports',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: isMobile ? 18 : null,
                      ),
                ),
                SizedBox(height: isMobile ? 10 : 24),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Export to PDF (placeholder)'),
                ),
                SizedBox(height: isMobile ? 8 : 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.table_chart),
                  label: Text('Export to Excel (placeholder)'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
