import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/school_home.dart';
import 'pages/school_announcements.dart';
import 'pages/school_tasks.dart' as tasks;
import 'pages/admin_dashboard.dart';
import 'pages/admin_announcements.dart';
import 'pages/admin_tasks_manager.dart';
import 'login_screen.dart'; // <-- change from 'main.dart' to 'login_screen.dart'
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
        SchoolAnnouncementsPage(),
        tasks.SchoolTasksPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          darkMode: widget.darkMode,
        ),
      ];

  List<String> get _schoolNav => [
        'Home',
        'Announcements',
        'Submission Tasks',
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
      ];

  List<String> get _adminNav => [
        'Dashboard',
        'Announcements',
        'Submission Tasks Manager',
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
              width: isMobile ? 80 : 250,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: const Color(0xFF232323),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 18 : 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.10),
                        ),
                        padding: EdgeInsets.all(isMobile ? 4 : 8),
                        child: Icon(Icons.shield, color: Colors.white, size: isMobile ? 22 : 32),
                      ),
                      SizedBox(width: isMobile ? 6 : 12),
                      Text(
                        'DRRMIS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 15 : 22,
                          color: Colors.white,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 18 : 32),
                  // Navigation items
                  ...List.generate(navItems.length, (i) {
                    final selected = _selectedIndex == i;
                    final menuColors = [
                      Colors.orange,
                      Colors.yellow,
                      Colors.red,
                      Colors.deepOrange,
                      Colors.amber,
                      Colors.deepOrangeAccent,
                      Colors.orangeAccent,
                    ];
                    final menuColor = menuColors[i % menuColors.length];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 1 : 2, horizontal: isMobile ? 4 : 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected ? menuColor.withOpacity(0.20) : Colors.transparent,
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 18),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _getMenuIcon(navItems[i], isSchool),
                            color: selected ? menuColor : Colors.white.withOpacity(0.85),
                            size: isMobile ? 18 : 24,
                          ),
                          title: Text(
                            navItems[i],
                            style: TextStyle(
                              color: selected ? menuColor : Colors.white.withOpacity(0.92),
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              fontSize: isMobile ? 13 : 16,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = i;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isMobile ? 10 : 18),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8, vertical: isMobile ? 1 : 2),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  // User info and logout
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 18, vertical: isMobile ? 8 : 18),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 12, vertical: isMobile ? 5 : 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSchool ? Icons.school : Icons.admin_panel_settings,
                            color: Colors.white,
                            size: isMobile ? 16 : 22,
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          Text(
                            isSchool ? 'School' : 'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12 : 15,
                            ),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: isMobile ? 12 : 16,
                            backgroundColor: Colors.white.withOpacity(0.18),
                            child: IconButton(
                              icon: Icon(Icons.account_circle, color: Colors.white, size: isMobile ? 14 : 18),
                              onPressed: () {},
                              tooltip: 'Profile',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: Colors.white, size: isMobile ? 14 : 18),
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
                  height: isMobile ? 70 : 120,
                  margin: EdgeInsets.only(bottom: isMobile ? 8 : 18),
                  padding: EdgeInsets.zero,
                  decoration: null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: 0.16,
                        child: Image.asset(
                          'assets/header.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.10),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: isMobile ? 12 : 32, top: isMobile ? 10 : 28),
                          child: Text(
                            'Roxas City',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 22 : 38,
                              letterSpacing: 1.1,
                              shadows: const [
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
                    color: Colors.white,
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: isMobile ? 8 : 32,
                          left: isMobile ? 2 : 16,
                          right: isMobile ? 2 : 16,
                          bottom: isMobile ? 4 : 16,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? double.infinity : 1440,
                          ),
                          child: Card(
                            elevation: 5,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 10 : 22)),
                            color: Colors.white.withOpacity(0.98),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 8 : 32,
                                horizontal: isMobile ? 4 : 32,
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
              child: Container(
                color: const Color(0xFF232323),
                child: Column(
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: const Color(0xFF232323),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.10),
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
                        Colors.orange,
                        Colors.yellow,
                        Colors.red,
                        Colors.deepOrange,
                        Colors.amber,
                        Colors.deepOrangeAccent,
                        Colors.orangeAccent,
                      ];
                      final menuColor = menuColors[i % menuColors.length];
                      return ListTile(
                        leading: Icon(
                          _getMenuIcon(navItems[i], isSchool),
                          color: selected ? menuColor : Colors.white.withOpacity(0.85),
                        ),
                        title: Text(
                          navItems[i],
                          style: TextStyle(
                            color: selected ? menuColor : Colors.white.withOpacity(0.92),
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
                        color: Colors.white,
                      ),
                      title: Text(isSchool ? 'School' : 'Admin', style: const TextStyle(color: Colors.white)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text('Logout', style: TextStyle(color: Colors.white)),
                      onTap: _logout,
                    ),
                  ],
                ),
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
      default:
        return Icons.circle;
    }
  }
}