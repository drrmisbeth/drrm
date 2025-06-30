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

  void _showProfileDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? error;
    bool loading = false;
    bool emailVerified = user?.emailVerified ?? false;

    Future<void> _sendVerificationEmail() async {
      try {
        await user?.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send verification email.')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Profile'),
            content: SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  if (!emailVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange, size: 18),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Email not verified.',
                              style: TextStyle(color: Colors.orange, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: loading ? null : () async {
                              await _sendVerificationEmail();
                            },
                            child: const Text('Resend', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.blue, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Note: verify email first before changing email or password.',
                          style: TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: loading || !emailVerified
                    ? null
                    : () async {
                        setState(() => loading = true);
                        try {
                          // Update email if changed
                          if (emailController.text.trim() != (user?.email ?? '')) {
                            await user?.updateEmail(emailController.text.trim());
                          }
                          // Update password if provided and matches
                          if (passwordController.text.isNotEmpty) {
                            if (passwordController.text != confirmPasswordController.text) {
                              setState(() {
                                error = 'Passwords do not match.';
                                loading = false;
                              });
                              return;
                            }
                            await user?.updatePassword(passwordController.text);
                          }
                          setState(() {
                            error = null;
                            loading = false;
                          });
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated.')),
                          );
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            error = e.message ?? 'Update failed';
                            loading = false;
                          });
                        } catch (e) {
                          setState(() {
                            error = 'Update failed';
                            loading = false;
                          });
                        }
                      },
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use only black, white, grey for color scheme
    final Color black = Colors.black;
    final Color white = Colors.white;
    final Color grey = Colors.grey[700]!;

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
                color: black,
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
                          color: white.withOpacity(0.10),
                        ),
                        padding: EdgeInsets.all(isMobile ? 4 : 8),
                        child: Icon(Icons.shield, color: white, size: isMobile ? 22 : 32),
                      ),
                      SizedBox(width: isMobile ? 6 : 12),
                      Text(
                        'DRRMIS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 15 : 22,
                          color: white,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 18 : 32),
                  // Navigation items
                  ...List.generate(navItems.length, (i) {
                    final selected = _selectedIndex == i;
                    final menuColor = grey;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 1 : 2, horizontal: isMobile ? 4 : 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: selected ? white.withOpacity(0.20) : Colors.transparent,
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 18),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _getMenuIcon(navItems[i], isSchool),
                            color: selected ? white : white.withOpacity(0.85),
                            size: isMobile ? 18 : 24,
                          ),
                          title: Text(
                            navItems[i],
                            style: TextStyle(
                              color: selected ? white : white.withOpacity(0.92),
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
                        color: white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSchool ? Icons.school : Icons.admin_panel_settings,
                            color: white,
                            size: isMobile ? 16 : 22,
                          ),
                          SizedBox(width: isMobile ? 4 : 8),
                          Text(
                            isSchool ? 'School' : 'Admin',
                            style: TextStyle(
                              color: white,
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12 : 15,
                            ),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: isMobile ? 12 : 16,
                            backgroundColor: white.withOpacity(0.18),
                            child: IconButton(
                              icon: Icon(Icons.account_circle, color: white, size: isMobile ? 14 : 18),
                              onPressed: () {
                                _showProfileDialog(context);
                              },
                              tooltip: 'Profile',
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.logout, color: white, size: isMobile ? 14 : 18),
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
                        color: black.withOpacity(0.10),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: isMobile ? 12 : 32, top: isMobile ? 10 : 28),
                          child: Text(
                            'Roxas City',
                            style: TextStyle(
                              color: white,
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
                    color: white,
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
                            color: white.withOpacity(0.98),
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
                color: black,
                child: Column(
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: black,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: white.withOpacity(0.10),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.shield, color: white, size: 32),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'DRRMIS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: white,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(navItems.length, (i) {
                      final selected = _selectedIndex == i;
                      final menuColor = grey;
                      return ListTile(
                        leading: Icon(
                          _getMenuIcon(navItems[i], isSchool),
                          color: selected ? white : white.withOpacity(0.85),
                        ),
                        title: Text(
                          navItems[i],
                          style: TextStyle(
                            color: selected ? white : white.withOpacity(0.92),
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
                        color: white,
                      ),
                      title: Text(isSchool ? 'School' : 'Admin', style: const TextStyle(color: Colors.white)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_circle, color: Colors.white),
                      title: const Text('Profile', style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _showProfileDialog(context);
                      },
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