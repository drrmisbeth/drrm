import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_task_submissions.dart';

class AdminTasksManagerPage extends StatefulWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AdminTasksManagerPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  State<AdminTasksManagerPage> createState() => _AdminTasksManagerPageState();
}

class _AdminTasksManagerPageState extends State<AdminTasksManagerPage> {
  final _drillTypeController = TextEditingController();
  String? _selectedFrequency;
  DateTime? _deadline;
  bool _taskActive = true;

  void _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _addTask() async {
    if (_drillTypeController.text.isEmpty || _selectedFrequency == null || _deadline == null) return;
    await FirebaseFirestore.instance.collection('tasks').add({
      'type': _drillTypeController.text,
      'frequency': _selectedFrequency,
      'deadline': Timestamp.fromDate(_deadline!),
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _drillTypeController.clear();
    setState(() {
      _selectedFrequency = null;
      _deadline = null;
    });
  }

  Future<void> _toggleActive(String docId, bool value) async {
    await FirebaseFirestore.instance.collection('tasks').doc(docId).update({'active': value});
  }

  Future<void> _deleteTask(String docId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(docId).delete();
  }

  void _viewSubmissions(String taskId, String taskTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminTaskSubmissionsPage(taskId: taskId, taskTitle: taskTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Modern color scheme
    final Color orange = const Color(0xFFFF9800);
    final Color yellow = const Color(0xFFFFEB3B);
    final Color red = const Color(0xFFF44336);
    final Color accent = const Color(0xFFFEF3E2);

    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 32,
            vertical: isMobile ? 8 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submission Tasks Manager',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 22 : 28,
                  color: orange,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: isMobile ? 18 : 32),
              // Input Row
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isMobile ? 10 : 0, right: isMobile ? 0 : 12),
                      child: TextField(
                        controller: _drillTypeController,
                        decoration: InputDecoration(
                          hintText: 'Drill Type (e.g. Earthquake)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 10 : 0),
                  // Frequency buttons
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isMobile ? 10 : 0),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final freq in [
                            '1st Quarter',
                            '2nd Quarter',
                            '3rd Quarter',
                            '4th Quarter',
                            'Monthly Unannounced'
                          ])
                            ChoiceChip(
                              label: Text(freq, style: TextStyle(fontSize: isMobile ? 12 : 14)),
                              selected: _selectedFrequency == freq,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFrequency = selected ? freq : null;
                                });
                              },
                              selectedColor: colorScheme.primary.withOpacity(0.18),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: _selectedFrequency == freq
                                    ? colorScheme.primary
                                    : Colors.black87,
                                fontWeight: _selectedFrequency == freq ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 10 : 0),
                  TextButton(
                    onPressed: _pickDeadline,
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFE7E1F3),
                      foregroundColor: Color(0xFF7C6CB2),
                      shape: StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: Text(_deadline == null ? 'Pick Deadline' : 'Deadline: ${_deadline!.toLocal()}'.split(' ')[0]),
                  ),
                  SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 10 : 0),
                  TextButton(
                    onPressed: _addTask,
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFF3EFFF),
                      foregroundColor: Color(0xFF7C6CB2),
                      shape: StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 18 : 32),
              // Firestore task list
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .orderBy('deadline')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Text('No tasks yet.');
                  }
                  return Column(
                    children: docs.map((doc) {
                      final task = doc.data() as Map<String, dynamic>;
                      final deadline = (task['deadline'] as Timestamp?)?.toDate();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: orange.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.13),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: orange.withOpacity(0.13),
                            child: Icon(Icons.event_note, color: orange),
                          ),
                          title: Text(
                            '${task['type']} (${task['frequency']})',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C6CB2),
                              fontSize: constraints.maxWidth < 700 ? 15 : 17,
                            ),
                          ),
                          subtitle: Text(
                            'Deadline: ${deadline != null ? "${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}" : "N/A"}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: constraints.maxWidth < 700 ? 12 : 14,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: task['active'] ?? true,
                                onChanged: (val) => _toggleActive(doc.id, val),
                                activeColor: Color(0xFF7C6CB2),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.black54),
                                onPressed: () => _deleteTask(doc.id),
                              ),
                              IconButton(
                                icon: Icon(Icons.visibility, color: Colors.blue),
                                tooltip: 'View Submissions',
                                onPressed: () => _viewSubmissions(doc.id, '${task['type']} (${task['frequency']})'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
