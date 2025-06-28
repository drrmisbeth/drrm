import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_task_submissions.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  DateTime? _drillDate;
  bool _taskActive = true;

  // UI state for add menu
  bool _showAddMenu = false;

  // Filter/sort/search state
  String _searchText = '';
  String? _filterFrequency;
  String? _filterActive;
  String? _filterYear; // <-- Add this line
  String _sortField = 'deadline';
  bool _sortAsc = true;
  bool _showArchived = false; // Toggle for showing archived tasks

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

  // Add drill date picker
  void _pickDrillDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _drillDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _drillDate = picked;
      });
    }
  }

  Future<void> _addTask() async {
    if (_drillTypeController.text.isEmpty || _selectedFrequency == null || _deadline == null || _drillDate == null) return;
    await FirebaseFirestore.instance.collection('tasks').add({
      'type': _drillTypeController.text,
      'frequency': _selectedFrequency,
      'deadline': Timestamp.fromDate(_deadline!),
      'drillDate': Timestamp.fromDate(_drillDate!),
      'active': true,
      'archived': false, // <-- Ensure archived is set on creation
      'createdAt': FieldValue.serverTimestamp(),
    });
    _drillTypeController.clear();
    setState(() {
      _selectedFrequency = null;
      _deadline = null;
      _drillDate = null;
    });
  }

  Future<void> _toggleActive(String docId, bool value) async {
    // Prevent activating if archived
    final doc = await FirebaseFirestore.instance.collection('tasks').doc(docId).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && (data['archived'] ?? false) == true && value == true) {
      // Do not allow activating archived tasks
      return;
    }
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

  // CSV template header as a string (first 8 lines of your template)
  static const String _csvTemplateHeader = '''
,,,REPUBLIC OF THE PHILIPPINES,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
,,,DEPARTMENT OF EDUCATION,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
,,"SCHOOLS CONSOLIDATED REPORT ON THE CONDUCT OF QUARTERY NATIONWIDE SIMULTANEOUS EARTHQUAKE DRILL
(DepEd Order No. 53, s. 2022)",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
No.,SCHOOL ID,SCHOOL NAME,PRE-DRILL,,,,,,,,,,,,,,ACTUAL DRILL,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,POST-DRILL,,Common issues and concerns encountered during the actual conduct of drill,"LINK FOR DOCUMENTATION
(documentation)

Google Drive Link"
,,,With available Go Bags?,"With updated preparedness, evacuation and response plans?",With updated contingency plan?,With available early warning system?,With available emergency and rescue equipment?,With available First Aid Kits?,"With available communication equipment (internet, cellphone, two-way radio, etc.)?","With sufficient space in school/classrooms to conduct the ""Duck, Cover, and Hold""",Conducted coordination/preparatory meeting with LDRRMO/BDRRMCs?,Conducted an orientation to learners and school personnel on earthquake preparedness measures and the conduct of earthquake and fire drills?,Conducted an orientation to parents on earthquake preparedness measures and the conduct of earthquake and fire drills?,Learners have accomplished the Family Earthquake Preparedness Homework?,"Conducted alternative activities and/or Information, Education and Communication (IEC) campaigns on earthquake preparedness and fire prevention?",Additional Remarks,"Conducted ""DUCK, COVER, and HOLD""?",Conducted evacuation drill?,Additional Remarks,"No. of Personnel
(Total Population)",,,"No. of Personnel Participated
(Partipation Head Count)",,,No. of Learners (Total Population),,,,,,,,,,,,,No. of Learners Participated (Participation Head Count),,,,,,,,,,,,,,Conduct of post-activity exercises,Additional Remarks,,
''';

  Future<void> _exportSubmissions(String taskId, String taskTitle) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exporting submissions...')),
      );

      // --- Fetch all schools ---
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'school')
          .get();
      final allSchools = usersSnap.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      // --- Fetch all submissions for the task ---
      final submissionsSnap = await FirebaseFirestore.instance
          .collection('submissions')
          .where('taskId', isEqualTo: taskId)
          .get();

      // --- Map schoolId to submission ---
      final Map<String, Map<String, dynamic>> schoolIdToSubmission = {};
      for (final doc in submissionsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['schoolId'] != null) {
          schoolIdToSubmission[data['schoolId']] = data;
        }
      }

      // --- 1. Collect all fields and their prefixes from all submissions ---
      Set<String> fieldSet = {};
      Map<String, String> fieldKeyToHeader = {};
      Map<String, String> fieldKeyToPrefix = {};
      for (final doc in submissionsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        void collectKeys(Map<String, dynamic> map, [String prefix = '']) {
          map.forEach((k, v) {
            if (v is Map<String, dynamic>) {
              collectKeys(v, '$prefix$k.');
            } else {
              fieldSet.add('$prefix$k');
              fieldKeyToHeader['$prefix$k'] = k;
              fieldKeyToPrefix['$prefix$k'] = prefix.isNotEmpty ? prefix.substring(0, prefix.length - 1) : '';
            }
          });
        }
        collectKeys(data);
      }

      // --- 3. Define desired order ---
      List<String> preDrillFields = [];
      List<String> actualDrillFields = [];
      List<String> learnersFields = [];
      List<String> personnelFields = [];
      List<String> postDrillFields = [];
      List<String> remainingFields = [];

      for (final f in fieldSet) {
        if (f.startsWith('preDrill.')) {
          preDrillFields.add(f);
        } else if (f.startsWith('actualDrill.')) {
          actualDrillFields.add(f);
        } else if (f.startsWith('learners.')) {
          learnersFields.add(f);
        } else if (f.startsWith('personnel.')) {
          personnelFields.add(f);
        } else if (f.startsWith('postDrill.')) {
          postDrillFields.add(f);
        } else {
          remainingFields.add(f);
        }
      }
      preDrillFields.sort();
      actualDrillFields.sort();
      learnersFields.sort();
      personnelFields.sort();
      postDrillFields.sort();
      remainingFields.sort();

      final List<String> fields = [
        ...preDrillFields,
        ...actualDrillFields,
        ...learnersFields,
        ...personnelFields,
        ...postDrillFields,
        ...remainingFields,
      ];

      // --- Remove unwanted fields from the export ---
      final unwanted = {'schoolId', 'schooluid', 'submittedAt', 'taskId'};
      List<String> filteredFields = fields.where((f) {
        final key = fieldKeyToHeader[f] ?? f;
        // Remove if the last part of the key matches unwanted
        final last = key;
        return !unwanted.contains(last);
      }).toList();

      // --- Prepare prefix row and header row (prefix only once, skip "users") ---
      List<String> prefixRow = ['No.', '', ''];
      List<String> headerRow = ['No.', 'schoolID', 'School Names']; // <-- Change "name" to "School Names"
      String lastPrefix = '';
      for (final f in filteredFields) {
        final prefix = fieldKeyToPrefix[f] ?? '';
        if (prefix.isEmpty || prefix == 'users') {
          prefixRow.add('');
        } else if (prefix != lastPrefix) {
          prefixRow.add(prefix);
          lastPrefix = prefix;
        } else {
          prefixRow.add('');
        }
        headerRow.add(fieldKeyToHeader[f] ?? f);
      }

      // --- 5. Prepare CSV rows for all schools ---
      List<List<dynamic>> csvRows = [];
      csvRows.add(prefixRow);
      csvRows.add(headerRow);
      int rowNum = 1;
      for (final school in allSchools) {
        final schoolId = school['id'] ?? '';
        final schoolID = school['schoolId']?.toString() ?? '';
        final schoolName = school['name']?.toString() ?? '';
        final submission = schoolIdToSubmission[schoolId];
        Map<String, dynamic> flat = {};
        if (submission != null) {
          void flatten(Map<String, dynamic> map, [String prefix = '']) {
            map.forEach((k, v) {
              if (v is Map<String, dynamic>) {
                flatten(v, '$prefix$k.');
              } else if (v is Timestamp) {
                flat['$prefix$k'] = v.toDate().toIso8601String();
              } else if (v is List) {
                flat['$prefix$k'] = v.join(', ');
              } else if (v is bool) {
                flat['$prefix$k'] = v ? 'Yes' : 'No';
              } else {
                flat['$prefix$k'] = v;
              }
            });
          }
          flatten(submission);
        }
        csvRows.add([
          rowNum++,
          schoolID,
          schoolName,
          ...filteredFields.map((f) => flat[f] ?? ''),
        ]);
      }

      // --- Add 5 empty rows ---
      for (int i = 0; i < 5; i++) {
        csvRows.add([]);
      }

      // --- Add signature rows ---
      csvRows.add(['Prepared by:', '', '', 'Noted by:']);
      csvRows.add(['_________________________', '', '', '_________________________']);
      csvRows.add(['MARIBETH A. BALDONADO', '', '', 'RENATO T. BALLESTEROS PhD, CESO V']);
      csvRows.add(['Date:', '', '', 'Date:']);

      // --- 6. Convert to CSV string and save ---
      String csvString = const ListToCsvConverter().convert(csvRows);
      final Uint8List exportBytes = Uint8List.fromList(utf8.encode(csvString));
      await FileSaver.instance.saveFile(
        name: '$taskTitle-submissions',
        bytes: exportBytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${csvRows.length - 2} schools for "$taskTitle".')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
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
        return Container(
          width: double.infinity,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          color: Colors.white, // Content background is white
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            color: Colors.white, // Card background is white
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header Row with Add Task Toggle ---
                  Row(
                    children: [
                      Text(
                        'Submission Tasks Manager',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 22 : 28,
                          color: const Color(0xFFFF9800),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      // Add Task toggle button
                      ElevatedButton.icon(
                        icon: Icon(_showAddMenu ? Icons.close : Icons.add_circle),
                        label: Text(_showAddMenu ? 'Hide Add Task' : 'Add Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        onPressed: () => setState(() => _showAddMenu = !_showAddMenu),
                      ),
                    ],
                  ),
                  // --- Add Task Menu ---
                  if (_showAddMenu)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Flex(
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
                          Padding(
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
                                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: _selectedFrequency == freq
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.black87,
                                      fontWeight: _selectedFrequency == freq ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                              ],
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
                            child: Text(_deadline == null ? 'Pick Deadline' : 'Deadline: ${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}'),
                          ),
                          SizedBox(width: isMobile ? 0 : 12, height: isMobile ? 10 : 0),
                          TextButton(
                            onPressed: _pickDrillDate,
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFE7E1F3),
                              foregroundColor: Color(0xFF7C6CB2),
                              shape: StadiumBorder(),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            ),
                            child: Text(_drillDate == null
                                ? 'Pick Drill Date'
                                : 'Drill Date: ${_drillDate!.year}-${_drillDate!.month.toString().padLeft(2, '0')}-${_drillDate!.day.toString().padLeft(2, '0')}'),
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
                    ),
                  // --- Filter, Sort, Search Row ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: isMobile ? 160 : 220,
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search by type or frequency',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                              isDense: true,
                            ),
                            onChanged: (v) => setState(() => _searchText = v.trim().toLowerCase()),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _filterFrequency,
                          hint: const Text('Filter Frequency'),
                          items: [
                            null,
                            '1st Quarter',
                            '2nd Quarter',
                            '3rd Quarter',
                            '4th Quarter',
                            'Monthly Unannounced'
                          ].map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e ?? 'All'),
                          )).toList(),
                          onChanged: (v) => setState(() => _filterFrequency = v),
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
                          value: _filterActive,
                          hint: const Text('Filter Status'),
                          items: [
                            null,
                            'Active',
                            'Inactive',
                          ].map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e ?? 'All'),
                          )).toList(),
                          onChanged: (v) => setState(() => _filterActive = v),
                        ),
                        DropdownButton<String>(
                          value: _sortField,
                          items: [
                            {'label': 'Deadline', 'value': 'deadline'},
                            {'label': 'Drill Date', 'value': 'drillDate'},
                            {'label': 'Type', 'value': 'type'},
                          ].map((e) => DropdownMenuItem(
                            value: e['value'],
                            child: Text('Sort: ${e['label']}'),
                          )).toList(),
                          onChanged: (v) => setState(() => _sortField = v ?? 'deadline'),
                        ),
                        // Sort order toggle button with dynamic icon
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _sortAsc ? Icons.arrow_upward : Icons.arrow_downward, // <-- changes icon based on _sortAsc
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Toggle sort order',
                            onPressed: () => setState(() => _sortAsc = !_sortAsc),
                          ),
                        ),
                        // --- Show Archived Toggle ---
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _showArchived,
                              onChanged: (v) => setState(() => _showArchived = v ?? false),
                            ),
                            const Text('Show Archived'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // --- Table for tasks ---
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                      // --- Filtering ---
                      if (_searchText.isNotEmpty) {
                        docs = docs.where((doc) {
                          final task = doc.data() as Map<String, dynamic>;
                          final type = (task['type'] ?? '').toString().toLowerCase();
                          final freq = (task['frequency'] ?? '').toString().toLowerCase();
                          return type.contains(_searchText) || freq.contains(_searchText);
                        }).toList();
                      }
                      if (_filterFrequency != null) {
                        docs = docs.where((doc) {
                          final task = doc.data() as Map<String, dynamic>;
                          return task['frequency'] == _filterFrequency;
                        }).toList();
                      }
                      // --- Year filter ---
                      if (_filterYear != null) {
                        docs = docs.where((doc) {
                          final task = doc.data() as Map<String, dynamic>;
                          final deadline = (task['deadline'] as Timestamp?)?.toDate();
                          return deadline != null && deadline.year.toString() == _filterYear;
                        }).toList();
                      }
                      if (_filterActive != null) {
                        docs = docs.where((doc) {
                          final task = doc.data() as Map<String, dynamic>;
                          final active = (task['active'] ?? true) == true;
                          return _filterActive == 'Active' ? active : !active;
                        }).toList();
                      }
                      // --- Archived filter ---
                      docs = docs.where((doc) {
                        final task = doc.data() as Map<String, dynamic>;
                        final archived = (task['archived'] ?? false) == true;
                        return _showArchived ? archived : !archived;
                      }).toList();

                      // --- Sorting ---
                      docs.sort((a, b) {
                        final ta = a.data() as Map<String, dynamic>;
                        final tb = b.data() as Map<String, dynamic>;
                        int cmp;
                        switch (_sortField) {
                          case 'drillDate':
                            final da = (ta['drillDate'] as Timestamp?)?.toDate();
                            final db = (tb['drillDate'] as Timestamp?)?.toDate();
                            cmp = (da ?? DateTime(2100)).compareTo(db ?? DateTime(2100));
                            break;
                          case 'type':
                            cmp = (ta['type'] ?? '').toString().compareTo((tb['type'] ?? '').toString());
                            break;
                          case 'deadline':
                          default:
                            final da = (ta['deadline'] as Timestamp?)?.toDate();
                            final db = (tb['deadline'] as Timestamp?)?.toDate();
                            cmp = (da ?? DateTime(2100)).compareTo(db ?? DateTime(2100));
                        }
                        return _sortAsc ? cmp : -cmp;
                      });

                      if (docs.isEmpty) {
                        return const Text('No tasks yet.');
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          columnSpacing: 28,
                          dataRowMinHeight: 48,
                          columns: const [
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Frequency')),
                            DataColumn(label: Text('Deadline')),
                            DataColumn(label: Text('Drill Date')),
                            DataColumn(label: Text('Active')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: docs.map((doc) {
                            final task = doc.data() as Map<String, dynamic>;
                            final deadline = (task['deadline'] as Timestamp?)?.toDate();
                            final drillDate = (task['drillDate'] as Timestamp?)?.toDate();
                            return DataRow(
                              cells: [
                                DataCell(Text(task['type'] ?? '')),
                                DataCell(Text(task['frequency'] ?? '')),
                                DataCell(Text(
                                  deadline != null
                                      ? _formatDate(deadline)
                                      : "N/A",
                                )),
                                DataCell(Text(
                                  drillDate != null
                                      ? _formatDate(drillDate)
                                      : "N/A",
                                )),
                                DataCell(
                                  Switch(
                                    value: task['active'] ?? true,
                                    onChanged: (task['archived'] ?? false)
                                        ? null // Disable switch if archived
                                        : (val) => _toggleActive(doc.id, val),
                                    activeColor: Color(0xFF7C6CB2),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Edit Task',
                                        onPressed: () async {
                                          final task = doc.data() as Map<String, dynamic>;
                                          final updated = await showDialog<Map<String, dynamic>>(
                                            context: context,
                                            builder: (context) {
                                              final typeController = TextEditingController(text: task['type'] ?? '');
                                              String? freq = task['frequency'];
                                              DateTime? deadline = (task['deadline'] as Timestamp?)?.toDate();
                                              DateTime? drillDate = (task['drillDate'] as Timestamp?)?.toDate();
                                              bool active = task['active'] ?? true;
                                              bool archived = task['archived'] ?? false; // <-- Add archived state
                                              return AlertDialog(
                                                title: const Text('Edit Task'),
                                                content: StatefulBuilder(
                                                  builder: (context, setState) => SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          controller: typeController,
                                                          decoration: const InputDecoration(labelText: 'Type'),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        DropdownButtonFormField<String>(
                                                          value: freq,
                                                          items: [
                                                            '1st Quarter',
                                                            '2nd Quarter',
                                                            '3rd Quarter',
                                                            '4th Quarter',
                                                            'Monthly Unannounced'
                                                          ].map((e) => DropdownMenuItem(
                                                            value: e,
                                                            child: Text(e),
                                                          )).toList(),
                                                          onChanged: (v) => setState(() => freq = v),
                                                          decoration: const InputDecoration(labelText: 'Frequency'),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: OutlinedButton.icon(
                                                                icon: const Icon(Icons.event),
                                                                label: Text(deadline == null
                                                                    ? 'Pick Deadline'
                                                                    : '${deadline?.year ?? ''}-${deadline?.month.toString().padLeft(2, '0') ?? ''}-${deadline?.day.toString().padLeft(2, '0') ?? ''}'),
                                                                onPressed: () async {
                                                                  final picked = await showDatePicker(
                                                                    context: context,
                                                                    initialDate: deadline ?? DateTime.now(),
                                                                    firstDate: DateTime(2020),
                                                                    lastDate: DateTime(2100),
                                                                  );
                                                                  if (picked != null) setState(() => deadline = picked);
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Expanded(
                                                              child: OutlinedButton.icon(
                                                                icon: const Icon(Icons.event_available),
                                                                label: Text(drillDate == null
                                                                    ? 'Pick Drill Date'
                                                                    : '${drillDate?.year ?? ''}-${drillDate?.month.toString().padLeft(2, '0') ?? ''}-${drillDate?.day.toString().padLeft(2, '0') ?? ''}'),
                                                                onPressed: () async {
                                                                  final picked = await showDatePicker(
                                                                    context: context,
                                                                    initialDate: drillDate ?? DateTime.now(),
                                                                    firstDate: DateTime(2020),
                                                                    lastDate: DateTime(2100),
                                                                  );
                                                                  if (picked != null) setState(() => drillDate = picked);
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        SwitchListTile(
                                                          value: active,
                                                          onChanged: (v) => setState(() => active = v),
                                                          title: const Text('Active'),
                                                        ),
                                                        SwitchListTile(
                                                          value: archived,
                                                          onChanged: (v) => setState(() => archived = v),
                                                          title: const Text('Archived'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop({
                                                        'type': typeController.text,
                                                        'frequency': freq,
                                                        'deadline': deadline,
                                                        'drillDate': drillDate,
                                                        'active': active,
                                                        'archived': archived, // <-- Pass archived value
                                                      });
                                                    },
                                                    child: const Text('Update'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (updated != null) {
                                            // If archived is true, always set active to false
                                            final updateData = {
                                              'type': updated['type'],
                                              'frequency': updated['frequency'],
                                              'deadline': updated['deadline'] != null ? Timestamp.fromDate(updated['deadline']) : null,
                                              'drillDate': updated['drillDate'] != null ? Timestamp.fromDate(updated['drillDate']) : null,
                                              'active': updated['archived'] == true ? false : updated['active'],
                                              'archived': updated['archived'],
                                            };
                                            await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update(updateData);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.black54),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Task'),
                                              content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            _deleteTask(doc.id);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.visibility, color: Colors.blue),
                                        tooltip: 'View Submissions',
                                        onPressed: () => _viewSubmissions(doc.id, '${task['type']} (${task['frequency']})'),
                                      ),
                                      // --- Export Button with export logic ---
                                      TextButton(
                                        child: const Text('Export'),
                                        onPressed: () => _exportSubmissions(doc.id, '${task['type']} (${task['frequency']})'),
                                      ),
                                      // --- Archive Button ---
                                      if (!(task['archived'] ?? false))
                                        TextButton.icon(
                                          icon: Icon(Icons.archive, color: Colors.orange),
                                          label: const Text('Archive', style: TextStyle(color: Colors.orange)),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.orange,
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Archive Task'),
                                                content: const Text('Are you sure you want to archive this task?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: const Text('Archive', style: TextStyle(color: Colors.orange)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              // Set archived: true and active: false
                                              await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update({
                                                'archived': true,
                                                'active': false,
                                              });
                                            }
                                          },
                                        ),
                                      // --- Unarchive Button ---
                                      if ((task['archived'] ?? false))
                                        TextButton.icon(
                                          icon: Icon(Icons.unarchive, color: Colors.green),
                                          label: const Text('Unarchive', style: TextStyle(color: Colors.green)),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.green,
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Unarchive Task'),
                                                content: const Text('Are you sure you want to unarchive this task?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: const Text('Unarchive', style: TextStyle(color: Colors.green)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              // Set archived: false (do not auto-activate)
                                              await FirebaseFirestore.instance.collection('tasks').doc(doc.id).update({
                                                'archived': false,
                                              });
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
