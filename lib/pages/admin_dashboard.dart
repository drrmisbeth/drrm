import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AdminDashboardPage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

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
        final isMobile = constraints.maxWidth < 900;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 24),
                    // Stat cards in column
                    _statCard(
                      color: orange,
                      icon: Icons.school,
                      value: '120',
                      label: 'Schools',
                    ),
                    const SizedBox(height: 16),
                    _statCard(
                      color: yellow,
                      icon: Icons.check_circle,
                      value: '80',
                      label: 'Submitted',
                      iconColor: Colors.white,
                      gradient: const [
                        Color(0xFFFFE082),
                        Color(0xFFFFC107),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _statCard(
                      color: red,
                      icon: Icons.camera_alt_rounded,
                      value: '40',
                      label: 'Pending',
                      iconColor: Colors.white,
                      gradient: const [
                        Color(0xFFFF8A65),
                        Color(0xFFF44336),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Quick Links',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF7C6CB2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _quickLink(
                      icon: Icons.assignment_rounded,
                      label: 'Submission Tasks',
                      color: const Color(0xFF7C6CB2),
                    ),
                    const SizedBox(height: 10),
                    _quickLink(
                      icon: Icons.list_alt_rounded,
                      label: 'All Submissions',
                      color: const Color(0xFF7C6CB2),
                    ),
                    const SizedBox(height: 24),
                    _infoCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event_note, color: Color(0xFF7C6CB2)),
                                const SizedBox(width: 8),
                                Text(
                                  'Upcoming Drills',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Color(0xFF7C6CB2),
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
                      color: const Color(0xFFF8F3FB),
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
                                color: Color(0xFF7C6CB2),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment, color: Color(0xFF7C6CB2)),
                                const SizedBox(width: 8),
                                Text(
                                  'Active Drill Tasks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF7C6CB2),
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
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: orange,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                _statCard(
                                  color: orange,
                                  icon: Icons.school,
                                  value: '120',
                                  label: 'Schools',
                                ),
                                const SizedBox(width: 24),
                                _statCard(
                                  color: yellow,
                                  icon: Icons.check_circle,
                                  value: '80',
                                  label: 'Submitted',
                                  iconColor: Colors.white,
                                  gradient: const [
                                    Color(0xFFFFE082),
                                    Color(0xFFFFC107),
                                  ],
                                ),
                                const SizedBox(width: 24),
                                _statCard(
                                  color: red,
                                  icon: Icons.camera_alt_rounded,
                                  value: '40',
                                  label: 'Pending',
                                  iconColor: Colors.white,
                                  gradient: const [
                                    Color(0xFFFF8A65),
                                    Color(0xFFF44336),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Text(
                              'Quick Links',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF7C6CB2),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                _quickLink(
                                  icon: Icons.assignment_rounded,
                                  label: 'Submission Tasks',
                                  color: const Color(0xFF7C6CB2),
                                ),
                                const SizedBox(width: 18),
                                _quickLink(
                                  icon: Icons.list_alt_rounded,
                                  label: 'All Submissions',
                                  color: const Color(0xFF7C6CB2),
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.event_note, color: Color(0xFF7C6CB2)),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Upcoming Drills',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Color(0xFF7C6CB2),
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
                            color: const Color(0xFFF8F3FB),
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
                                      color: Color(0xFF7C6CB2),
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.assignment, color: Color(0xFF7C6CB2)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Active Drill Tasks',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF7C6CB2),
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
  }) {
    return Container(
      width: 200,
      height: 110,
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
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.18),
              child: Icon(icon, color: iconColor, size: 32),
              radius: 28,
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickLink({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: color.withOpacity(0.13),
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

  Widget _infoCard({required Widget child, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
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
}
