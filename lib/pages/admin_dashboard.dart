import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statCards = [
      _statCard(
        context,
        'Schools',
        '120',
        Icons.school,
        Colors.indigo,
        [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
      ),
      _statCard(
        context,
        'Submitted',
        '80',
        Icons.check_circle,
        Colors.green,
        [Color(0xFF43E97B), Color(0xFF38F9D7)],
      ),
      _statCard(
        context,
        'Pending',
        '40',
        Icons.pending_actions,
        Colors.orange,
        [Color(0xFFFFB75E), Color(0xFFED8F03)],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: colorScheme.primary,
              ),
        ),
        const SizedBox(height: 32),
        // Responsive stat cards using Wrap
        Wrap(
          spacing: 28,
          runSpacing: 28,
          children: statCards,
        ),
        const SizedBox(height: 44),
        Text(
          'Quick Links',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: colorScheme.secondary,
              ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 24,
          children: [
            _quickLink(context, Icons.assignment, 'Submission Tasks', colorScheme.primary),
            _quickLink(context, Icons.list_alt, 'All Submissions', colorScheme.secondary),
          ],
        ),
      ],
    );
  }

  // Modern stat card with gradient background and shadow
  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color iconColor, List<Color> gradientColors) {
    return Container(
      width: 220,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.18),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.18),
              child: Icon(icon, color: iconColor, size: 34),
              radius: 28,
            ),
            const SizedBox(width: 18),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
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

  // Modern quick link button with custom color
  Widget _quickLink(BuildContext context, IconData icon, String label, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        backgroundColor: color.withOpacity(0.13),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        shadowColor: color.withOpacity(0.18),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 24),
      label: Text(label),
    );
  }
}
