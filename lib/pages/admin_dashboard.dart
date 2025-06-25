import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AdminDashboardPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Modern color scheme
    final Color orange = const Color(0xFFFF9800);
    final Color yellow = const Color(0xFFFFEB3B);
    final Color red = const Color(0xFFF44336);
    final Color accent = const Color(0xFFFEF3E2);

    // Updated palette
    final Color purple = const Color(0xFF7C6CB2);
    final Color purpleBg = const Color(0xFFF8F3FB);
    final Color cardBg = Colors.white; // Info cards background is white
    final Color mainBg = Colors.white; // Main background is white

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row for Dashboard title and Select Task
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: orange,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('tasks').orderBy('deadline').snapshots(),
                            builder: (context, taskSnap) {
                              if (!taskSnap.hasData) return const SizedBox();
                              final tasks = taskSnap.data!.docs;
                              return DropdownButton<String>(
                                value: _selectedTaskId,
                                hint: const Text('Select Task'),
                                items: [
                                  ...tasks.map((doc) => DropdownMenuItem(
                                    value: doc.id,
                                    child: Text('${doc['type']} - ${doc['frequency']}'),
                                  )),
                                ],
                                onChanged: (v) => setState(() => _selectedTaskId = v),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // --- Task Filter Dropdown ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('tasks').orderBy('deadline').snapshots(),
                      builder: (context, taskSnap) {
                        if (!taskSnap.hasData) return const SizedBox();
                        final tasks = taskSnap.data!.docs;
                        return Row(
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    // --- Stat Cards with actual counts ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'school').snapshots(),
                      builder: (context, schoolSnap) {
                        if (!schoolSnap.hasData) {
                          return Row(
                            children: [
                              _statCard(
                                color: yellow,
                                icon: Icons.check_circle,
                                value: '...',
                                label: 'Submitted',
                                iconColor: Colors.white,
                                gradient: const [
                                  Color(0xFFFFE082),
                                  Color(0xFFFFC107),
                                ],
                              ),
                              const SizedBox(width: 16),
                              _statCard(
                                color: red,
                                icon: Icons.camera_alt_rounded,
                                value: '...',
                                label: 'Not Submitted',
                                iconColor: Colors.white,
                                gradient: const [
                                  Color(0xFFFF8A65),
                                  Color(0xFFF44336),
                                ],
                              ),
                              const SizedBox(width: 16),
                              _statCard(
                                color: orange,
                                icon: Icons.school,
                                value: '...',
                                label: 'Schools',
                              ),
                            ],
                          );
                        }
                        final schools = schoolSnap.data!.docs;
                        final totalSchools = schools.length;
                        if (_selectedTaskId == null) {
                          return Row(
                            children: [
                              _statCard(
                                color: yellow,
                                icon: Icons.check_circle,
                                value: '...',
                                label: 'Submitted',
                                iconColor: Colors.white,
                                gradient: const [
                                  Color(0xFFFFE082),
                                  Color(0xFFFFC107),
                                ],
                              ),
                              const SizedBox(width: 16),
                              _statCard(
                                color: red,
                                icon: Icons.camera_alt_rounded,
                                value: '...',
                                label: 'Not Submitted',
                                iconColor: Colors.white,
                                gradient: const [
                                  Color(0xFFFF8A65),
                                  Color(0xFFF44336),
                                ],
                                onTap: null,
                              ),
                              const SizedBox(width: 16),
                              _statCard(
                                color: orange,
                                icon: Icons.school,
                                value: totalSchools.toString(),
                                label: 'Schools',
                              ),
                            ],
                          );
                        }
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('submissions')
                              .where('taskId', isEqualTo: _selectedTaskId)
                              .snapshots(),
                          builder: (context, subSnap) {
                            if (!subSnap.hasData) {
                              return Row(
                                children: [
                                  _statCard(
                                    color: yellow,
                                    icon: Icons.check_circle,
                                    value: '...',
                                    label: 'Submitted',
                                    iconColor: Colors.white,
                                    gradient: const [
                                      Color(0xFFFFE082),
                                      Color(0xFFFFC107),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  _statCard(
                                    color: red,
                                    icon: Icons.camera_alt_rounded,
                                    value: '...',
                                    label: 'Not Submitted',
                                    iconColor: Colors.white,
                                    gradient: const [
                                      Color(0xFFFF8A65),
                                      Color(0xFFF44336),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  _statCard(
                                    color: orange,
                                    icon: Icons.school,
                                    value: totalSchools.toString(),
                                    label: 'Schools',
                                  ),
                                ],
                              );
                            }
                            final submissions = subSnap.data!.docs;
                            final submittedSchoolIds = submissions.map((s) => s['schoolId'] as String).toSet();
                            final submitted = schools.where((s) => submittedSchoolIds.contains(s.id)).length;
                            final notSubmitted = totalSchools - submitted;
                            final notSubmittedSchools = schools.where((s) => !submittedSchoolIds.contains(s.id)).toList();
                            return Row(
                              children: [
                                _statCard(
                                  color: yellow,
                                  icon: Icons.check_circle,
                                  value: submitted.toString(),
                                  label: 'Submitted',
                                  iconColor: Colors.white,
                                  gradient: const [
                                    Color(0xFFFFE082),
                                    Color(0xFFFFC107),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                _statCard(
                                  color: red,
                                  icon: Icons.camera_alt_rounded,
                                  value: notSubmitted.toString(),
                                  label: 'Not Submitted',
                                  iconColor: Colors.white,
                                  gradient: const [
                                    Color(0xFFFF8A65),
                                    Color(0xFFF44336),
                                  ],
                                  onTap: notSubmitted > 0
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Schools Not Submitted'),
                                              content: SizedBox(
                                                width: 320,
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: notSubmittedSchools.length,
                                                  itemBuilder: (context, idx) {
                                                    final school = notSubmittedSchools[idx].data() as Map<String, dynamic>;
                                                    return ListTile(
                                                      leading: const Icon(Icons.school),
                                                      title: Text(school['name'] ?? school['email'] ?? 'School'),
                                                      subtitle: school['email'] != null ? Text(school['email']) : null,
                                                    );
                                                  },
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                _statCard(
                                  color: orange,
                                  icon: Icons.school,
                                  value: totalSchools.toString(),
                                  label: 'Schools',
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Quick Links',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: purple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _quickLink(
                          icon: Icons.assignment_rounded,
                          label: 'Submission Tasks',
                          color: purple,
                          background: purpleBg,
                        ),
                        const SizedBox(width: 10),
                        _quickLink(
                          icon: Icons.list_alt_rounded,
                          label: 'All Submissions',
                          color: purple,
                          background: purpleBg,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _infoCard(
                      background: cardBg, // Info card background is white
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event_note, color: purple),
                                const SizedBox(width: 8),
                                Text(
                                  'Upcoming Drills',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('• Earthquake Drill: June 15, 2024',
                                style: TextStyle(fontSize: 15, color: Colors.black87)),
                            Text('• Earthquake Drill: September 15, 2024',
                                style: TextStyle(fontSize: 15, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                    _infoCard(
                      background: purpleBg,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: purple,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _activityRow(
                              icon: Icons.check_circle,
                              iconColor: Color(0xFF3FE9B3),
                              text: 'School A submitted Earthquake Drill report',
                              date: 'June 8, 2024',
                            ),
                            _activityRow(
                              icon: Icons.pending_actions,
                              iconColor: Color(0xFFFFB75E),
                              text: 'School B pending Earthquake Drill report',
                              date: 'June 7, 2024',
                            ),
                            _activityRow(
                              icon: Icons.check_circle,
                              iconColor: Color(0xFF3FE9B3),
                              text: 'School C submitted Earthquake Drill report',
                              date: 'June 6, 2024',
                            ),
                          ],
                        ),
                      ),
                    ),
                    _infoCard(
                      background: cardBg, // Info card background is white
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment, color: purple),
                                const SizedBox(width: 8),
                                Text(
                                  'Active Drill Tasks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: purple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Earthquake Drill (Quarterly)',
                              style: TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Dashboard stats and quick links
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24.0, left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row for Dashboard title and Select Task
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Dashboard',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: orange,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance.collection('tasks').orderBy('deadline').snapshots(),
                                    builder: (context, taskSnap) {
                                      if (!taskSnap.hasData) return const SizedBox();
                                      final tasks = taskSnap.data!.docs;
                                      return DropdownButton<String>(
                                        value: _selectedTaskId,
                                        hint: const Text('Select Task'),
                                        items: [
                                          ...tasks.map((doc) => DropdownMenuItem(
                                            value: doc.id,
                                            child: Text('${doc['type']} - ${doc['frequency']}'),
                                          )),
                                        ],
                                        onChanged: (v) => setState(() => _selectedTaskId = v),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Wrap(
                              spacing: 24,
                              runSpacing: 18,
                              children: [
                                FutureBuilder<int>(
                                  future: _getSchoolCount(),
                                  builder: (context, snapshot) {
                                    final count = snapshot.hasData ? snapshot.data.toString() : '...';
                                    return _statCard(
                                      color: orange,
                                      icon: Icons.school,
                                      value: count,
                                      label: 'Schools',
                                    );
                                  },
                                ),
                                // Replace the two _statCard widgets for Submitted and Pending/Not Submitted with actual counts
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'school').snapshots(),
                                  builder: (context, schoolSnap) {
                                    if (!schoolSnap.hasData) {
                                      return Row(
                                        children: [
                                          _statCard(
                                            color: yellow,
                                            icon: Icons.check_circle,
                                            value: '...',
                                            label: 'Submitted',
                                            iconColor: Colors.white,
                                            gradient: const [
                                              Color(0xFFFFE082),
                                              Color(0xFFFFC107),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          _statCard(
                                            color: red,
                                            icon: Icons.camera_alt_rounded,
                                            value: '...',
                                            label: 'Not Submitted',
                                            iconColor: Colors.white,
                                            gradient: const [
                                              Color(0xFFFF8A65),
                                              Color(0xFFF44336),
                                            ],
                                          ),
                                        ],
                                      );
                                    }
                                    final schools = schoolSnap.data!.docs;
                                    final totalSchools = schools.length;
                                    if (_selectedTaskId == null) {
                                      return Row(
                                        children: [
                                          _statCard(
                                            color: yellow,
                                            icon: Icons.check_circle,
                                            value: '...',
                                            label: 'Submitted',
                                            iconColor: Colors.white,
                                            gradient: const [
                                              Color(0xFFFFE082),
                                              Color(0xFFFFC107),
                                            ],
                                          ),
                                          const SizedBox(width: 16),
                                          _statCard(
                                            color: red,
                                            icon: Icons.camera_alt_rounded,
                                            value: '...',
                                            label: 'Not Submitted',
                                            iconColor: Colors.white,
                                            gradient: const [
                                              Color(0xFFFF8A65),
                                              Color(0xFFF44336),
                                            ],
                                            onTap: null,
                                          ),
                                        ],
                                      );
                                    }
                                    return StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('submissions')
                                          .where('taskId', isEqualTo: _selectedTaskId)
                                          .snapshots(),
                                      builder: (context, subSnap) {
                                        if (!subSnap.hasData) {
                                          return Row(
                                            children: [
                                              _statCard(
                                                color: yellow,
                                                icon: Icons.check_circle,
                                                value: '...',
                                                label: 'Submitted',
                                                iconColor: Colors.white,
                                                gradient: const [
                                                  Color(0xFFFFE082),
                                                  Color(0xFFFFC107),
                                                ],
                                              ),
                                              const SizedBox(width: 16),
                                              _statCard(
                                                color: red,
                                                icon: Icons.camera_alt_rounded,
                                                value: '...',
                                                label: 'Not Submitted',
                                                iconColor: Colors.white,
                                                gradient: const [
                                                  Color(0xFFFF8A65),
                                                  Color(0xFFF44336),
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                        final submissions = subSnap.data!.docs;
                                        final submittedSchoolIds = submissions.map((s) => s['schoolId'] as String).toSet();
                                        final submitted = schools.where((s) => submittedSchoolIds.contains(s.id)).length;
                                        final notSubmitted = totalSchools - submitted;
                                        final notSubmittedSchools = schools.where((s) => !submittedSchoolIds.contains(s.id)).toList();
                                        return Row(
                                          children: [
                                            _statCard(
                                              color: yellow,
                                              icon: Icons.check_circle,
                                              value: submitted.toString(),
                                              label: 'Submitted',
                                              iconColor: Colors.white,
                                              gradient: const [
                                                Color(0xFFFFE082),
                                                Color(0xFFFFC107),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            _statCard(
                                              color: red,
                                              icon: Icons.camera_alt_rounded,
                                              value: notSubmitted.toString(),
                                              label: 'Not Submitted',
                                              iconColor: Colors.white,
                                              gradient: const [
                                                Color(0xFFFF8A65),
                                                Color(0xFFF44336),
                                              ],
                                              onTap: notSubmitted > 0
                                                  ? () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Schools Not Submitted'),
                                                          content: SizedBox(
                                                            width: 320,
                                                            child: ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount: notSubmittedSchools.length,
                                                              itemBuilder: (context, idx) {
                                                                final school = notSubmittedSchools[idx].data() as Map<String, dynamic>;
                                                                return ListTile(
                                                                  leading: const Icon(Icons.school),
                                                                  title: Text(school['name'] ?? school['email'] ?? 'School'),
                                                                  subtitle: school['email'] != null ? Text(school['email']) : null,
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: const Text('Close'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  : null,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Text(
                              'Quick Links',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: purple,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                _quickLink(
                                  icon: Icons.assignment_rounded,
                                  label: 'Submission Tasks',
                                  color: purple,
                                  background: purpleBg,
                                ),
                                const SizedBox(width: 18),
                                _quickLink(
                                  icon: Icons.list_alt_rounded,
                                  label: 'All Submissions',
                                  color: purple,
                                  background: purpleBg,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Right: Upcoming Drills, Recent Activity, Active Drill Tasks
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _infoCard(
                                  background: cardBg, // Info card background is white
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.event_note, color: purple),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Upcoming Drills',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: purple,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('• Earthquake Drill: June 15, 2024',
                                            style: TextStyle(fontSize: 15, color: Colors.black87)),
                                        Text('• Earthquake Drill: September 15, 2024',
                                            style: TextStyle(fontSize: 15, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _infoCard(
                            background: purpleBg,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Activity',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: purple,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _activityRow(
                                    icon: Icons.check_circle,
                                    iconColor: Color(0xFF3FE9B3),
                                    text: 'School A submitted Earthquake Drill report',
                                    date: 'June 8, 2024',
                                  ),
                                  _activityRow(
                                    icon: Icons.pending_actions,
                                    iconColor: Color(0xFFFFB75E),
                                    text: 'School B pending Earthquake Drill report',
                                    date: 'June 7, 2024',
                                  ),
                                  _activityRow(
                                    icon: Icons.check_circle,
                                    iconColor: Color(0xFF3FE9B3),
                                    text: 'School C submitted Earthquake Drill report',
                                    date: 'June 6, 2024',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _infoCard(
                            background: cardBg, // Info card background is white
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.assignment, color: purple),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Active Drill Tasks',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Earthquake Drill (Quarterly)',
                                    style: TextStyle(fontSize: 15, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _statCard({
    required Color color,
    required IconData icon,
    required String value,
    required String label,
    Color iconColor = Colors.white,
    List<Color>? gradient,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 170,
      height: 110,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: gradient == null ? color : null,
              gradient: gradient != null
                  ? LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: (gradient != null ? gradient.last : color).withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    child: Icon(icon, color: iconColor, size: 32),
                    radius: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.92),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

  Widget _quickLink({
    required IconData icon,
    required String label,
    required Color color,
    Color? background,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: background ?? color.withOpacity(0.13),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shadowColor: Colors.transparent,
      ),
      onPressed: () {},
      icon: Icon(icon, size: 22),
      label: Text(label),
    );
  }

  Widget _infoCard({required Widget child, Color? background}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.13),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _activityRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            date,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Helper to get school count
  Future<int> _getSchoolCount() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'school')
        .get();
    return snap.docs.length;
  }
}
