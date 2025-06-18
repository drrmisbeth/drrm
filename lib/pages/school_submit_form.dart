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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pre-Drill', style: Theme.of(context).textTheme.titleLarge),
            ...preDrill.keys.map((q) => CheckboxListTile(
                  title: Text(q),
                  value: preDrill[q],
                  onChanged: (v) => setState(() => preDrill[q] = v ?? false),
                )),
            TextField(
              controller: additionalRemarks,
              decoration: const InputDecoration(labelText: 'Additional Remarks'),
            ),
            const Divider(),
            Text('Actual Drill', style: Theme.of(context).textTheme.titleLarge),
            CheckboxListTile(
              title: const Text('Conducted "DUCK, COVER, and HOLD"?'),
              value: duckCoverHold,
              onChanged: (v) => setState(() => duckCoverHold = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('Conducted evacuation drill?'),
              value: conductedEvacuationDrill,
              onChanged: (v) => setState(() => conductedEvacuationDrill = v ?? false),
            ),
            TextField(
              controller: otherActivities,
              decoration: const InputDecoration(labelText: 'Other sub-activities conducted'),
            ),
            const Divider(),
            Text('Personnel Participation', style: Theme.of(context).textTheme.titleLarge),
            Row(children: [
              Expanded(child: TextField(controller: teachingMale, decoration: const InputDecoration(labelText: 'Teaching Male'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: teachingFemale, decoration: const InputDecoration(labelText: 'Teaching Female'))),
            ]),
            Row(children: [
              Expanded(child: TextField(controller: nonTeachingMale, decoration: const InputDecoration(labelText: 'Non-Teaching Male'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: nonTeachingFemale, decoration: const InputDecoration(labelText: 'Non-Teaching Female'))),
            ]),
            Row(children: [
              Expanded(child: TextField(controller: teachingPartMale, decoration: const InputDecoration(labelText: 'Teaching Part. Male'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: teachingPartFemale, decoration: const InputDecoration(labelText: 'Teaching Part. Female'))),
            ]),
            Row(children: [
              Expanded(child: TextField(controller: nonTeachingPartMale, decoration: const InputDecoration(labelText: 'Non-Teaching Part. Male'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: nonTeachingPartFemale, decoration: const InputDecoration(labelText: 'Non-Teaching Part. Female'))),
            ]),
            const Divider(),
            Text('Learners Participation', style: Theme.of(context).textTheme.titleLarge),
            Row(children: [
              Expanded(child: TextField(controller: learnersMale, decoration: const InputDecoration(labelText: 'Learners Male'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: learnersFemale, decoration: const InputDecoration(labelText: 'Learners Female'))),
            ]),
            Row(children: [
              Expanded(child: TextField(controller: learnersPartMale, decoration: const InputDecoration(labelText: 'Learners Part. Male'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: learnersPartFemale, decoration: const InputDecoration(labelText: 'Learners Part. Female'))),
            ]),
            const Divider(),
            Text('Post-Drill', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: issues,
              decoration: const InputDecoration(labelText: 'Issues/Concerns/Observations'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting ? const CircularProgressIndicator() : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
