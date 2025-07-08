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
  String? _filterYear;
  String _sortField = 'submittedAt';
  bool _sortAsc = false;

  // --- Pagination state ---
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: Text('Submissions for ${widget.taskTitle}'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 8 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search, filter, sort row
            Wrap(
              spacing: isMobile ? 6 : 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: isMobile ? 140 : 220,
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
            SizedBox(height: isMobile ? 8 : 18),
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
                        for (var s in submissions) (s['schooluid'] as String): s
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

                      // --- Pagination ---
                      final totalRows = rows.length;
                      final totalPages = (totalRows / _rowsPerPage).ceil();
                      final start = _currentPage * _rowsPerPage;
                      final end = (start + _rowsPerPage) > totalRows ? totalRows : (start + _rowsPerPage);
                      final pageRows = rows.sublist(
                        start < totalRows ? start : 0,
                        end < totalRows ? end : totalRows,
                      );

                      return Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: isMobile ? 10 : 28,
                                  dataRowMinHeight: isMobile ? 32 : 44,
                                  columns: const [
                                    DataColumn(label: Text('School')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Submitted At')),
                                    DataColumn(label: Text('Action')),
                                  ],
                                  rows: pageRows.map((row) {
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
                                                    final submission = row['submission'];
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => AdminSubmissionDetailPage(
                                                          submission: submission,
                                                          schoolName: row['schoolName'],
                                                          taskTitle: widget.taskTitle,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('View'),
                                                )
                                              : const SizedBox(),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          // --- Pagination controls ---
                          if (totalPages > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 0
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  Text('Page ${_currentPage + 1} of $totalPages'),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: (_currentPage < totalPages - 1)
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                        ],
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

// Add this new page at the end of the file
class AdminSubmissionDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot submission;
  final String schoolName;
  final String taskTitle;
  const AdminSubmissionDetailPage({
    Key? key,
    required this.submission,
    required this.schoolName,
    required this.taskTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;
    final data = submission.data() as Map<String, dynamic>;
    final submittedAt = data['submittedAt'] != null
        ? (data['submittedAt'] as Timestamp).toDate()
        : null;

    // Helper for Yes/No/null
    String yn(dynamic v) {
      if (v == true) return "Yes";
      if (v == false) return "No";
      return "-";
    }

    // Pre-Drill
    final preDrill = (data['preDrill'] ?? {}) as Map<String, dynamic>;
    final additionalRemarks = data['additionalRemarks'] ?? "";

    // Actual Drill
    final actualDrill = (data['actualDrill'] ?? {}) as Map<String, dynamic>;

    // Personnel
    final personnel = (data['personnel'] ?? {}) as Map<String, dynamic>;

    // Learners
    final learners = (data['learners'] ?? {}) as Map<String, dynamic>;

    // Post-Drill
    final postDrill = (data['postDrill'] ?? {}) as Map<String, dynamic>;

    // Attachments
    final attachments = (data['attachments'] ?? []) as List<dynamic>;
    final attachmentNames = (data['attachmentNames'] ?? []) as List<dynamic>;

    // External Links
    final externalLinks = (data['externalLinks'] ?? []) as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Submission Detail'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 24),
        child: ListView(
          children: [
            Text(
              taskTitle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 16 : 22, color: colorScheme.primary),
            ),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              'School: $schoolName',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 13 : 16),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              'Submitted At: ${submittedAt != null ? _formatDate(submittedAt) : "-"}',
              style: TextStyle(fontSize: isMobile ? 12 : 15, color: Colors.black87),
            ),
            Divider(height: isMobile ? 16 : 32, thickness: 1.2),

            // Pre-Drill Section
            Text('Pre-Drill:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...preDrill.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text('${e.key}', style: const TextStyle(fontSize: 15))),
                  Text(yn(e.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
            if (additionalRemarks.toString().trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: Text('Additional Remarks', style: TextStyle(fontSize: 15))),
                    Expanded(child: Text(additionalRemarks, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Actual Drill Section
            Text('Actual Drill:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Expanded(child: Text('Conducted "DUCK, COVER, and HOLD"?', style: TextStyle(fontSize: 15))),
                Text(yn(actualDrill['duckCoverHold']), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            Row(
              children: [
                const Expanded(child: Text('Conducted evacuation drill?', style: TextStyle(fontSize: 15))),
                Text(yn(actualDrill['conductedEvacuationDrill']), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            if ((actualDrill['otherActivities'] ?? '').toString().trim().isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: Text('Other sub-activities conducted', style: TextStyle(fontSize: 15))),
                  Expanded(child: Text(actualDrill['otherActivities'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            const SizedBox(height: 16),

            // Personnel & Learners Section
            Text('Personnel & Learners:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Personnel (Total Population):', style: const TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(child: Text('Teaching Personnel: ${personnel['teachingTotal'] ?? "-"}')),
                Expanded(child: Text('Non-Teaching Personnel: ${personnel['nonTeachingTotal'] ?? "-"}')),
              ],
            ),
            Text('Personnel Participated:', style: const TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(child: Text('Teaching: ${personnel['teachingParticipated'] ?? "-"}')),
                Expanded(child: Text('Non-Teaching: ${personnel['nonTeachingParticipated'] ?? "-"}')),
              ],
            ),
            const SizedBox(height: 6),
            Text('Learners (Total Population):', style: const TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(child: Text('Male: ${learners['male'] ?? "-"}')),
                Expanded(child: Text('Female: ${learners['female'] ?? "-"}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('IP: ${learners['ip'] ?? "-"}')),
                Expanded(child: Text('Muslim: ${learners['muslim'] ?? "-"}')),
                Expanded(child: Text('With Disability: ${learners['pwd'] ?? "-"}')),
              ],
            ),
            Text('Learners Participated:', style: const TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(child: Text('Male: ${learners['participatedMale'] ?? "-"}')),
                Expanded(child: Text('Female: ${learners['participatedFemale'] ?? "-"}')),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('IP: ${learners['participatedIP'] ?? "-"}')),
                Expanded(child: Text('Muslim: ${learners['participatedMuslim'] ?? "-"}')),
                Expanded(child: Text('With Disability: ${learners['participatedPWD'] ?? "-"}')),
              ],
            ),
            const SizedBox(height: 16),

            // Post-Drill Section
            Text('Post-Drill:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Expanded(child: Text('Conduct a review of Contingency Plan?', style: TextStyle(fontSize: 15))),
                Text(yn(postDrill['reviewedContingencyPlan']), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            if ((postDrill['issuesConcerns'] ?? '').toString().trim().isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: Text('Issues/Concerns encountered', style: TextStyle(fontSize: 15))),
                  Expanded(child: Text(postDrill['issuesConcerns'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            const SizedBox(height: 16),

            // Attachments Section
            if (attachments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attachments:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...List.generate(attachments.length, (i) => Row(
                    children: [
                      const Icon(Icons.attach_file, size: 18),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Open link
                            final url = attachments[i];
                            // ignore: deprecated_member_use
                            // launch(url); // You may use url_launcher if desired
                          },
                          child: Text(
                            attachmentNames.length > i ? attachmentNames[i] : 'Attachment ${i + 1}',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),
                ],
              ),

            // External Links Section
            if (externalLinks.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('External Links:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ...externalLinks.map((link) => Row(
                    children: [
                      const Icon(Icons.link, size: 18),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // ignore: deprecated_member_use
                            // launch(link); // You may use url_launcher if desired
                          },
                          child: Text(
                            link,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
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

// Helper function to count submissions for a specific taskId
int countSubmissionsForTask(List<QueryDocumentSnapshot> submissions, String taskId) {
  return submissions.where((s) => s['taskId'] == taskId).length;
}
