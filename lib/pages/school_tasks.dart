import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class SchoolTasksPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const SchoolTasksPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;
    return LayoutBuilder(
      builder: (context, constraints) {
        // final isMobile = constraints.maxWidth < 700; // Use MediaQuery for consistency
        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 24,
                vertical: isMobile ? 16 : 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submission Tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 22 : 30,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 28),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .where('active', isEqualTo: true) // Only show active tasks
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Text('No tasks.');
                      }
                      final user = FirebaseAuth.instance.currentUser;
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('submissions')
                            .where('schooluid', isEqualTo: user?.uid)
                            .snapshots(),
                        builder: (context, subSnap) {
                          if (!subSnap.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final submissions = subSnap.data!.docs;
                          final submittedTaskIds = submissions
                              .map((s) => s['taskId'] as String?)
                              .where((id) => id != null)
                              .toSet();

                          return SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: isMobile ? 600 : 0,
                                ),
                                child: DataTable(
                                  columnSpacing: isMobile ? 8 : 24,
                                  dataRowMinHeight: isMobile ? 36 : 44,
                                  columns: const [
                                    DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Drill Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: docs.map((doc) {
                                    final task = doc.data() as Map<String, dynamic>;
                                    final deadline = (task['deadline'] as Timestamp?)?.toDate();
                                    final drillDate = (task['drillDate'] as Timestamp?)?.toDate();
                                    final isActive = task['active'] ?? true;
                                    IconData icon;
                                    Color iconBg;
                                    switch ((task['type'] as String).toLowerCase()) {
                                      case 'earthquake':
                                        icon = Icons.public;
                                        iconBg = colorScheme.primary;
                                        break;
                                      case 'fire':
                                        icon = Icons.local_fire_department;
                                        iconBg = colorScheme.error;
                                        break;
                                      default:
                                        icon = Icons.warning_amber;
                                        iconBg = colorScheme.secondary;
                                    }
                                    final isSubmitted = submittedTaskIds.contains(doc.id);
                                    return DataRow(
                                      cells: [
                                        DataCell(Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: iconBg,
                                              child: Icon(icon, color: Colors.white, size: 22),
                                              radius: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(task['type'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                          ],
                                        )),
                                        DataCell(Text(task['frequency'] ?? '')),
                                        DataCell(Text(
                                          deadline != null
                                              ? "${_formatDate(deadline)}"
                                              : "N/A",
                                        )),
                                        DataCell(Text(
                                          drillDate != null
                                              ? "${_formatDate(drillDate)}"
                                              : "N/A",
                                        )),
                                        DataCell(
                                          isActive
                                              ? Chip(
                                                  label: const Text('Active'),
                                                  backgroundColor: colorScheme.primary.withOpacity(0.18),
                                                  labelStyle: TextStyle(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                )
                                              : Chip(
                                                  label: const Text('Inactive'),
                                                  backgroundColor: Colors.grey[300],
                                                  labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                ),
                                        ),
                                        DataCell(
                                          // Allow editing: If already submitted, show "Edit" button instead of disabled "Submitted"
                                          isSubmitted
                                              ? ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    shape: const StadiumBorder(),
                                                    backgroundColor: Colors.grey[400],
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                    elevation: 0,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) => SchoolSubmitFormPage(taskId: doc.id),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.edit, size: 20),
                                                  label: const Text('Edit Submission'),
                                                )
                                              : isActive
                                                  ? ElevatedButton.icon(
                                                      style: ElevatedButton.styleFrom(
                                                        shape: const StadiumBorder(),
                                                        backgroundColor: colorScheme.primary,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                        elevation: 0,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (_) => SchoolSubmitFormPage(taskId: doc.id),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.upload_rounded, size: 20),
                                                      label: const Text('Submit'),
                                                    )
                                                  : ElevatedButton.icon(
                                                      style: ElevatedButton.styleFrom(
                                                        shape: const StadiumBorder(),
                                                        backgroundColor: Colors.grey[300],
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                        elevation: 0,
                                                      ),
                                                      onPressed: null,
                                                      icon: const Icon(Icons.lock, size: 20),
                                                      label: const Text('Closed'),
                                                    ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          );
                        },
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
}
// --- Multi-step Submit Form Page ---

class SchoolSubmitFormPage extends StatefulWidget {
  final String taskId;
  const SchoolSubmitFormPage({Key? key, required this.taskId}) : super(key: key);

  @override
  State<SchoolSubmitFormPage> createState() => _SchoolSubmitFormPageState();
}

class _SchoolSubmitFormPageState extends State<SchoolSubmitFormPage> {
  int _step = 0;
  bool _submitting = false;

  // Pre-Drill
  final Map<String, bool?> preDrill = {
    'With available Go Bags?': null,
    'With updated preparedness, evacuation, and response plans?': null,
    'With updated contingency plan?': null,
    'With available early warning system?': null,
    'With available emergency and rescue equipment?': null,
    'With available First Aid Kit?': null,
    'With available communication equipment (internet, cellphone, two-way radio, etc.)?': null,
    'With sufficient space in school/classrooms to conduct the "Duck, Cover, and Hold"?': null,
    'Conducted coordination/preparatory meeting with LDRRMO/BDRRMC?': null,
    'Conducted orientation to learners and school personnel on earthquake preparedness measures and the conduct of earthquake and fire drills?': null,
    'Conducted an orientation to parents on earthquake preparedness measures and the conduct of earthquake and fire drills?': null,
    'Learners have accomplished the Family Earthquake Preparedness Homework?': null,
    'Conducted alternative activities and/or Information, Education and Communication (IEC) campaigns on earthquake preparedness and fire prevention?': null,
  };
  final TextEditingController preDrillRemarks = TextEditingController();

  // Actual Drill
  bool? duckCoverHold;
  bool? conductedEvacuationDrill;
  final TextEditingController otherActivities = TextEditingController();
  final TextEditingController actualDrillRemarks = TextEditingController();

  // Personnel/Participants
  // --- Total Population ---
  final TextEditingController teachingPersonnelTotalMale = TextEditingController();
  final TextEditingController teachingPersonnelTotalFemale = TextEditingController();
  final TextEditingController nonTeachingPersonnelTotalMale = TextEditingController();
  final TextEditingController nonTeachingPersonnelTotalFemale = TextEditingController();

  final TextEditingController learnersTotalMale = TextEditingController();
  final TextEditingController learnersTotalFemale = TextEditingController();
  final TextEditingController ipTotalMale = TextEditingController();
  final TextEditingController ipTotalFemale = TextEditingController();
  final TextEditingController muslimTotalMale = TextEditingController();
  final TextEditingController muslimTotalFemale = TextEditingController();
  final TextEditingController pwdTotalMale = TextEditingController();
  final TextEditingController pwdTotalFemale = TextEditingController();

  // --- Participated ---
  final TextEditingController teachingPersonnelParticipatedMale = TextEditingController();
  final TextEditingController teachingPersonnelParticipatedFemale = TextEditingController();
  final TextEditingController nonTeachingPersonnelParticipatedMale = TextEditingController();
  final TextEditingController nonTeachingPersonnelParticipatedFemale = TextEditingController();

  final TextEditingController learnersParticipatedMale = TextEditingController();
  final TextEditingController learnersParticipatedFemale = TextEditingController();
  final TextEditingController ipParticipatedMale = TextEditingController();
  final TextEditingController ipParticipatedFemale = TextEditingController();
  final TextEditingController muslimParticipatedMale = TextEditingController();
  final TextEditingController muslimParticipatedFemale = TextEditingController();
  final TextEditingController pwdParticipatedMale = TextEditingController();
  final TextEditingController pwdParticipatedFemale = TextEditingController();

  // Post-Drill
  bool? reviewedContingencyPlan;
  final TextEditingController issuesConcerns = TextEditingController();
  final TextEditingController postDrillRemarks = TextEditingController();

  // New: Controller for external links
  final TextEditingController linksController = TextEditingController();

  // --- NEW: For edit mode ---
  bool _loadingSubmission = true;
  String? _submissionId; // For updating existing submission

  @override
  void initState() {
    super.initState();
    _loadSubmissionIfExists();
  }

  Future<void> _loadSubmissionIfExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Find submission by schooluid and taskId
    final snap = await FirebaseFirestore.instance
        .collection('submissions')
        .where('schooluid', isEqualTo: user.uid)
        .where('taskId', isEqualTo: widget.taskId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      final data = doc.data();
      _submissionId = doc.id;
      // Remove: _alreadySubmitted = true;
      // Pre-Drill
      final Map<String, dynamic> pd = Map<String, dynamic>.from(data['preDrill'] ?? {});
      for (final k in preDrill.keys) {
        preDrill[k] = pd[k];
      }
      preDrillRemarks.text = data['preDrillRemarks'] ?? '';
      // Actual Drill
      final actual = data['actualDrill'] ?? {};
      duckCoverHold = actual['duckCoverHold'];
      conductedEvacuationDrill = actual['conductedEvacuationDrill'];
      otherActivities.text = actual['otherActivities'] ?? '';
      actualDrillRemarks.text = data['actualDrillRemarks'] ?? '';
      // Personnel
      final personnel = data['personnel'] ?? {};
      teachingPersonnelTotalMale.text = personnel['teachingTotalMale'] ?? '';
      teachingPersonnelTotalFemale.text = personnel['teachingTotalFemale'] ?? '';
      nonTeachingPersonnelTotalMale.text = personnel['nonTeachingTotalMale'] ?? '';
      nonTeachingPersonnelTotalFemale.text = personnel['nonTeachingTotalFemale'] ?? '';
      teachingPersonnelParticipatedMale.text = personnel['teachingParticipatedMale'] ?? '';
      teachingPersonnelParticipatedFemale.text = personnel['teachingParticipatedFemale'] ?? '';
      nonTeachingPersonnelParticipatedMale.text = personnel['nonTeachingParticipatedMale'] ?? '';
      nonTeachingPersonnelParticipatedFemale.text = personnel['nonTeachingParticipatedFemale'] ?? '';
      // Learners
      final learners = data['learners'] ?? {};
      learnersTotalMale.text = learners['totalMale'] ?? '';
      learnersTotalFemale.text = learners['totalFemale'] ?? '';
      ipTotalMale.text = learners['ipTotalMale'] ?? '';
      ipTotalFemale.text = learners['ipTotalFemale'] ?? '';
      muslimTotalMale.text = learners['muslimTotalMale'] ?? '';
      muslimTotalFemale.text = learners['muslimTotalFemale'] ?? '';
      pwdTotalMale.text = learners['pwdTotalMale'] ?? '';
      pwdTotalFemale.text = learners['pwdTotalFemale'] ?? '';
      learnersParticipatedMale.text = learners['participatedMale'] ?? '';
      learnersParticipatedFemale.text = learners['participatedFemale'] ?? '';
      ipParticipatedMale.text = learners['ipParticipatedMale'] ?? '';
      ipParticipatedFemale.text = learners['ipParticipatedFemale'] ?? '';
      muslimParticipatedMale.text = learners['muslimParticipatedMale'] ?? '';
      muslimParticipatedFemale.text = learners['muslimParticipatedFemale'] ?? '';
      pwdParticipatedMale.text = learners['pwdParticipatedMale'] ?? '';
      pwdParticipatedFemale.text = learners['pwdParticipatedFemale'] ?? '';
      // Post-Drill
      final post = data['postDrill'] ?? {};
      reviewedContingencyPlan = post['reviewedContingencyPlan'];
      issuesConcerns.text = post['issuesConcerns'] ?? '';
      postDrillRemarks.text = data['postDrillRemarks'] ?? '';
      // External Links
      final links = (data['externalLinks'] ?? []) as List<dynamic>;
      linksController.text = links.join('\n');
    }
    setState(() {
      _loadingSubmission = false;
    });
  }

  List<Widget> _buildStepContent(BuildContext context) {
    // Use the color palette from the main build method
    final Color primary = Colors.black;
    final Color accent = Colors.grey[700]!;
    final Color cardBg = Colors.grey[850]!;
    final Color inputBg = Colors.grey[800]!;
    final Color border = Colors.grey[700]!;
    final Color textColor = Colors.white;
    final Color hintColor = Colors.grey[400]!;
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    final sectionColors = [cardBg, cardBg, cardBg, cardBg];
    final sectionIcons = [
      Icons.flag_rounded,
      Icons.flash_on_rounded,
      Icons.people_alt_rounded,
      Icons.check_circle_rounded,
    ];
    final sectionTitles = [
      'Pre-Drill',
      'Actual Drill',
      'Personnel & Learners',
      'Post-Drill',
    ];

    Widget sectionHeader(int idx) => Container(
      decoration: BoxDecoration(
        color: sectionColors[idx],
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(sectionIcons[idx], color: primary, size: 28),
          const SizedBox(width: 10),
          Text(
            sectionTitles[idx],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );

    InputDecoration inputDecoration({required String label, IconData? icon}) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: hintColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 2)),
      filled: true,
      fillColor: inputBg,
      prefixIcon: icon != null ? Icon(icon, color: hintColor) : null,
    );

    TextStyle labelStyle = TextStyle(color: textColor, fontWeight: FontWeight.w500);
    TextStyle fieldStyle = TextStyle(color: textColor);

    switch (_step) {
      case 0:
        return [
          sectionHeader(0),
          const Divider(height: 24, thickness: 1.2, color: Colors.white24),
          ...preDrill.keys.map((q) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text(q, style: labelStyle)),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: accent.withOpacity(0.18),
                  ),
                  child: ToggleButtons(
                    isSelected: [
                      preDrill[q] == true,
                      preDrill[q] == false,
                    ],
                    onPressed: (idx) {
                      setState(() {
                        preDrill[q] = idx == 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: primary,
                    color: accent,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Yes'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('No'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 14),
          TextField(
            controller: preDrillRemarks,
            style: fieldStyle,
            decoration: inputDecoration(label: 'Additional Remarks (Pre-Drill)', icon: Icons.note_alt_outlined),
            minLines: 1,
            maxLines: 3,
          ),
        ];
      case 1:
        return [
          sectionHeader(1),
          const Divider(height: 24, thickness: 1.2, color: Colors.white24),
          Row(
            children: [
              Expanded(child: Text('Conducted "DUCK, COVER, and HOLD"?', style: labelStyle)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accent.withOpacity(0.18),
                ),
                child: ToggleButtons(
                  isSelected: [duckCoverHold == true, duckCoverHold == false],
                  onPressed: (idx) => setState(() => duckCoverHold = idx == 0),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: primary,
                  color: accent,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Yes')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('No')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('Conducted evacuation drill?', style: labelStyle)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accent.withOpacity(0.18),
                ),
                child: ToggleButtons(
                  isSelected: [conductedEvacuationDrill == true, conductedEvacuationDrill == false],
                  onPressed: (idx) => setState(() => conductedEvacuationDrill = idx == 0),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: primary,
                  color: accent,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Yes')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('No')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: otherActivities,
            style: fieldStyle,
            decoration: inputDecoration(label: 'Other sub-activities conducted (symposium, advocacy campaigns, etc.)', icon: Icons.event_note_outlined),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: actualDrillRemarks,
            style: fieldStyle,
            decoration: inputDecoration(label: 'Additional Remarks (Actual Drill)', icon: Icons.note_alt_outlined),
            minLines: 1,
            maxLines: 3,
          ),
        ];
      case 2:
        return [
          sectionHeader(2),
          const Divider(height: 24, thickness: 1.2, color: Colors.white24),
          Text('No. of Personnel (Total Population)', style: labelStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: teachingPersonnelTotalMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Teaching Personnel (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: teachingPersonnelTotalFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Teaching Personnel (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nonTeachingPersonnelTotalMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Non-Teaching Personnel (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: nonTeachingPersonnelTotalFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Non-Teaching Personnel (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('No. of Learners (Total Population)', style: labelStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: learnersTotalMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Learners (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersTotalFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Learners (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ipTotalMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'IP (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ipTotalFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'IP (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: muslimTotalMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Muslim (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: muslimTotalFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Muslim (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pwdTotalMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'With Disability (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: pwdTotalFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'With Disability (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('No. of Personnel Participated', style: labelStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: teachingPersonnelParticipatedMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Teaching Personnel (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: teachingPersonnelParticipatedFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Teaching Personnel (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nonTeachingPersonnelParticipatedMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Non-Teaching Personnel (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: nonTeachingPersonnelParticipatedFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Non-Teaching Personnel (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('No. of Learners Participated', style: labelStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: learnersParticipatedMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Learners (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersParticipatedFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Learners (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ipParticipatedMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'IP (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ipParticipatedFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'IP (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: muslimParticipatedMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Muslim (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: muslimParticipatedFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'Muslim (Female)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: pwdParticipatedMale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'With Disability (Male)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: pwdParticipatedFemale,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: fieldStyle,
                  decoration: inputDecoration(label: 'With Disability (Female)'),
                ),
              ),
            ],
          ),
        ];
      case 3:
        return [
          sectionHeader(3),
          const Divider(height: 24, thickness: 1.2, color: Colors.white24),
          Row(
            children: [
              Expanded(child: Text('Conduct a review of Contingency Plan?', style: labelStyle)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accent.withOpacity(0.18),
                ),
                child: ToggleButtons(
                  isSelected: [reviewedContingencyPlan == true, reviewedContingencyPlan == false],
                  onPressed: (idx) => setState(() => reviewedContingencyPlan = idx == 0),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: Colors.white,
                  fillColor: primary,
                  color: accent,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Yes')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('No')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: issuesConcerns,
            style: fieldStyle,
            decoration: inputDecoration(label: 'Issues/Concerns encountered during the actual conduct of drill', icon: Icons.report_problem_outlined),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: postDrillRemarks,
            style: fieldStyle,
            decoration: inputDecoration(label: 'Additional Remarks (Post-Drill)', icon: Icons.note_alt_outlined),
            minLines: 1,
            maxLines: 3,
          ),
        ];
      default:
        return [];
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final List<String> links = linksController.text
        .split(RegExp(r'[\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final submissionData = {
      'schooluid': user.uid,
      'taskId': widget.taskId,
      'submittedAt': FieldValue.serverTimestamp(),
      'preDrill': preDrill,
      'preDrillRemarks': preDrillRemarks.text,
      'actualDrillRemarks': actualDrillRemarks.text,
      'postDrillRemarks': postDrillRemarks.text,
      // Remove: 'additionalRemarks': additionalRemarks.text,
      'actualDrill': {
        'duckCoverHold': duckCoverHold,
        'conductedEvacuationDrill': conductedEvacuationDrill,
        'otherActivities': otherActivities.text,
      },
      'personnel': {
        'teachingTotalMale': teachingPersonnelTotalMale.text,
        'teachingTotalFemale': teachingPersonnelTotalFemale.text,
        'nonTeachingTotalMale': nonTeachingPersonnelTotalMale.text,
        'nonTeachingTotalFemale': nonTeachingPersonnelTotalFemale.text,
        'teachingParticipatedMale': teachingPersonnelParticipatedMale.text,
        'teachingParticipatedFemale': teachingPersonnelParticipatedFemale.text,
        'nonTeachingParticipatedMale': nonTeachingPersonnelParticipatedMale.text,
        'nonTeachingParticipatedFemale': nonTeachingPersonnelParticipatedFemale.text,
      },
      'learners': {
        'totalMale': learnersTotalMale.text,
        'totalFemale': learnersTotalFemale.text,
        'ipTotalMale': ipTotalMale.text,
        'ipTotalFemale': ipTotalFemale.text,
        'muslimTotalMale': muslimTotalMale.text,
        'muslimTotalFemale': muslimTotalFemale.text,
        'pwdTotalMale': pwdTotalMale.text,
        'pwdTotalFemale': pwdTotalFemale.text,
        'participatedMale': learnersParticipatedMale.text,
        'participatedFemale': learnersParticipatedFemale.text,
        'ipParticipatedMale': ipParticipatedMale.text,
        'ipParticipatedFemale': ipParticipatedFemale.text,
        'muslimParticipatedMale': muslimParticipatedMale.text,
        'muslimParticipatedFemale': muslimParticipatedFemale.text,
        'pwdParticipatedMale': pwdParticipatedMale.text,
        'pwdParticipatedFemale': pwdParticipatedFemale.text,
      },
      'postDrill': {
        'reviewedContingencyPlan': reviewedContingencyPlan,
        'issuesConcerns': issuesConcerns.text,
      },
      'externalLinks': links,
    };

    // --- Find existing submission by schooluid and taskId ---
    String? existingSubmissionId;
    final snap = await FirebaseFirestore.instance
        .collection('submissions')
        .where('schooluid', isEqualTo: user.uid)
        .where('taskId', isEqualTo: widget.taskId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      existingSubmissionId = snap.docs.first.id;
    }

    if (existingSubmissionId != null) {
      // Update existing submission
      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(existingSubmissionId)
          .update(submissionData);
    } else {
      // Add new submission
      await FirebaseFirestore.instance.collection('submissions').add(submissionData);
    }

    setState(() => _submitting = false);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted!')));
  }

  @override
  Widget build(BuildContext context) {
    // Custom color palette
    final Color primary = Colors.black;
    final Color secondary = Colors.grey[900]!;
    final Color cardBg = Colors.grey[850]!;
    final Color textColor = Colors.white;
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    if (_loadingSubmission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        title: const Text('Submission Form'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 32, vertical: isMobile ? 8 : 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Card(
                elevation: 2,
                color: cardBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : 24,
                    horizontal: isMobile ? 8 : 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator
                      Padding(
                        padding: EdgeInsets.only(bottom: isMobile ? 10 : 18),
                        child: Row(
                          children: List.generate(4, (i) => Expanded(
                            child: Container(
                              height: isMobile ? 5 : 7,
                              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                              decoration: BoxDecoration(
                                color: i <= _step ? Colors.white : Colors.grey[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )),
                        ),
                      ),
                      ..._buildStepContent(context),
                      SizedBox(height: isMobile ? 16 : 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_step > 0)
                            OutlinedButton.icon(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              label: const Text('Back', style: TextStyle(color: Colors.white)),
                              onPressed: _submitting ? null : () => setState(() => _step--),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: Colors.white, width: 2),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 10 : 18,
                                  vertical: isMobile ? 6 : 10,
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          if (_step < 3)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.arrow_forward, color: Colors.black),
                              label: const Text('Next', style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 10 : 18,
                                  vertical: isMobile ? 6 : 10,
                                ),
                              ),
                              onPressed: _submitting ? null : () => setState(() => _step++),
                            ),
                          if (_step == 3)
                            ElevatedButton.icon(
                              icon: _submitting
                                  ? SizedBox(
                                      width: isMobile ? 14 : 18,
                                      height: isMobile ? 14 : 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                    )
                                  : const Icon(Icons.send_rounded, color: Colors.black),
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 10),
                                child: Text(
                                  _submitting ? 'Saving...' : 'Save',
                                  style: TextStyle(fontSize: isMobile ? 14 : 17, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 10 : 18,
                                  vertical: isMobile ? 6 : 10,
                                ),
                              ),
                              onPressed: _submitting ? null : _submit,
                            ),
                        ],
                      ),
                      if (_step == 3) ...[
                        SizedBox(height: isMobile ? 10 : 18),
                        SizedBox(height: isMobile ? 4 : 6),
                        SizedBox(height: isMobile ? 10 : 18),
                        Text('External Links (e.g., Google Drive, YouTube, etc.):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 13 : 15, color: textColor)),
                        SizedBox(height: isMobile ? 4 : 6),
                        TextField(
                          controller: linksController,
                          decoration: InputDecoration(
                            labelText: 'Paste links here (PROVIDE FULL LINK INCLUDING "https://")',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.link),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.07),
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // (No helper function here)
}

// Add this helper function as a top-level function
String _formatDate(DateTime date) {
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return "${months[date.month]} ${date.day}, ${date.year}";
}
