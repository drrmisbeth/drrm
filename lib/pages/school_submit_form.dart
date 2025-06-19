import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchoolSubmitFormPage extends StatefulWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const SchoolSubmitFormPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  State<SchoolSubmitFormPage> createState() => _SchoolSubmitFormPageState();
}

class _SchoolSubmitFormPageState extends State<SchoolSubmitFormPage> {
  // Pre-Drill questions
  final Map<String, bool> preDrill = {
    'With available Go Bags?': false,
    'With updated preparedness, evacuation, and response plans?': false,
    'With updated contingency plan?': false,
    'With available early warning system?': false,
    'With available emergency and rescue equipment?': false,
    'With available First Aid Kit?': false,
    'With available communication equipment (internet, cellphone, two-way radio, etc.)?': false,
    'With sufficient space in school/classrooms to conduct the "Duck, Cover, and Hold"?': false,
    'Conducted coordination/preparatory meeting with LDRRMO/BDRRMC?': false,
    'Conducted orientation to learners and school personnel on earthquake preparedness measures and the conduct of earthquake and fire drills?': false,
    'Conducted an orientation to parents on earthquake preparedness measures and the conduct of earthquake and fire drills?': false,
    'Learners have accomplished the Family Earthquake Preparedness Homework?': false,
    'Conducted alternative activities and/or Information, Education and Communication (IEC) campaigns on earthquake preparedness and fire prevention?': false,
  };
  final TextEditingController additionalRemarks = TextEditingController();

  // Actual Drill
  bool duckCoverHold = false;
  bool conductedEvacuationDrill = false;
  final TextEditingController otherActivities = TextEditingController();

  // Personnel/learners counts
  final TextEditingController teachingMale = TextEditingController();
  final TextEditingController teachingFemale = TextEditingController();
  final TextEditingController nonTeachingMale = TextEditingController();
  final TextEditingController nonTeachingFemale = TextEditingController();

  final TextEditingController teachingPartMale = TextEditingController();
  final TextEditingController teachingPartFemale = TextEditingController();
  final TextEditingController nonTeachingPartMale = TextEditingController();
  final TextEditingController nonTeachingPartFemale = TextEditingController();

  final TextEditingController learnersMale = TextEditingController();
  final TextEditingController learnersFemale = TextEditingController();
  final TextEditingController learnersPartMale = TextEditingController();
  final TextEditingController learnersPartFemale = TextEditingController();

  // Post-Drill
  final TextEditingController issues = TextEditingController();

  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // TODO: Select taskId from dropdown or context
    final taskId = 'SELECTED_TASK_ID';
    await FirebaseFirestore.instance.collection('submissions').add({
      'schoolId': user.uid,
      'taskId': taskId,
      'submittedAt': FieldValue.serverTimestamp(),
      'preDrill': preDrill,
      'additionalRemarks': additionalRemarks.text,
      'actualDrill': {
        'duckCoverHold': duckCoverHold,
        'conductedEvacuationDrill': conductedEvacuationDrill,
        'otherActivities': otherActivities.text,
      },
      'personnel': {
        'teaching': {'male': teachingMale.text, 'female': teachingFemale.text},
        'nonTeaching': {'male': nonTeachingMale.text, 'female': nonTeachingFemale.text},
        'teachingPart': {'male': teachingPartMale.text, 'female': teachingPartFemale.text},
        'nonTeachingPart': {'male': nonTeachingPartMale.text, 'female': nonTeachingPartFemale.text},
      },
      'learners': {
        'male': learnersMale.text,
        'female': learnersFemale.text,
        'partMale': learnersPartMale.text,
        'partFemale': learnersPartFemale.text,
      },
      'postDrillIssues': issues.text,
    });
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted!')));
  }

  InputDecoration _inputDecoration(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      filled: true,
      fillColor: colorScheme.surface.withOpacity(0.97),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    );
  }

  Widget _sectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 18),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _divider() => const SizedBox(height: 18);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          color: colorScheme.secondary.withOpacity(0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 32, horizontal: isMobile ? 10 : 32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Submission Form',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: colorScheme.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  _divider(),
                  _sectionTitle('Pre-Drill'),
                  ...preDrill.keys.map((q) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(q, style: const TextStyle(fontSize: 15))),
                            Switch(
                              value: preDrill[q] ?? false,
                              onChanged: (v) => setState(() => preDrill[q] = v),
                              activeColor: colorScheme.primary,
                            ),
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: TextField(
                      controller: additionalRemarks,
                      decoration: _inputDecoration('Additional Remarks'),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  _divider(),
                  _sectionTitle('Actual Drill'),
                  Row(
                    children: [
                      Expanded(child: Text('Conducted "DUCK, COVER, and HOLD"?', style: const TextStyle(fontSize: 15))),
                      Switch(
                        value: duckCoverHold,
                        onChanged: (v) => setState(() => duckCoverHold = v),
                        activeColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Conducted evacuation drill?', style: const TextStyle(fontSize: 15))),
                      Switch(
                        value: conductedEvacuationDrill,
                        onChanged: (v) => setState(() => conductedEvacuationDrill = v),
                        activeColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: TextField(
                      controller: otherActivities,
                      decoration: _inputDecoration('Other sub-activities conducted'),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  _divider(),
                  _sectionTitle('Personnel Participation'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: teachingMale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Teaching Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: teachingFemale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Teaching Female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nonTeachingMale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Non-Teaching Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: nonTeachingFemale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Non-Teaching Female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: teachingPartMale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Teaching Part. Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: teachingPartFemale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Teaching Part. Female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nonTeachingPartMale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Non-Teaching Part. Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: nonTeachingPartFemale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Non-Teaching Part. Female'),
                        ),
                      ),
                    ],
                  ),
                  _divider(),
                  _sectionTitle('Learners Participation'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: learnersMale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Learners Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: learnersFemale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Learners Female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: learnersPartMale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Learners Part. Male'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: learnersPartFemale,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Learners Part. Female'),
                        ),
                      ),
                    ],
                  ),
                  _divider(),
                  _sectionTitle('Post-Drill'),
                  TextField(
                    controller: issues,
                    decoration: _inputDecoration('Issues/Concerns/Observations'),
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _submit,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(_submitting ? 'Submitting...' : 'Submit',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                      ),
                    ),
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
