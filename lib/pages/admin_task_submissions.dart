import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTaskSubmissionsPage extends StatefulWidget {
  final String taskId;
  final String taskTitle;
  const AdminTaskSubmissionsPage({Key? key, required this.taskId, required this.taskTitle}) : super(key: key);

  @override
  State<AdminTaskSubmissionsPage> createState() => _AdminTaskSubmissionsPageState();
}

class _AdminTaskSubmissionsPageState extends State<AdminTaskSubmissionsPage> {
  String _searchText = '';
  String? _filterStatus;
  String? _filterYear; // <-- Add this line
  String _sortField = 'submittedAt';
  bool _sortAsc = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Submissions for ${widget.taskTitle}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search, filter, sort row
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by school name/email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchText = v.trim().toLowerCase()),
                  ),
                ),
                DropdownButton<String>(
                  value: _filterStatus,
                  hint: const Text('Filter Status'),
                  items: [
                    null,
                    'Submitted',
                    'Not Submitted',
                  ].map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e ?? 'All'),
                  )).toList(),
                  onChanged: (v) => setState(() => _filterStatus = v),
                ),
                // --- Year Filter ---
                DropdownButton<String>(
                  value: _filterYear,
                  hint: const Text('Filter Year'),
                  items: [
                    null,
                    ...List.generate(10, (i) => (DateTime.now().year - 5 + i).toString())
                  ].map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e ?? 'All'),
                  )).toList(),
                  onChanged: (v) => setState(() => _filterYear = v),
                ),
                DropdownButton<String>(
                  value: _sortField,
                  items: [
                    {'label': 'Submitted At', 'value': 'submittedAt'},
                    {'label': 'School Name', 'value': 'schoolName'},
                  ].map((e) => DropdownMenuItem(
                    value: e['value'],
                    child: Text('Sort: ${e['label']}'),
                  )).toList(),
                  onChanged: (v) => setState(() => _sortField = v ?? 'submittedAt'),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'Toggle sort order',
                    onPressed: () => setState(() => _sortAsc = !_sortAsc),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('submissions')
                    .where('taskId', isEqualTo: widget.taskId)
                    .snapshots(),
                builder: (context, subSnap) {
                  if (subSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final submissions = subSnap.hasData ? subSnap.data!.docs : [];
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'school')
                        .snapshots(),
                    builder: (context, schoolSnap) {
                      if (!schoolSnap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final schools = schoolSnap.data!.docs;
                      // Map schoolId to school info
                      final Map<String, Map<String, dynamic>> schoolMap = {
                        for (var s in schools) s.id: s.data() as Map<String, dynamic>
                      };
                      // Map schoolId to submission
                      final Map<String, QueryDocumentSnapshot> subMap = {
                        for (var s in submissions) (s['schoolId'] as String): s
                      };

                      // Build table rows
                      List<Map<String, dynamic>> rows = [];
                      for (final school in schools) {
                        final schoolId = school.id;
                        final schoolInfo = school.data() as Map<String, dynamic>;
                        final sub = subMap[schoolId];
                        final submittedAt = sub != null && sub['submittedAt'] != null
                            ? (sub['submittedAt'] as Timestamp).toDate()
                            : null;
                        rows.add({
                          'schoolId': schoolId,
                          'schoolName': schoolInfo['name'] ?? schoolInfo['email'] ?? 'School',
                          'submittedAt': submittedAt,
                          'status': sub != null ? 'Submitted' : 'Not Submitted',
                          'submission': sub,
                        });
                      }

                      // --- Filtering ---
                      if (_searchText.isNotEmpty) {
                        rows = rows.where((row) {
                          final name = (row['schoolName'] ?? '').toString().toLowerCase();
                          return name.contains(_searchText);
                        }).toList();
                      }
                      if (_filterStatus != null) {
                        rows = rows.where((row) => row['status'] == _filterStatus).toList();
                      }
                      // --- Year filter ---
                      if (_filterYear != null) {
                        rows = rows.where((row) {
                          final submittedAt = row['submittedAt'] as DateTime?;
                          return submittedAt != null && submittedAt.year.toString() == _filterYear;
                        }).toList();
                      }

                      // --- Sorting ---
                      rows.sort((a, b) {
                        int cmp;
                        switch (_sortField) {
                          case 'schoolName':
                            cmp = (a['schoolName'] ?? '').compareTo(b['schoolName'] ?? '');
                            break;
                          case 'submittedAt':
                          default:
                            final da = a['submittedAt'] as DateTime?;
                            final db = b['submittedAt'] as DateTime?;
                            cmp = (da ?? DateTime(1900)).compareTo(db ?? DateTime(1900));
                        }
                        return _sortAsc ? cmp : -cmp;
                      });

                      return SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columnSpacing: 28,
                          dataRowMinHeight: 44,
                          columns: const [
                            DataColumn(label: Text('School')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Submitted At')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: rows.map((row) {
                            return DataRow(
                              cells: [
                                DataCell(Text(row['schoolName'] ?? '')),
                                DataCell(
                                  Chip(
                                    label: Text(row['status']),
                                    backgroundColor: row['status'] == 'Submitted'
                                        ? colorScheme.primary.withOpacity(0.18)
                                        : colorScheme.secondary.withOpacity(0.18),
                                    labelStyle: TextStyle(
                                      color: row['status'] == 'Submitted'
                                          ? colorScheme.primary
                                          : colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  ),
                                ),
                                DataCell(Text(
                                  row['submittedAt'] != null
                                      ? _formatDate(row['submittedAt'])
                                      : '-',
                                )),
                                DataCell(
                                  row['status'] == 'Submitted'
                                      ? TextButton(
                                          onPressed: () {
                                            // TODO: Show submission details dialog/page
                                          },
                                          child: const Text('View'),
                                        )
                                      : const SizedBox(),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[date.month]} ${date.day}, ${date.year}";
  }
}
