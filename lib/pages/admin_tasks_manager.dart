import 'package:flutter/material.dart';

class AdminTasksManagerPage extends StatelessWidget {
  const AdminTasksManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return ListView(
          padding: EdgeInsets.all(isMobile ? 8 : 24),
          children: [
            Text('Submission Tasks Manager', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: isMobile ? 18 : null,
            )),
            SizedBox(height: isMobile ? 8 : 16),
            ElevatedButton(onPressed: () {}, child: Text('Add New Task (placeholder)')),
            SizedBox(height: isMobile ? 8 : 16),
            ...List.generate(2, (i) => Card(
              child: ListTile(
                title: Text('Drill Task ${i + 1}'),
                subtitle: Text('Type: ${i == 0 ? "Monthly" : "Quarterly"}'),
                trailing: Switch(value: i == 0, onChanged: (_) {}),
              ),
            )),
          ],
        );
      },
    );
  }
}
