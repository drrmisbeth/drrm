import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'school_my_submissions.dart';

class SchoolTasksPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const SchoolTasksPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return SingleChildScrollView(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submission Tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 28),
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
                        return const Text('No tasks.');
                      }
                      return Wrap(
                        spacing: isMobile ? 0 : 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: docs.map((doc) {
                          final task = doc.data() as Map<String, dynamic>;
                          final deadline = (task['deadline'] as Timestamp?)?.toDate();
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
                          return Container(
                            width: isMobile ? double.infinity : 400,
                            constraints: BoxConstraints(
                              maxWidth: 500,
                              minWidth: isMobile ? 0 : 300,
                            ),
                            child: Card(
                              elevation: 0,
                              color: colorScheme.secondary.withOpacity(isActive ? 0.13 : 0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: iconBg,
                                      child: Icon(icon, color: Colors.white, size: 38),
                                      radius: 36,
                                    ),
                                    const SizedBox(width: 28),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  task['type'] ?? '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              if (!isActive)
                                                Chip(
                                                  label: const Text('Inactive'),
                                                  backgroundColor: Colors.grey[300],
                                                  labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            'Type: ${task['frequency'] ?? ''}',
                                            style: TextStyle(color: Colors.grey[700], fontSize: 15),
                                          ),
                                          Text(
                                            'Due: ${deadline != null ? "${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}" : "N/A"}',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isMobile)
                                      const SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        elevation: 0,
                                      ),
                                      onPressed: isActive
                                          ? () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => SchoolSubmitFormPage(taskId: doc.id),
                                                ),
                                              );
                                            }
                                          : null,
                                      icon: const Icon(Icons.upload_rounded, size: 22),
                                      label: const Text('Submit'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
  final TextEditingController additionalRemarks = TextEditingController();

  // Actual Drill
  bool? duckCoverHold;
  bool? conductedEvacuationDrill;
  final TextEditingController otherActivities = TextEditingController();

  // Personnel/Participants
  final TextEditingController teachingPersonnelTotal = TextEditingController();
  final TextEditingController nonTeachingPersonnelTotal = TextEditingController();
  final TextEditingController teachingPersonnelParticipated = TextEditingController();
  final TextEditingController nonTeachingPersonnelParticipated = TextEditingController();

  final TextEditingController learnersMale = TextEditingController();
  final TextEditingController learnersFemale = TextEditingController();
  final TextEditingController learnersIP = TextEditingController();
  final TextEditingController learnersMuslim = TextEditingController();
  final TextEditingController learnersPWD = TextEditingController();

  final TextEditingController learnersParticipatedMale = TextEditingController();
  final TextEditingController learnersParticipatedFemale = TextEditingController();
  final TextEditingController learnersParticipatedIP = TextEditingController();
  final TextEditingController learnersParticipatedMuslim = TextEditingController();
  final TextEditingController learnersParticipatedPWD = TextEditingController();

  // Post-Drill
  bool? reviewedContingencyPlan;
  final TextEditingController issuesConcerns = TextEditingController();

  List<Widget> _buildStepContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_step) {
      case 0:
        return [
          Text('Pre-Drill', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...preDrill.keys.map((q) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(child: Text(q, style: const TextStyle(fontSize: 15))),
                ToggleButtons(
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
                  fillColor: colorScheme.primary,
                  color: colorScheme.primary,
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
              ],
            ),
          )),
          const SizedBox(height: 10),
          TextField(
            controller: additionalRemarks,
            decoration: InputDecoration(
              labelText: 'Additional Remarks',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            minLines: 1,
            maxLines: 3,
          ),
        ];
      case 1:
        return [
          Text('Actual Drill', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('Conducted "DUCK, COVER, and HOLD"?', style: const TextStyle(fontSize: 15))),
              ToggleButtons(
                isSelected: [duckCoverHold == true, duckCoverHold == false],
                onPressed: (idx) => setState(() => duckCoverHold = idx == 0),
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: colorScheme.primary,
                color: colorScheme.primary,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Yes')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('No')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('Conducted evacuation drill?', style: const TextStyle(fontSize: 15))),
              ToggleButtons(
                isSelected: [conductedEvacuationDrill == true, conductedEvacuationDrill == false],
                onPressed: (idx) => setState(() => conductedEvacuationDrill = idx == 0),
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: colorScheme.primary,
                color: colorScheme.primary,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Yes')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('No')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: otherActivities,
            decoration: InputDecoration(
              labelText: 'Other sub-activities conducted (symposium, advocacy campaigns, etc.)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            minLines: 1,
            maxLines: 3,
          ),
        ];
      case 2:
        return [
          Text('Personnel & Learners', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('No. of Personnel (Total Population)', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: teachingPersonnelTotal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Teaching Personnel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: nonTeachingPersonnelTotal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Non-Teaching Personnel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('No. of Personnel Participated', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: teachingPersonnelParticipated,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Teaching Personnel'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: nonTeachingPersonnelParticipated,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Non-Teaching Personnel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('No. of Learners (Total Population)', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: learnersMale,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Male'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersFemale,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Female'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: learnersIP,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'IP'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersMuslim,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Muslim'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersPWD,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'With Disability'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('No. of Learners Participated', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: learnersParticipatedMale,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Male'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersParticipatedFemale,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Female'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: learnersParticipatedIP,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'IP'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersParticipatedMuslim,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Muslim'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: learnersParticipatedPWD,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'With Disability'),
                ),
              ),
            ],
          ),
        ];
      case 3:
        return [
          Text('Post-Drill', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text('Conduct a review of Contingency Plan?', style: const TextStyle(fontSize: 15))),
              ToggleButtons(
                isSelected: [reviewedContingencyPlan == true, reviewedContingencyPlan == false],
                onPressed: (idx) => setState(() => reviewedContingencyPlan = idx == 0),
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: colorScheme.primary,
                color: colorScheme.primary,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Yes')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('No')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: issuesConcerns,
            decoration: InputDecoration(
              labelText: 'Issues/Concerns encountered during the actual conduct of drill',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ];
      default:
        return [];
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('submissions').add({
      'schoolId': user.uid,
      'taskId': widget.taskId,
      'submittedAt': FieldValue.serverTimestamp(),
      'preDrill': preDrill,
      'additionalRemarks': additionalRemarks.text,
      'actualDrill': {
        'duckCoverHold': duckCoverHold,
        'conductedEvacuationDrill': conductedEvacuationDrill,
        'otherActivities': otherActivities.text,
      },
      'personnel': {
        'teachingTotal': teachingPersonnelTotal.text,
        'nonTeachingTotal': nonTeachingPersonnelTotal.text,
        'teachingParticipated': teachingPersonnelParticipated.text,
        'nonTeachingParticipated': nonTeachingPersonnelParticipated.text,
      },
      'learners': {
        'male': learnersMale.text,
        'female': learnersFemale.text,
        'ip': learnersIP.text,
        'muslim': learnersMuslim.text,
        'pwd': learnersPWD.text,
        'participatedMale': learnersParticipatedMale.text,
        'participatedFemale': learnersParticipatedFemale.text,
        'participatedIP': learnersParticipatedIP.text,
        'participatedMuslim': learnersParticipatedMuslim.text,
        'participatedPWD': learnersParticipatedPWD.text,
      },
      'postDrill': {
        'reviewedContingencyPlan': reviewedContingencyPlan,
        'issuesConcerns': issuesConcerns.text,
      },
    });
    setState(() => _submitting = false);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SchoolMySubmissionsPage()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted!')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Form'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 32, vertical: 18),
          child: Card(
            elevation: 0,
            color: colorScheme.secondary.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildStepContent(context),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_step > 0)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back'),
                          onPressed: _submitting ? null : () => setState(() => _step--),
                        ),
                      if (_step < 3)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _submitting ? null : () => setState(() => _step++),
                        ),
                      if (_step == 3)
                        ElevatedButton.icon(
                          icon: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(_submitting ? 'Submitting...' : 'Submit', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _submitting ? null : _submit,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
