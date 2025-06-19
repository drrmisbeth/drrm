import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/school_home.dart';
import 'pages/school_announcements.dart';
import 'pages/school_tasks.dart' as tasks;
import 'pages/school_my_submissions.dart';
import 'pages/admin_dashboard.dart';
import 'pages/admin_announcements.dart';
import 'pages/admin_tasks_manager.dart';
import 'pages/admin_all_submissions.dart';
import 'pages/admin_exports.dart';
import 'main.dart';
import 'user_role.dart'; // Use the shared UserRole enum

class AppShell extends StatefulWidget {
  final UserRole role;
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const AppShell({Key? key, required this.role, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  List<Widget> get _schoolPages => [
        SchoolHomePage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
        SchoolAnnouncementsPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
        tasks.SchoolTasksPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
        SchoolMySubmissionsPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
      ];

  List<String> get _schoolNav => [
        'Home',
        'Announcements',
        'Submission Tasks',
        'My Submissions',
      ];

  List<Widget> get _adminPages => [
        AdminDashboardPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
        AdminAnnouncementsPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
        AdminTasksManagerPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
        AdminAllSubmissionsPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
        AdminExportsPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
      ];

  List<String> get _adminNav => [
        'Dashboard',
        'Announcements',
        'Submission Tasks Manager',
        'All Submissions',
        'Exports',
      ];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Custom color scheme
    final Color orange = const Color(0xFFFF9800);
    final Color yellow = const Color(0xFFFFEB3B);
    final Color red = const Color(0xFFF44336);

    final isSchool = widget.role == UserRole.school;
    final navItems = isSchool ? _schoolNav : _adminNav;
    final pages = isSchool ? _schoolPages : _adminPages;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          if (!isMobile)
            Container(
              width: 250,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    orange.withOpacity(0.98),
                    Colors.deepOrange.shade700.withOpacity(0.98),
                    Colors.red.shade800.withOpacity(0.98),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              orange.withOpacity(0.22),
                              yellow.withOpacity(0.13),
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
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Navigation items
                  ...List.generate(navItems.length, (i) {
                    final selected = _selectedIndex == i;
                    final menuColors = [
                      orange,
                      yellow,
                      red,
                      Colors.deepOrange,
                      Colors.amber,
                      Colors.deepOrangeAccent,
                      Colors.orangeAccent,
                    ];
                    final menuColor = menuColors[i % menuColors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected ? menuColor.withOpacity(0.20) : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _getMenuIcon(navItems[i], isSchool),
                            color: selected ? menuColor : Colors.white.withOpacity(0.85),
                          ),
                          title: Text(
                            navItems[i],
                            style: TextStyle(
                              color: selected ? menuColor : Colors.white.withOpacity(0.92),
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = i;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  // User info and logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(18),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            child: IconButton(
                              icon: const Icon(Icons.account_circle, color: Colors.white, size: 18),
                              onPressed: () {},
                              tooltip: 'Profile',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                            tooltip: 'Logout',
                            onPressed: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Header area
                Container(
                  width: double.infinity,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: EdgeInsets.zero,
                  decoration: null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image with lower opacity and center alignment
                      Opacity(
                        opacity: 0.16, // Lowered opacity for a subtler effect
                        child: Image.asset(
                          'assets/header.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.center, // Show the middle part of the image
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.10), // Optional: subtle overlay for contrast
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 32, top: 28),
                          child: Text(
                            'Roxas City',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                              letterSpacing: 1.1,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black38,
                                  offset: Offset(1, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Page content
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: isMobile ? 12 : 32,
                          left: isMobile ? 4 : 16,
                          right: isMobile ? 4 : 16,
                          bottom: isMobile ? 8 : 16,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? double.infinity : 2000,
                          ),
                          child: Card(
                            elevation: 5,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            color: Colors.white.withOpacity(0.98),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 12 : 32,
                                horizontal: isMobile ? 6 : 32,
                              ),
                              child: pages[_selectedIndex],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // For mobile, show a drawer for navigation
      drawer: isMobile
          ? Drawer(
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          orange.withOpacity(0.98),
                          Colors.deepOrange.shade700.withOpacity(0.98),
                          Colors.red.shade800.withOpacity(0.98),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                orange.withOpacity(0.22),
                                yellow.withOpacity(0.13),
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
                            fontSize: 22,
                            color: Colors.white,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...List.generate(navItems.length, (i) {
                    final selected = _selectedIndex == i;
                    final menuColors = [
                      orange,
                      yellow,
                      red,
                      Colors.deepOrange,
                      Colors.amber,
                      Colors.deepOrangeAccent,
                      Colors.orangeAccent,
                    ];
                    final menuColor = menuColors[i % menuColors.length];
                    return ListTile(
                      leading: Icon(
                        _getMenuIcon(navItems[i], isSchool),
                        color: selected ? menuColor : Colors.black87,
                      ),
                      title: Text(
                        navItems[i],
                        style: TextStyle(
                          color: selected ? menuColor : Colors.black87,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = i;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                  const Spacer(),
                  ListTile(
                    leading: Icon(
                      isSchool ? Icons.school : Icons.admin_panel_settings,
                      color: Colors.black54,
                    ),
                    title: Text(isSchool ? 'School' : 'Admin'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.black54),
                    title: const Text('Logout'),
                    onTap: _logout,
                  ),
                ],
              ),
            )
          : null,
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