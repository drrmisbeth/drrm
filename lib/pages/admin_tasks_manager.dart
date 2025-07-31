import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_task_submissions.dart';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;


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
        if (data['schooluid'] != null) {
          schoolIdToSubmission[data['schooluid']] = data;
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
      // --- PRE-DRILL FIELD ORDER AND HEADERS BASED ON IMAGE ---
      List<String> preDrillOrder = [
        'preDrill.conductedAlternativeActivitiesAndOrIECCampaignsOnEarthquakePreparednessAndFirePrevention',
        'preDrill.conductedOrientationToParentsOnEarthquakePreparednessMeasuresAndConductOfEarthquakeAndFireDrills',
        'preDrill.conductedCoordinationPreparatoryMeetingWithLDRRMOBDRRMCs',
        'preDrill.conductedOrientationToLearnersAndSchoolPersonnelOnEarthquakePreparednessMeasuresAndTheConductOfEarthquakeAndFireDrills',
        'preDrill.learnersHaveAccomplishedTheFamilyEarthquakePreparednessHomework',
        'preDrill.withAvailableFirstAidKits',
        'preDrill.withAvailableGoBags',
        'preDrill.withAvailableCommunicationEquipment',
        'preDrill.withAvailableEarlyWarningSystem',
        'preDrill.withAvailableEmergencyAndRescueEquipment',
        'preDrill.withSufficientSpaceInSchoolClassRoomsToConductTheDuckCoverAndHold',
        'preDrill.withUpdatedContingencyPlan',
        'preDrill.withUpdatedPreparednessEvacuationAndResponsePlans',
      ];
      Map<String, String> preDrillHeaders = {
        'preDrill.conductedAlternativeActivitiesAndOrIECCampaignsOnEarthquakePreparednessAndFirePrevention':
            'Conducted\nalternative\nactivities\nand/or\nInformation,\nEducation and\nCommunication (IEC)\ncampaigns on\nearthquake\npreparedness\nand fire\nprevention?',
        'preDrill.conductedOrientationToParentsOnEarthquakePreparednessMeasuresAndConductOfEarthquakeAndFireDrills':
            'Conducted an\norientation to\nparents on\nearthquake\npreparedness\nmeasures and\nthe conduct\nof earthquake\nand fire drills?',
        'preDrill.conductedCoordinationPreparatoryMeetingWithLDRRMOBDRRMCs':
            'Conducted\ncoordination/\npreparatory\nmeeting with\nLDRRMO/BDRRMC?',
        'preDrill.conductedOrientationToLearnersAndSchoolPersonnelOnEarthquakePreparednessMeasuresAndTheConductOfEarthquakeAndFireDrills':
            'Conducted\norientation to\nlearners and\nschool personnel\non earthquake\npreparedness\nmeasures and\nthe conduct of\nearthquake and\nfire drills?',
        'preDrill.learnersHaveAccomplishedTheFamilyEarthquakePreparednessHomework':
            'Learners have\naccomplished\nthe Family\nEarthquake\nPreparedness\nHomework?',
        'preDrill.withAvailableFirstAidKits':
            'With available\nFirst Aid Kit?',
        'preDrill.withAvailableGoBags':
            'With available\nGo Bags?',
        'preDrill.withAvailableCommunicationEquipment':
            'With available\ncommunication\nequipment\n(internet,\ncellphone,\ntwo-way\nradio, etc.)?',
        'preDrill.withAvailableEarlyWarningSystem':
            'With available\nearly warning\nsystem?',
        'preDrill.withAvailableEmergencyAndRescueEquipment':
            'With available\nemergency and\nrescue\nequipment?',
        'preDrill.withSufficientSpaceInSchoolClassRoomsToConductTheDuckCoverAndHold':
            'With sufficient\nspace in\nschool/class\nrooms to\nconduct the\n"Duck, Cover,\nand Hold"?',
        'preDrill.withUpdatedContingencyPlan':
            'With updated\ncontingency\nplan?',
        'preDrill.withUpdatedPreparednessEvacuationAndResponsePlans':
            'With updated\npreparedness,\nevacuation,\nand response\nplans?',
      };

      // --- New: Define personnel and learners export order ---
      // Remove: Total Male (Teaching + Non-Teaching), Total Female (Teaching + Non-Teaching), Total Personnel (Male + Female), Total Participated (Teaching + Non-Teaching)
      List<String> personnelOrder = [
        'personnel.teachingTotalMale',
        'personnel.teachingTotalFemale',
        'personnel.nonTeachingTotalMale',
        'personnel.nonTeachingTotalFemale',
        'personnel.teachingParticipatedMale',
        'personnel.teachingParticipatedFemale',
        'personnel.nonTeachingParticipatedMale',
        'personnel.nonTeachingParticipatedFemale',
      ];
      List<String> learnersOrder = [
        'learners.totalMale',
        'learners.totalFemale',
        'learners.ipTotalMale',
        'learners.ipTotalFemale',
        'learners.muslimTotalMale',
        'learners.pwdTotalMale',
        'learners.pwdTotalFemale',
        'learners.participatedMale',
        'learners.participatedFemale',
        'learners.ipParticipatedMale',
        'learners.ipParticipatedFemale',
        'learners.muslimParticipatedMale',
        'learners.muslimParticipatedFemale',
        'learners.pwdParticipatedMale',
        'learners.pwdParticipatedFemale',
      ];

      // --- Insert Personnel Summary Section ---
      // We'll insert after personnel and learners fields
      // Find insertion index
      int personnelInsertIdx = personnelOrder.length + learnersOrder.length;

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

      // --- Sort preDrillFields according to preDrillOrder, then append any extra fields at the end ---
      List<String> orderedPreDrillFields = [
        ...preDrillOrder.where((f) => preDrillFields.contains(f)),
        ...preDrillFields.where((f) => !preDrillOrder.contains(f)).toList()..sort(),
      ];

      // --- Sort personnel and learners fields according to new order ---
      List<String> orderedPersonnelFields = [
        ...personnelOrder.where((f) => personnelFields.contains(f)),
        ...personnelFields.where((f) => !personnelOrder.contains(f)).toList()..sort(),
      ];
      List<String> orderedLearnersFields = [
        ...learnersOrder.where((f) => learnersFields.contains(f) || f == 'learners.total' || f == 'learners.participatedTotal'),
        ...learnersFields.where((f) => !learnersOrder.contains(f)).toList()..sort(),
      ];

      actualDrillFields.sort();
      postDrillFields.sort();
      remainingFields.sort();

      // --- Build fields list and insert personnel and learners summary sections ---
      final List<String> fields = [
        ...orderedPreDrillFields,
        'preDrillRemarks',
        ...actualDrillFields,
        'actualDrillRemarks',
        ...orderedPersonnelFields,
        ...orderedLearnersFields,
        // Insert marker for personnel summary section
        '___personnel_summary___',
        // Insert marker for participated personnel summary section
        '___personnel_participated_summary___',
        // Insert marker for learners summary section
        '___learners_summary___',
        // Insert marker for IP learners summary section
        '___ip_learners_summary___',
        // Insert marker for Muslim learners summary section
        '___muslim_learners_summary___',
        // Insert marker for learners participated summary section
        '___learners_participated_summary___',
        // Insert marker for IP learners participated summary section
        '___ip_learners_participated_summary___',
        // Insert marker for Muslim learners participated summary section
        '___muslim_learners_participated_summary___',
        // Insert marker for PWD learners summary section
        '___pwd_learners_summary___',
        // Insert marker for PWD learners participated summary section
        '___pwd_learners_participated_summary___',
        // --- Place reviewedContingencyPlan at AZ, postDrillRemarks at BA, issuesConcerns at BB ---
        'postDrill.reviewedContingencyPlan', // AZ
        'postDrillRemarks',                  // BA
        'postDrill.issuesConcerns',          // BB
        'externalLinks',
      ];

      // --- Remove unwanted fields from the export ---
      final unwanted = {
        'schoolId', 'schooluid', 'submittedAt', 'taskId',
        'learners.total', 'learners.participatedTotal', 'learners.participatedMale',
        // Hide these columns:
        'personnel.teachingTotalMale',
        'personnel.teachingTotalFemale',
        'personnel.nonTeachingTotalMale',
        'personnel.nonTeachingTotalFemale',
        'personnel.teachingParticipatedMale',
        'personnel.teachingParticipatedFemale',
        'personnel.nonTeachingParticipatedMale',
        'personnel.nonTeachingParticipatedFemale',
        'learners.totalMale',
        'learners.totalFemale',
        'learners.ipTotalMale',
        'learners.ipTotalFemale',
        'learners.muslimTotalMale',
        'learners.pwdTotalMale',
        'learners.pwdTotalFemale',
        'learners.participatedFemale',
        'learners.ipParticipatedMale',
        'learners.ipParticipatedFemale',
        'learners.muslimParticipatedMale',
        'learners.muslimParticipatedFemale',
        'learners.pwdParticipatedMale',
        'learners.pwdParticipatedFemale',
        'learners.muslimTotalFemale',
      };
      List<String> filteredFields = fields.where((f) {
        final key = fieldKeyToHeader[f] ?? f;
        final last = key;
        return !unwanted.contains(last) && !unwanted.contains(f);
      }).toList();

      // --- Prepare prefix row and header row (prefix only once, skip "users") ---
      List<String> prefixRow = ['No.', 'schoolID', 'School Names'];
      List<String> headerRow = ['', '', ''];
      List<String> yesNoRow = ['','',''];

      
      // Track where to insert the summary sections
      int personnelSummaryCol = -1;
      int personnelParticipatedSummaryCol = -1;
      int learnersSummaryCol = -1;
      int ipLearnersSummaryCol = -1;
      int learnersParticipatedSummaryCol = -1;
      int ipLearnersParticipatedSummaryCol = -1;
      int muslimLearnersSummaryCol = -1;
      int muslimLearnersParticipatedSummaryCol = -1;
      int pwdLearnersSummaryCol = -1;
      int pwdLearnersParticipatedSummaryCol = -1;

      int i = 0;
      while (i < filteredFields.length) {
        final f = filteredFields[i];
        // --- Insert merged header for personnel summary ---
        if (f == '___personnel_summary___') {
          personnelSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of Teaching and Non-Teaching Personnel');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for participated personnel summary ---
        if (f == '___personnel_participated_summary___') {
          personnelParticipatedSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of Teaching and Non-Teaching Participated Personnel');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for learners summary ---
        if (f == '___learners_summary___') {
          learnersSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of Learners');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for IP learners summary ---
        if (f == '___ip_learners_summary___') {
          ipLearnersSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of IP Learners');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for Muslim learners summary ---
        if (f == '___muslim_learners_summary___') {
          muslimLearnersSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of Muslim Learners');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for learners participated summary ---
        if (f == '___learners_participated_summary___') {
          learnersParticipatedSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of Learners Participated');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for IP learners participated summary ---
        if (f == '___ip_learners_participated_summary___') {
          ipLearnersParticipatedSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of IP Learners Participated');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for Muslim learners participated summary ---
        if (f == '___muslim_learners_participated_summary___') {
          muslimLearnersParticipatedSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of Muslim Learners Participated');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for PWD learners summary ---
        if (f == '___pwd_learners_summary___') {
          pwdLearnersSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of PWD Learners');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for PWD learners participated summary ---
        if (f == '___pwd_learners_participated_summary___') {
          pwdLearnersParticipatedSummaryCol = prefixRow.length;
          prefixRow.add('Total No. of PWD Learners Participated');
          prefixRow.add('');
          prefixRow.add('');
          headerRow.add('Male');
          headerRow.add('Female');
          headerRow.add('Total');
          i++;
          continue;
        }
        // --- Insert merged header for reviewedContingencyPlan at AZ ---
        if (f == 'postDrill.reviewedContingencyPlan') {
          prefixRow.add('Conduct of post-activity exercises');
          headerRow.add('Yes/No');
          yesNoRow.add('');
          i++;
          continue;
        }
        // --- Insert merged header for postDrillRemarks at BA ---
        if (f == 'postDrillRemarks') {
          prefixRow.add('Post-Drill Remarks');
          headerRow.add('');
          yesNoRow.add('');
          i++;
          continue;
        }
        // --- Insert merged header for issuesConcerns at BB ---
        if (f == 'postDrill.issuesConcerns') {
          prefixRow.add('Common issues and concerns encountered during the actual conduct of drill');
          headerRow.add('');
          yesNoRow.add('');
          i++;
          continue;
        }
        // --- Insert merged header for externalLinks ---
        if (f == 'externalLinks') {
          prefixRow.add('LINK FOR DOCUMENTATION\n(documentation)\n\nGoogle Drive Link');
          headerRow.add('');
          yesNoRow.add('');
          i++;
          continue;
        }
        final prefix = fieldKeyToPrefix[f] ?? '';
        // Move preDrill fields up to
        if (prefix == 'preDrill') {
          prefixRow.add(fieldKeyToHeader[f] ?? f);
        } else if (prefix.isEmpty || prefix == 'users') {
          prefixRow.add(fieldKeyToHeader[f] ?? f);
        } else if (prefix == 'actualDrill') {
          prefixRow.add(fieldKeyToHeader[f] ?? f);
        }
         else if (prefix == 'postDrill') {
          prefixRow.add(fieldKeyToHeader[f] ?? f);
        }
         else if (i == 0 || prefix != fieldKeyToPrefix[filteredFields[i-1]]) {
          prefixRow.add(fieldKeyToHeader[f] ?? f);
        } else {
          prefixRow.add(fieldKeyToHeader[f] ?? f);
        }
        // Yes/No row
        if (orderedPreDrillFields.contains(f) ||
    (actualDrillFields.contains(f))) {
  headerRow.add('Yes/No');
        } else if (actualDrillFields.contains('otherActivities')) {
          headerRow.add('');
        } else {
          headerRow.add('');
        }
        i++;
      }

      // --- 5. Prepare Excel rows for all schools ---
      List<List<dynamic>> excelRows = [];
      // Add extra empty row at the top
      excelRows.add([]);
      excelRows.add(prefixRow);
      excelRows.add(headerRow);
      excelRows.add(yesNoRow); // Insert Yes/No row here
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
        // Compute combined personnel totals
        int totalMale = 0;
        int totalFemale = 0;
        int teachingPartMale = 0;
        int teachingPartFemale = 0;
        int nonTeachingPartMale = 0;
        int nonTeachingPartFemale = 0;
        int learnersTotalMale = 0;
        int learnersTotalFemale = 0;
        int learnersParticipatedMale = 0;
        int learnersParticipatedFemale = 0;

        // --- New: Compute IP, Muslim, PWD totals and participated totals ---
        int ipTotalMale = int.tryParse(flat['learners.ipTotalMale']?.toString() ?? '') ?? 0;
        int ipTotalFemale = int.tryParse(flat['learners.ipTotalFemale']?.toString() ?? '') ?? 0;
        int muslimTotalMale = int.tryParse(flat['learners.muslimTotalMale']?.toString() ?? '') ?? 0;
        int muslimTotalFemale = int.tryParse(flat['learners.muslimTotalFemale']?.toString() ?? '') ?? 0;
        int pwdTotalMale = int.tryParse(flat['learners.pwdTotalMale']?.toString() ?? '') ?? 0;
        int pwdTotalFemale = int.tryParse(flat['learners.pwdTotalFemale']?.toString() ?? '') ?? 0;

        int ipParticipatedMale = int.tryParse(flat['learners.ipParticipatedMale']?.toString() ?? '') ?? 0;
        int ipParticipatedFemale = int.tryParse(flat['learners.ipParticipatedFemale']?.toString() ?? '') ?? 0;
        int muslimParticipatedMale = int.tryParse(flat['learners.muslimParticipatedMale']?.toString() ?? '') ?? 0;
        int muslimParticipatedFemale = int.tryParse(flat['learners.muslimParticipatedFemale']?.toString() ?? '') ?? 0;
        int pwdParticipatedMale = int.tryParse(flat['learners.pwdParticipatedMale']?.toString() ?? '') ?? 0;
        int pwdParticipatedFemale = int.tryParse(flat['learners.pwdParticipatedFemale']?.toString() ?? '') ?? 0;

        if (flat['personnel.teachingTotalMale'] != null && flat['personnel.teachingTotalMale'].toString().isNotEmpty) {
          totalMale += int.tryParse(flat['personnel.teachingTotalMale'].toString()) ?? 0;
        }
        if (flat['personnel.nonTeachingTotalMale'] != null && flat['personnel.nonTeachingTotalMale'].toString().isNotEmpty) {
          totalMale += int.tryParse(flat['personnel.nonTeachingTotalMale'].toString()) ?? 0;
        }
        if (flat['personnel.teachingTotalFemale'] != null && flat['personnel.teachingTotalFemale'].toString().isNotEmpty) {
          totalFemale += int.tryParse(flat['personnel.teachingTotalFemale'].toString()) ?? 0;
        }
        if (flat['personnel.nonTeachingTotalFemale'] != null && flat['personnel.nonTeachingTotalFemale'].toString().isNotEmpty) {
          totalFemale += int.tryParse(flat['personnel.nonTeachingTotalFemale'].toString()) ?? 0;
        }
        if (flat['personnel.teachingParticipatedMale'] != null && flat['personnel.teachingParticipatedMale'].toString().isNotEmpty) {
          teachingPartMale = int.tryParse(flat['personnel.teachingParticipatedMale'].toString()) ?? 0;
        }
        if (flat['personnel.nonTeachingParticipatedMale'] != null && flat['personnel.nonTeachingParticipatedMale'].toString().isNotEmpty) {
          nonTeachingPartMale = int.tryParse(flat['personnel.nonTeachingParticipatedMale'].toString()) ?? 0;
        }
        if (flat['personnel.teachingParticipatedFemale'] != null && flat['personnel.teachingParticipatedFemale'].toString().isNotEmpty) {
          teachingPartFemale = int.tryParse(flat['personnel.teachingParticipatedFemale'].toString()) ?? 0;
        }
        if (flat['personnel.nonTeachingParticipatedFemale'] != null && flat['personnel.nonTeachingParticipatedFemale'].toString().isNotEmpty) {
          nonTeachingPartFemale = int.tryParse(flat['personnel.nonTeachingParticipatedFemale'].toString()) ?? 0;
        }
        if (flat['learners.totalMale'] != null && flat['learners.totalMale'].toString().isNotEmpty) {
          learnersTotalMale = int.tryParse(flat['learners.totalMale'].toString()) ?? 0;
        }
        if (flat['learners.totalFemale'] != null && flat['learners.totalFemale'].toString().isNotEmpty) {
          learnersTotalFemale = int.tryParse(flat['learners.totalFemale'].toString()) ?? 0;
        }
        if (flat['learners.participatedMale'] != null && flat['learners.participatedMale'].toString().isNotEmpty) {
          learnersParticipatedMale = int.tryParse(flat['learners.participatedMale'].toString()) ?? 0;
        }
        if (flat['learners.participatedFemale'] != null && flat['learners.participatedFemale'].toString().isNotEmpty) {
          learnersParticipatedFemale = int.tryParse(flat['learners.participatedFemale'].toString()) ?? 0;
        }

        // --- Add computed totals for IP, Muslim, PWD ---
        flat['learners.ipTotal'] = ipTotalMale + ipTotalFemale;
        flat['learners.muslimTotal'] = muslimTotalMale + muslimTotalFemale;
        flat['learners.pwdTotal'] = pwdTotalMale + pwdTotalFemale;
        flat['learners.ipParticipatedTotal'] = ipParticipatedMale + ipParticipatedFemale;
        flat['learners.muslimParticipatedTotal'] = muslimParticipatedMale + muslimParticipatedFemale;
        flat['learners.pwdParticipatedTotal'] = pwdParticipatedMale + pwdParticipatedFemale;

        // Build row data, inserting summary sections at correct positions
        List<dynamic> row = [rowNum++, schoolID, schoolName];
        int colIdx = 3;
        for (final f in filteredFields) {
          if (f == '___personnel_summary___') {
            // Show blank if value is 0
            row.add(totalMale == 0 ? '' : totalMale);
            row.add(totalFemale == 0 ? '' : totalFemale);
            row.add((totalMale + totalFemale) == 0 ? '' : (totalMale + totalFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___personnel_participated_summary___') {
            final partMale = teachingPartMale + nonTeachingPartMale;
            final partFemale = teachingPartFemale + nonTeachingPartFemale;
            row.add(partMale == 0 ? '' : partMale);
            row.add(partFemale == 0 ? '' : partFemale);
            row.add((partMale + partFemale) == 0 ? '' : (partMale + partFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___learners_summary___') {
            row.add(learnersTotalMale == 0 ? '' : learnersTotalMale);
            row.add(learnersTotalFemale == 0 ? '' : learnersTotalFemale);
            row.add((learnersTotalMale + learnersTotalFemale) == 0 ? '' : (learnersTotalMale + learnersTotalFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___ip_learners_summary___') {
            row.add(ipTotalMale == 0 ? '' : ipTotalMale);
            row.add(ipTotalFemale == 0 ? '' : ipTotalFemale);
            row.add((ipTotalMale + ipTotalFemale) == 0 ? '' : (ipTotalMale + ipTotalFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___muslim_learners_summary___') {
            row.add(muslimTotalMale == 0 ? '' : muslimTotalMale);
            row.add(muslimTotalFemale == 0 ? '' : muslimTotalFemale);
            row.add((muslimTotalMale + muslimTotalFemale) == 0 ? '' : (muslimTotalMale + muslimTotalFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___learners_participated_summary___') {
            row.add(learnersParticipatedMale == 0 ? '' : learnersParticipatedMale);
            row.add(learnersParticipatedFemale == 0 ? '' : learnersParticipatedFemale);
            row.add((learnersParticipatedMale + learnersParticipatedFemale) == 0 ? '' : (learnersParticipatedMale + learnersParticipatedFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___ip_learners_participated_summary___') {
            row.add(ipParticipatedMale == 0 ? '' : ipParticipatedMale);
            row.add(ipParticipatedFemale == 0 ? '' : ipParticipatedFemale);
            row.add((ipParticipatedMale + ipParticipatedFemale) == 0 ? '' : (ipParticipatedMale + ipParticipatedFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___muslim_learners_participated_summary___') {
            row.add(muslimParticipatedMale == 0 ? '' : muslimParticipatedMale);
            row.add(muslimParticipatedFemale == 0 ? '' : muslimParticipatedFemale);
            row.add((muslimParticipatedMale + muslimParticipatedFemale) == 0 ? '' : (muslimParticipatedMale + muslimParticipatedFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___pwd_learners_summary___') {
            row.add(pwdTotalMale == 0 ? '' : pwdTotalMale);
            row.add(pwdTotalFemale == 0 ? '' : pwdTotalFemale);
            row.add((pwdTotalMale + pwdTotalFemale) == 0 ? '' : (pwdTotalMale + pwdTotalFemale));
            colIdx += 3;
            continue;
          }
          if (f == '___pwd_learners_participated_summary___') {
            row.add(pwdParticipatedMale == 0 ? '' : pwdParticipatedMale);
            row.add(pwdParticipatedFemale == 0 ? '' : pwdParticipatedFemale);
            row.add((pwdParticipatedMale + pwdParticipatedFemale) == 0 ? '' : (pwdParticipatedMale + pwdParticipatedFemale));
            colIdx += 3;
            continue;
          }
          if (f == 'postDrill.reviewedContingencyPlan') {
            row.add(flat['postDrill.reviewedContingencyPlan'] ?? '');
            colIdx++;
            continue;
          }
          if (f == 'postDrillRemarks') {
            row.add(flat['postDrillRemarks'] ?? '');
            colIdx++;
            continue;
          }
          if (f == 'postDrill.issuesConcerns') {
            row.add(flat['postDrill.issuesConcerns'] ?? '');
            colIdx++;
            continue;
          }
          if (f == 'externalLinks') {
            final link = flat['externalLinks']?.toString() ?? '';
            if (link.isNotEmpty) {
              row.add('=HYPERLINK("$link")');
            } else {
              row.add('');
            }
            colIdx++;
            continue;
          }
          row.add(flat[f] ?? '');
          colIdx++;
        }
        excelRows.add(row);
      }

      // --- Add 5 empty rows ---
      for (int i = 0; i < 5; i++) {
        excelRows.add([]);
      }

      // --- Add signature rows ---
      excelRows.add(['','','Prepared by:', '', '','','','','', 'Noted by:']);
      excelRows.add(['','','___________________________________', '','', '','','','', '___________________________________']);
      excelRows.add(['','','MARIBETH A. BALDONADO', '', '','','','','', 'RENATO T. BALLESTEROS PhD, CESO V']);
      excelRows.add(['','','Date:', '', '','','','','', 'Date:']);

      // --- 6. Convert to Excel file and save with template styling (Syncfusion) ---
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];
      sheet.name = 'Sheet1';

      // --- Style definitions ---
    
      final headerStyle = workbook.styles.add('headerStyle');
      headerStyle.bold = true;
      headerStyle.hAlign = xlsio.HAlignType.center;
      headerStyle.vAlign = xlsio.VAlignType.center;
      headerStyle.wrapText = true;
      headerStyle.backColor = '#F4CCCC'; // Light pink for preDrill header
      headerStyle.fontColor = '#000000';

      final prefixStyle = workbook.styles.add('prefixStyle');
      prefixStyle.bold = true;
      prefixStyle.hAlign = xlsio.HAlignType.center;
      prefixStyle.vAlign = xlsio.VAlignType.center;
      prefixStyle.backColor = '#F4CCCC';
      prefixStyle.fontColor = '#000000';

      final yesNoStyle = workbook.styles.add('yesNoStyle');
      yesNoStyle.hAlign = xlsio.HAlignType.center;
      yesNoStyle.vAlign = xlsio.VAlignType.center;
      yesNoStyle.backColor = '#F4CCCC';
      yesNoStyle.fontColor = '#000000';

      final evenRowStyle = workbook.styles.add('evenRowStyle');
      evenRowStyle.hAlign = xlsio.HAlignType.left;
      evenRowStyle.vAlign = xlsio.VAlignType.center;
      evenRowStyle.backColor = '#FFFFFF';
      evenRowStyle.fontColor = '#000000';

      final oddRowStyle = workbook.styles.add('oddRowStyle');
      oddRowStyle.hAlign = xlsio.HAlignType.left;
      oddRowStyle.vAlign = xlsio.VAlignType.center;
      oddRowStyle.backColor = '#F9F9F9';
      oddRowStyle.fontColor = '#000000';

      // --- Additional styles for actualDrill, postDrill, and external links ---
      final actualDrillStyle = workbook.styles.add('actualDrillStyle');
      actualDrillStyle.bold = true;
      actualDrillStyle.hAlign = xlsio.HAlignType.center;
      actualDrillStyle.vAlign = xlsio.VAlignType.center;
      actualDrillStyle.backColor = '#FFF2CC'; // Light yellow
      actualDrillStyle.fontColor = '#000000';

      final postDrillStyle = workbook.styles.add('postDrillStyle');
      postDrillStyle.bold = true;
      postDrillStyle.hAlign = xlsio.HAlignType.center;
      postDrillStyle.vAlign = xlsio.VAlignType.center;
      postDrillStyle.backColor = '#D9EAD3'; // Light green
      postDrillStyle.fontColor = '#000000';

      final externalLinkStyle = workbook.styles.add('externalLinkStyle');
      externalLinkStyle.bold = true;
      externalLinkStyle.hAlign = xlsio.HAlignType.center;
      externalLinkStyle.vAlign = xlsio.VAlignType.center;
      externalLinkStyle.backColor = '#CFE2F3'; // Light blue
      externalLinkStyle.fontColor = '#000000';

      // --- Border style ---
      final border = xlsio.LineStyle.thin;

      int preDrillStartCol = -1;
      int preDrillColSpan = 0;
      for (int col = 3; col < prefixRow.length; col++) {
        final field = col - 3 < filteredFields.length ? filteredFields[col - 3] : '';
        if (field.startsWith('preDrill.')) {
          if (preDrillStartCol == -1) preDrillStartCol = col;
          preDrillColSpan++;
        } else if (preDrillColSpan > 0) {
          break;
        }
      }

      
      // Adjusted row indices due to extra empty row at the top
      for (int col = 0; col < prefixRow.length; col++) {
        final cell = sheet.getRangeByIndex(2, col + 1);
        cell.setText(prefixRow[col].toString());
        final field = col >= 3 && col - 3 < filteredFields.length ? filteredFields[col - 3] : '';
        // Merge and style for summary sections
        if (personnelSummaryCol != -1 && col == personnelSummaryCol) {
          // Merge the 3 columns for the personnel summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('personnelSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (personnelParticipatedSummaryCol != -1 && col == personnelParticipatedSummaryCol) {
          // Merge the 3 columns for the participated personnel summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('personnelParticipatedSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (learnersSummaryCol != -1 && col == learnersSummaryCol) {
          // Merge the 3 columns for the learners summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('learnersSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (ipLearnersSummaryCol != -1 && col == ipLearnersSummaryCol) {
          // Merge the 3 columns for the IP learners summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('ipLearnersSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (muslimLearnersSummaryCol != -1 && col == muslimLearnersSummaryCol) {
          // Merge the 3 columns for the Muslim learners summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('muslimLearnersSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (learnersParticipatedSummaryCol != -1 && col == learnersParticipatedSummaryCol) {
          // Merge the 3 columns for the learners participated summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('learnersParticipatedSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (ipLearnersParticipatedSummaryCol != -1 && col == ipLearnersParticipatedSummaryCol) {
          // Merge the 3 columns for the IP learners participated summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('ipLearnersParticipatedSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (muslimLearnersParticipatedSummaryCol != -1 && col == muslimLearnersParticipatedSummaryCol) {
          // Merge the 3 columns for the Muslim learners participated summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('muslimLearnersParticipatedSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (pwdLearnersSummaryCol != -1 && col == pwdLearnersSummaryCol) {
          // Merge the 3 columns for the PWD learners summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('pwdLearnersSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (pwdLearnersParticipatedSummaryCol != -1 && col == pwdLearnersParticipatedSummaryCol) {
          // Merge the 3 columns for the PWD learners participated summary header
          sheet.getRangeByIndex(2, col + 1, 1, col + 3).merge();
          sheet.getRangeByIndex(2, col + 2).setText('');
          sheet.getRangeByIndex(2, col + 3).setText('');
          cell.cellStyle = workbook.styles.add('pwdLearnersParticipatedSummaryHeader')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (
          (personnelSummaryCol != -1 && (col == personnelSummaryCol + 1 || col == personnelSummaryCol + 2)) ||
          (personnelParticipatedSummaryCol != -1 && (col == personnelParticipatedSummaryCol + 1 || col == personnelParticipatedSummaryCol + 2)) ||
          (learnersSummaryCol != -1 && (col == learnersSummaryCol + 1 || col == learnersSummaryCol + 2)) ||
          (ipLearnersSummaryCol != -1 && (col == ipLearnersSummaryCol + 1 || col == ipLearnersSummaryCol + 2)) ||
          (muslimLearnersSummaryCol != -1 && (col == muslimLearnersSummaryCol + 1 || col == muslimLearnersSummaryCol + 2)) ||
          (learnersParticipatedSummaryCol != -1 && (col == learnersParticipatedSummaryCol + 1 || col == learnersParticipatedSummaryCol + 2)) ||
          (ipLearnersParticipatedSummaryCol != -1 && (col == ipLearnersParticipatedSummaryCol + 1 || col == ipLearnersParticipatedSummaryCol + 2)) ||
          (muslimLearnersParticipatedSummaryCol != -1 && (col == muslimLearnersParticipatedSummaryCol + 1 || col == muslimLearnersParticipatedSummaryCol + 2)) ||
          (pwdLearnersSummaryCol != -1 && (col == pwdLearnersSummaryCol + 1 || col == pwdLearnersSummaryCol + 2)) ||
          (pwdLearnersParticipatedSummaryCol != -1 && (col == pwdLearnersParticipatedSummaryCol + 1 || col == pwdLearnersParticipatedSummaryCol + 2))
        ) {
          // These cells are merged, skip styling/text
          continue;
        } else if (col < 3) {
          cell.cellStyle = workbook.styles.add('prefixWhite$col')
            ..backColor = '#FFFFFF'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center;
        } else if (field.startsWith('preDrill.')) {
          cell.cellStyle = prefixStyle;
        } else if (field.startsWith('actualDrill.')) {
          cell.cellStyle = actualDrillStyle;
        } else if (field.startsWith('postDrill.')) {
          cell.cellStyle = postDrillStyle;
        } else if (field.startsWith('externalLink.')) {
          cell.cellStyle = externalLinkStyle;
        } else {
          cell.cellStyle = prefixStyle;
        }
        cell.cellStyle.borders.all.lineStyle = border;
        cell.cellStyle.borders.all.color = '#000000';
      }
      for (int col = 4; col <= 60; col++) {
  final cell = sheet.getRangeByIndex(2, col);
  cell.cellStyle.wrapText = true;
  cell.cellStyle.hAlign = xlsio.HAlignType.center;
  cell.cellStyle.vAlign = xlsio.VAlignType.center;
}
for (int col = 4; col <= 16; col++) {
  final cell = sheet.getRangeByIndex(3, col);
  cell.cellStyle.backColor = '#f4cccc';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)
  cell.cellStyle.bold = true;                // Optional: bold text
  cell.cellStyle.hAlign = xlsio.HAlignType.center;
  cell.cellStyle.vAlign = xlsio.VAlignType.center;
  cell.cellStyle.wrapText = true;            // Optional: enable wrapping
}

for (int col = 18; col <= 21; col++) {
  final cell = sheet.getRangeByIndex(3, col);
  cell.cellStyle.backColor = '#FFF2CC';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)
  cell.cellStyle.bold = true;                // Optional: bold text
  cell.cellStyle.hAlign = xlsio.HAlignType.center;
  cell.cellStyle.vAlign = xlsio.VAlignType.center;
  cell.cellStyle.wrapText = true;            // Optional: enable wrapping
}
for (int col = 18; col <= 21; col++) {
  final cell = sheet.getRangeByIndex(2, col);
  cell.cellStyle.backColor = '#FFF2CC';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)
  cell.cellStyle.bold = true;                // Optional: bold text
  cell.cellStyle.hAlign = xlsio.HAlignType.center;
  cell.cellStyle.vAlign = xlsio.VAlignType.center;
  cell.cellStyle.wrapText = true;            // Optional: enable wrapping
}

for (int col = 4; col <= 17; col++) {
  final cell = sheet.getRangeByIndex(3, col);
  cell.cellStyle.backColor = '#f4cccc';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)
  cell.cellStyle.bold = true;                // Optional: bold text
  cell.cellStyle.hAlign = xlsio.HAlignType.center;
  cell.cellStyle.vAlign = xlsio.VAlignType.center;
  cell.cellStyle.wrapText = true;            // Optional: enable wrapping
}

for (int col = 26; col <= 49; col++) {
  final cell = sheet.getRangeByIndex(2, col);
  cell.cellStyle.backColor = '#FFF2CC';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)        // Optional: enable wrapping
}
for (int col = 26; col <= 49; col++) {
  final cell = sheet.getRangeByIndex(3, col);
  cell.cellStyle.backColor = '#FFF2CC';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)        // Optional: enable wrapping
}

for (int col = 52; col <= 53; col++) {
  final cell = sheet.getRangeByIndex(2, col);
  cell.cellStyle.backColor = '#acd8a7';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)        // Optional: enable wrapping
}
for (int col = 52; col <= 53; col++) {
  final cell = sheet.getRangeByIndex(3, col);
  cell.cellStyle.backColor = '#acd8a7';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)        // Optional: enable wrapping
}
for (int col = 55; col <= 55; col++) {
  final cell = sheet.getRangeByIndex(1, col);
  cell.cellStyle.backColor = '#0077b6';     
  cell.cellStyle.fontColor = '#ffffff';      // Black text (optional)        // Optional: enable wrapping
}
for (int col = 55; col <= 55; col++) {
  final cell = sheet.getRangeByIndex(2, col);
  cell.cellStyle.backColor = '#0077b6';     
  cell.cellStyle.fontColor = '#ffffff';      // Black text (optional)        // Optional: enable wrapping
}

for (int col = 55; col <= 55; col++) {
  final cell = sheet.getRangeByIndex(3, col);
  cell.cellStyle.backColor = '#0077b6';     
  cell.cellStyle.fontColor = '#ffffff';      // Black text (optional)        // Optional: enable wrapping
}
for (int col = 54; col <= 54; col++) {
  final cell = sheet.getRangeByIndex(1, col);
  cell.cellStyle.backColor = '#FDA172';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)        // Optional: enable wrapping
}
for (int col = 54; col <= 54; col++) {
  final cell = sheet.getRangeByIndex(2, col);
  cell.cellStyle.backColor = '#FDA172';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)        // Optional: enable wrapping
}

for (int col = 54; col <= 54; col++) {
  final cell = sheet.getRangeByIndex(3, col);
  cell.cellStyle.backColor = '#FDA172';     
  cell.cellStyle.fontColor = '#000000';      // Black text (optional)        // Optional: enable wrapping
}


// Loop through the desired rows and columns (e.g. rows 1–100, columns 1–20)
for (int row = 1; row <= 70; row++) {
  for (int col = 1; col <= 65; col++) {
    final cell = sheet.getRangeByIndex(row, col);
    cell.cellStyle.fontName = 'Bookman Old Style';
  }
}

final int lastUsedRow = sheet.getLastRow();
final int lastUsedCol = sheet.getLastColumn();

// A1:BA54 = rows 1–54, cols 1–53 (BA = 53rd column)
for (int row = 1; row <= lastUsedRow; row++) {
  for (int col = 1; col <= lastUsedCol; col++) {
    // Skip the protected range
    if (row >= 1 && row <= 54 && col >= 1 && col <= 53) {
      continue;
    }

    final cell = sheet.getRangeByIndex(row, col);
    final borders = cell.cellStyle.borders;

    borders.all.lineStyle = xlsio.LineStyle.thin;
    borders.all.color = '#FFFFFF'; // White color
  }
}


      // --- Write header row ---
      for (int col = 0; col < headerRow.length; col++) {
        final cell = sheet.getRangeByIndex(3, col + 1);
        cell.setText(headerRow[col].toString());
        // Special: Style personnel summary columns
        if (personnelSummaryCol != -1 && col >= personnelSummaryCol && col < personnelSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('personnelSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (personnelParticipatedSummaryCol != -1 && col >= personnelParticipatedSummaryCol && col < personnelParticipatedSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('personnelParticipatedSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (learnersSummaryCol != -1 && col >= learnersSummaryCol && col < learnersSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('learnersSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (ipLearnersSummaryCol != -1 && col >= ipLearnersSummaryCol && col < ipLearnersSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('ipLearnersSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (muslimLearnersSummaryCol != -1 && col >= muslimLearnersSummaryCol && col < muslimLearnersSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('muslimLearnersSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (learnersParticipatedSummaryCol != -1 && col >= learnersParticipatedSummaryCol && col < learnersParticipatedSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('learnersParticipatedSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (ipLearnersParticipatedSummaryCol != -1 && col >= ipLearnersParticipatedSummaryCol && col < ipLearnersParticipatedSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('ipLearnersParticipatedSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (muslimLearnersParticipatedSummaryCol != -1 && col >= muslimLearnersParticipatedSummaryCol && col < muslimLearnersParticipatedSummaryCol + 3) {
          // Add blue background for "Total No. of Muslim Learners Participated" columns
          cell.cellStyle = workbook.styles.add('muslimLearnersParticipatedSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (pwdLearnersSummaryCol != -1 && col >= pwdLearnersSummaryCol && col < pwdLearnersSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('pwdLearnersSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        } else if (pwdLearnersParticipatedSummaryCol != -1 && col >= pwdLearnersParticipatedSummaryCol && col < pwdLearnersParticipatedSummaryCol + 3) {
          cell.cellStyle = workbook.styles.add('pwdLearnersParticipatedSummarySubHeader$col')
            ..backColor = '#FFF2CC'
            ..fontColor = '#000000'
            ..bold = true
            ..hAlign = xlsio.HAlignType.center
            ..vAlign = xlsio.VAlignType.center
            ..wrapText = true;
        }
        cell.cellStyle.borders.all.lineStyle = border;
        cell.cellStyle.borders.all.color = '#000000';
      }
      
sheet.getRangeByIndex(2, 1).rowHeight = 150;


      // --- Merge and set "drill proper" in the first row, columns 17-20 ---
      // Row 1 (1-based), columns 17 to 20 (inclusive)
      final drillproperrange = sheet.getRangeByIndex(1, 18, 1, 51);
drillproperrange.merge();
      sheet.getRangeByIndex(1, 18, 1, 51).merge();
      final drillProperCell = sheet.getRangeByIndex(1, 18);
      drillProperCell.setText('ACTUAL DRILL');
      drillProperCell.cellStyle = workbook.styles.add('actualdrillheader')
        ..backColor = '#FFF2CC'
        ..fontColor = '#000000'
        ..bold = true
        ..hAlign = xlsio.HAlignType.center
        ..vAlign = xlsio.VAlignType.center
        ..wrapText = true;
  // Add border to the entire merged range
drillproperrange.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
drillproperrange.cellStyle.borders.all.color = '#000000'; // Optional: Border color
         // --- Merge and set "drill proper" in the first row, columns 17-20 ---
      // Row 1 (1-based), columns 17 to 20 (inclusive)
      final postdrillrange = sheet.getRangeByIndex(1, 52, 1, 53);
postdrillrange.merge();
      sheet.getRangeByIndex(1, 52, 1, 53).merge();
      final postdrillcell = sheet.getRangeByIndex(1, 52);
      postdrillcell.setText('POST DRILL');
      postdrillcell.cellStyle = workbook.styles.add('postdrillheader')
        ..backColor = '#acd8a7'
        ..fontColor = '#000000'
        ..bold = true
        ..hAlign = xlsio.HAlignType.center
        ..vAlign = xlsio.VAlignType.center
        ..wrapText = true;
// Add border to the entire merged range
postdrillrange.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
postdrillrange.cellStyle.borders.all.color = '#000000'; // Optional: Border color

      final predrillrange = sheet.getRangeByIndex(1, 4, 1, 17);
predrillrange.merge();

// Apply styles to the merged cell
final predrillcell = sheet.getRangeByIndex(1, 4);
predrillcell.setText('PRE DRILL');
predrillcell.cellStyle = workbook.styles.add('predrillheader')
  ..backColor = '#f4cccc'
  ..fontColor = '#000000'
  ..bold = true
  ..hAlign = xlsio.HAlignType.center
  ..vAlign = xlsio.VAlignType.center
  ..wrapText = true;

// Add border to the entire merged range
predrillrange.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
predrillrange.cellStyle.borders.all.color = '#000000'; // Optional: Border color


      // --- Write data rows with plain white background ---
      for (int row = 4; row < excelRows.length; row++) {
        for (int col = 0; col < excelRows[row].length; col++) {
          final cell = sheet.getRangeByIndex(row + 1, col + 1);
          cell.setText(excelRows[row][col].toString());
          cell.cellStyle = workbook.styles.add('dataWhite${row}_$col')
            ..backColor = '#FFFFFF'
            ..fontColor = '#000000'
            ..hAlign = xlsio.HAlignType.left
            ..vAlign = xlsio.VAlignType.center;
          // Set border color to white for signature rows
          if (row >= excelRows.length - 4) {
            cell.cellStyle.borders.all.lineStyle = border;
            cell.cellStyle.borders.all.color = '#FFFFFF';
          } else {
            cell.cellStyle.borders.all.lineStyle = border;
            cell.cellStyle.borders.all.color = '#000000';
          }
        }
      }

      // --- Add TOTAL row before signature rows ---
      // Find the index to insert the total row (before the last 9 rows: 5 empty + 4 signature)
      final int totalRowIndex = excelRows.length - 9;
      final int colCount = excelRows[4].length;
      List<dynamic> totalRow = List.generate(colCount, (i) {
        if (i == 0) return '';
        if (i == 1) return '';
        if (i == 2) return 'TOTAL';
        // Sum all numeric values in this column (skip header/prefix/yesno/signature rows)
        num sum = 0;
        for (int row = 4; row < totalRowIndex; row++) {
          final val = excelRows[row][i];
          if (val is num) {
            sum += val;
          } else if (val is String && num.tryParse(val) != null) {
            sum += num.parse(val);
          }
        }
        return sum == 0 ? '' : sum;
      });
     // Insert the total row into excelRows
excelRows.insert(totalRowIndex, totalRow);

// Write the TOTAL row to the sheet (columns 20 to 49)
for (int col = 21; col < 51; col++) { // 0-based index: 19 = column 20
  final cell = sheet.getRangeByIndex(totalRowIndex + 1, col + 1);
  cell.setText(totalRow[col].toString());
  cell.cellStyle = workbook.styles.add('totalRow$col')
    ..backColor = '#d9ead3'
    ..fontColor = '#000000'
    ..bold = true
    ..hAlign = xlsio.HAlignType.center
    ..vAlign = xlsio.VAlignType.center;
  cell.cellStyle.borders.all.lineStyle = border;
  cell.cellStyle.borders.all.color = '#000000';
}

      // --- Set column widths for better spacing ---
      // Set default width
      for (int col = 0; col < headerRow.length; col++) {
        sheet.setColumnWidthInPixels(col + 1, 140);
      }
      sheet.autoFitColumn(3);

      // Set wider columns for summary columns and enable wrap text
      final summaryCols = <int>[
        personnelSummaryCol,
        personnelParticipatedSummaryCol,
        learnersSummaryCol,
        ipLearnersSummaryCol,
        muslimLearnersSummaryCol,
        learnersParticipatedSummaryCol,
        ipLearnersParticipatedSummaryCol,
        muslimLearnersParticipatedSummaryCol,
        pwdLearnersSummaryCol,
        pwdLearnersParticipatedSummaryCol,
      ];
      for (final col in summaryCols) {
        if (col != -1) {
          // Set all 3 columns (header + 2 subcolumns) to be narrower and wrap text
          for (int i = 0; i < 3; i++) {
            sheet.setColumnWidthInPixels(col + 1 + i, 80); // changed from 220 to 110
            // Enable wrap text for header, prefix, and yes/no rows
            for (int row = 2; row <= 4; row++) {
              final cell = sheet.getRangeByIndex(row, col + 1 + i);
              cell.cellStyle.wrapText = true;
            }
          }
        }
      }


      // --- Set the whole sheet to Bookman Old Style font ---
      for (int row = 1; row <= sheet.getLastRow(); row++) {
        for (int col = 1; col <= sheet.getLastColumn(); col++) {
          final cell = sheet.getRangeByIndex(row, col);
          cell.cellStyle.fontName = 'Bookman Old Style';
        }
      }

      final List<int> excelBytes = workbook.saveAsStream();
      workbook.dispose();
      await FileSaver.instance.saveFile(
        name: '$taskTitle-submissions',
        bytes: Uint8List.fromList(excelBytes),
        ext: 'xlsx',
        mimeType: MimeType.other, // Excel MIME type
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported ${excelRows.length - 2} schools for "$taskTitle".')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use only black, white, grey for color scheme
    final Color black = Colors.black;
    final Color white = Colors.white;
    final Color grey = Colors.grey[700]!;
    final Color accent = Colors.grey[100]!;

    final colorScheme = ColorScheme.light(
      primary: black,
      secondary: grey,
      background: white,
      surface: white,
      onPrimary: white,
      onSecondary: black,
      onBackground: black,
      onSurface: black,
      brightness: Brightness.light,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Container(
          width: double.infinity,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          color: white, // Content background is white
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            color: white, // Card background is white
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
                          color: black,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      // Add Task toggle button
                      ElevatedButton.icon(
                        icon: Icon(_showAddMenu ? Icons.close : Icons.add_circle),
                        label: Text(_showAddMenu ? 'Hide Add Task' : 'Add Task'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: black,
                          foregroundColor: white,
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
                      child: Card(
                        color: accent,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.add_circle_outline, color: black, size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add New Task',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  // Drill Type
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _drillTypeController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.assignment, color: black),
                                        hintText: 'Drill Type (e.g. Earthquake)',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                                        filled: true,
                                        fillColor: white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Frequency
                                  Expanded(
                                    flex: 4,
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.repeat, color: black),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                        filled: true,
                                        fillColor: white,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedFrequency,
                                          hint: Text('Frequency'),
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
                                          onChanged: (selected) {
                                            setState(() {
                                              _selectedFrequency = selected;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Deadline
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: Icon(Icons.event, color: black),
                                      label: Text(
                                        _deadline == null
                                            ? 'Pick Deadline'
                                            : 'Deadline: ${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: _deadline == null ? Colors.black54 : Colors.black87,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: black),
                                        shape: StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                        backgroundColor: white,
                                      ),
                                      onPressed: _pickDeadline,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // Drill Date
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: Icon(Icons.event_available, color: black),
                                      label: Text(
                                        _drillDate == null
                                            ? 'Pick Drill Date'
                                            : 'Drill Date: ${_drillDate!.year}-${_drillDate!.month.toString().padLeft(2, '0')}-${_drillDate!.day.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: _drillDate == null ? Colors.black54 : Colors.black87,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: black),
                                        shape: StadiumBorder(),
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                        backgroundColor: white,
                                      ),
                                      onPressed: _pickDrillDate,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.check_circle, color: white),
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: black,
                                    foregroundColor: white,
                                    shape: StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                    elevation: 2,
                                  ),
                                  onPressed: _addTask,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            color: grey.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                              color: black,
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
                                DataCell(Text(task['type'] ?? '', style: TextStyle(color: black))),
                                DataCell(Text(task['frequency'] ?? '', style: TextStyle(color: black))),
                                DataCell(Text(
                                  deadline != null
                                      ? _formatDate(deadline)
                                      : "N/A",
                                  style: TextStyle(color: black),
                                )),
                                DataCell(Text(
                                  drillDate != null
                                      ? _formatDate(drillDate)
                                      : "N/A",
                                  style: TextStyle(color: black),
                                )),
                                DataCell(
                                  Switch(
                                    value: task['active'] ?? true,
                                    onChanged: (task['archived'] ?? false)
                                        ? null // Disable switch if archived
                                        : (val) => _toggleActive(doc.id, val),
                                    activeColor: black,
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: grey),
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
                                        icon: Icon(Icons.delete, color: Colors.grey[600]),
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
                                        icon: Icon(Icons.visibility, color: grey),
                                        tooltip: 'View Submissions',
                                        onPressed: () => _viewSubmissions(doc.id, '${task['type']} (${task['frequency']})'),
                                      ),
                                      // --- Export Button with export logic ---
                                      FutureBuilder<int>(
                                        future: FirebaseFirestore.instance
                                            .collection('submissions')
                                            .where('taskId', isEqualTo: doc.id)
                                            .limit(1)
                                            .get()
                                            .then((snap) => snap.size),
                                        builder: (context, snapshot) {
                                          final hasSubmissions = snapshot.hasData && snapshot.data! > 0;
                                          return TextButton(
                                            child: const Text('Export', style: TextStyle(color: Colors.black)),
                                            onPressed: hasSubmissions
                                                ? () => _exportSubmissions(doc.id, '${task['type']} (${task['frequency']})')
                                                : null,
                                            style: TextButton.styleFrom(
                                              foregroundColor: hasSubmissions ? Colors.black : Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                      // --- Archive Button ---
                                      if (!(task['archived'] ?? false))
                                        TextButton.icon(
                                          icon: Icon(Icons.archive, color: grey),
                                          label: const Text('Archive', style: TextStyle(color: Colors.black)),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.black,
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
                                          icon: Icon(Icons.unarchive, color: grey),
                                          label: const Text('Unarchive', style: TextStyle(color: Colors.black)),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.black,
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

// Add this helper function at the bottom of the file (outside the class)
String _prettyField(String f) {
  // Remove prefix and camelCase to words
  final field = f.split('.').last
    .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
    .replaceAll('Total', '')
    .replaceAll('Participated', '')
    .replaceAll('Male', '')
    .replaceAll('Female', '')
    .replaceAll('  ', ' ')
    .trim();
  return field[0].toUpperCase() + field.substring(1);
}
