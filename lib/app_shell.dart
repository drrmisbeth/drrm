import 'package:flutter/material.dart';
import 'pages/school_home.dart';
import 'pages/school_announcements.dart';
import 'pages/school_tasks.dart';
import 'pages/school_submit_form.dart';
import 'pages/school_my_submissions.dart';
import 'pages/admin_dashboard.dart';
import 'pages/admin_announcements.dart';
import 'pages/admin_tasks_manager.dart';
import 'pages/admin_all_submissions.dart';
import 'pages/admin_exports.dart';
import 'user_role.dart'; // Use the shared UserRole enum

class AppShell extends StatefulWidget {
  final UserRole role;
  const AppShell({Key? key, required this.role}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  List<Widget> get _schoolPages => const [
        SchoolHomePage(),
        SchoolAnnouncementsPage(),
        SchoolTasksPage(),
        SchoolSubmitFormPage(),
        SchoolMySubmissionsPage(),
      ];

  List<String> get _schoolNav => [
        'Home',
        'Announcements',
        'Submission Tasks',
        'Submit Form',
        'My Submissions',
      ];

  List<Widget> get _adminPages => const [
        AdminDashboardPage(),
        AdminAnnouncementsPage(),
        AdminTasksManagerPage(),
        AdminAllSubmissionsPage(),
        AdminExportsPage(),
      ];

  List<String> get _adminNav => [
        'Dashboard',
        'Announcements',
        'Submission Tasks Manager',
        'All Submissions',
        'Exports',
      ];

  @override
  Widget build(BuildContext context) {
    final isSchool = widget.role == UserRole.school;
    final navItems = isSchool ? _schoolNav : _adminNav;
    final pages = isSchool ? _schoolPages : _adminPages;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.95),
                colorScheme.secondary.withOpacity(0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withOpacity(0.13),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 700;
                  return Row(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withOpacity(0.22),
                                  colorScheme.secondary.withOpacity(0.13),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.shield, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'DRRMIS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      if (!isMobile)
                        ...List.generate(navItems.length, (i) {
                          final selected = _selectedIndex == i;
                          final menuColors = [
                            Colors.deepPurple,
                            Colors.indigo,
                            Colors.teal,
                            Colors.orange,
                            Colors.pink,
                            Colors.blue,
                            Colors.green,
                            Colors.red,
                          ];
                          final menuColor = menuColors[i % menuColors.length];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? menuColor.withOpacity(0.18)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: selected
                                        ? menuColor
                                        : Colors.white.withOpacity(0.90),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    textStyle: TextStyle(
                                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 17,
                                      letterSpacing: 0.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedIndex = i;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getMenuIcon(navItems[i], isSchool),
                                        size: 20,
                                        color: selected ? menuColor : Colors.white.withOpacity(0.85),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(navItems[i]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      if (isMobile)
                        PopupMenuButton<int>(
                          icon: Icon(Icons.menu, color: Colors.white),
                          color: Colors.white,
                          onSelected: (i) {
                            setState(() {
                              _selectedIndex = i;
                            });
                          },
                          itemBuilder: (context) => [
                            for (int i = 0; i < navItems.length; i++)
                              PopupMenuItem(
                                value: i,
                                child: Row(
                                  children: [
                                    Icon(
                                      _getMenuIcon(navItems[i], isSchool),
                                      color: Colors.deepPurple,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(navItems[i]),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSchool ? Icons.school : Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isSchool ? 'School' : 'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 18),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white.withOpacity(0.18),
                              child: IconButton(
                                icon: const Icon(Icons.account_circle, color: Colors.white),
                                onPressed: () {},
                                tooltip: 'Profile',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.07),
                  colorScheme.secondary.withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: isMobile ? 18 : 40,
                  left: isMobile ? 6 : 18,
                  right: isMobile ? 6 : 18,
                  bottom: isMobile ? 10 : 18,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 600 : 1100),
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 18 : 36,
                        horizontal: isMobile ? 10 : 36,
                      ),
                      child: pages[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getMenuIcon(String label, bool isSchool) {
    // Assign icons based on menu label
    switch (label) {
      case 'Home':
        return Icons.home_rounded;
      case 'Announcements':
        return Icons.campaign_rounded;
      case 'Submission Tasks':
        return Icons.assignment_rounded;
      case 'Submit Form':
        return Icons.upload_rounded;
      case 'My Submissions':
        return Icons.list_alt_rounded;
      case 'Dashboard':
        return Icons.dashboard_rounded;
      case 'Submission Tasks Manager':
        return Icons.settings_rounded;
      case 'All Submissions':
        return Icons.fact_check_rounded;
      case 'Exports':
        return Icons.file_download_rounded;
      default:
        return Icons.circle;
    }
  }
}