import 'package:flutter/material.dart';

class AdminTasksManagerPage extends StatelessWidget {
  const AdminTasksManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Submission Tasks Manager', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: () {}, child: Text('Add New Task (placeholder)')),
        const SizedBox(height: 16),
        ...List.generate(2, (i) => Card(
          child: ListTile(
            title: Text('Drill Task ${i + 1}'),
            subtitle: Text('Type: ${i == 0 ? "Monthly" : "Quarterly"}'),
            trailing: Switch(value: i == 0, onChanged: (_) {}),
          ),
        )),
      ],
    );
  }
}
