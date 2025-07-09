import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolHomePage extends StatelessWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const SchoolHomePage({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Black, grey, white palette
    final Color primary = Colors.black;
    final Color secondary = Colors.grey[900]!;
    final Color cardBg = Colors.grey[850]!;
    final Color accent = Colors.grey[700]!;
    final Color textColor = Colors.white;
    final Color hintColor = Colors.grey[400]!;
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 32, horizontal: isMobile ? 14 : 32),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.school, color: primary, size: isMobile ? 32 : 48),
                  SizedBox(width: isMobile ? 10 : 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to DRRMIS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 28,
                            color: primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your dashboard for disaster risk reduction and management in schools.',
                          style: TextStyle(fontSize: isMobile ? 13 : 16, color: Colors.grey[300]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 18 : 32),
            // Quick Summary Cards
            Wrap(
              spacing: isMobile ? 10 : 24,
              runSpacing: isMobile ? 10 : 18,
              children: [
                GestureDetector(
                  onTap: () {
                    DefaultTabController.of(context)?.animateTo(0);
                  },
                  child: _summaryCard(
                    icon: Icons.assignment_turned_in,
                    label: 'Submission Tasks',
                    value: 'View and submit required drills',
                    color: primary,
                    context: context,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                  child: _summaryCard(
                    icon: Icons.campaign_rounded,
                    label: 'Announcements',
                    value: 'See latest updates',
                    color: accent,
                    context: context,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 18 : 32),
            // Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Use',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 15 : 20,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Check for new submission tasks regularly.\n'
                      '• Submit your drill reports before the deadline.\n'
                      '• Review announcements for important updates.\n'
                      '• Track your previous submissions in "My Submissions".',
                      style: TextStyle(fontSize: isMobile ? 13 : 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required BuildContext context,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return SizedBox(
      width: isMobile ? double.infinity : 260,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white, // Remove dark/grey background
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 18, horizontal: isMobile ? 10 : 18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: isMobile ? 22 : 28),
                radius: isMobile ? 20 : 26,
              ),
              SizedBox(width: isMobile ? 10 : 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16, color: color)),
                    SizedBox(height: 2),
                    Text(value, style: TextStyle(fontSize: isMobile ? 11 : 13, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
