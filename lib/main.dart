import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Add this import
import 'firebase_options.dart';
import 'user_role.dart' as user_role;
import 'app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ievsphgbaytnfwbjyykn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlldnNpaGdiYXl0bmZ3Ymp5eWtuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2OTA5OTEsImV4cCI6MjA2NTI2Njk5MX0.g1WzqHj5Xtys3GZUpQBwBaeTN25RB3DGEZilQqNujIE',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _darkMode = !_darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Modern color scheme
    final Color orange = const Color(0xFFFF9800);
    final Color yellow = const Color(0xFFFFEB3B);
    final Color red = const Color(0xFFF44336);
    final Color accent = const Color(0xFFFEF3E2);

    final lightTheme = ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: orange,
        onPrimary: Colors.white,
        secondary: yellow,
        onSecondary: Colors.black,
        error: red,
        onError: Colors.white,
        background: accent,
        onBackground: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.97),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      cardTheme: CardThemeData(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        color: Colors.white.withOpacity(0.98),
      ),
      scaffoldBackgroundColor: accent,
      fontFamily: 'Segoe UI',
    );

    final darkTheme = ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: orange,
        onPrimary: Colors.black,
        secondary: yellow,
        onSecondary: Colors.black,
        error: red,
        onError: Colors.white,
        background: Colors.grey[900]!,
        onBackground: Colors.white,
        surface: Colors.grey[850]!,
        onSurface: Colors.white,
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      cardTheme: CardThemeData(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        color: Colors.grey[900],
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      fontFamily: 'Segoe UI',
    );

    return MaterialApp(
      title: 'DRRMIS',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginScreen(
        onToggleDarkMode: _toggleDarkMode,
        darkMode: _darkMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback? onToggleDarkMode;
  final bool darkMode;
  const LoginScreen({Key? key, this.onToggleDarkMode, this.darkMode = false}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text;
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      // Sign in with Firebase Auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Fetch user role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (!userDoc.exists || userDoc.data()?['role'] == null) {
        setState(() {
          _error = 'User role not found.';
          _loading = false;
        });
        return;
      }
      final String roleStr = userDoc.data()!['role'];
      user_role.UserRole? role;
      if (roleStr == 'admin') {
        role = user_role.UserRole.admin;
      } else if (roleStr == 'school') {
        role = user_role.UserRole.school;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AppShell(
            role: role!,
            onToggleDarkMode: widget.onToggleDarkMode,
            darkMode: widget.darkMode,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Login failed';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Login failed';
        _loading = false;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withOpacity(0.13),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.10),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Icon(Icons.shield, color: colorScheme.primary, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to DRRMIS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: colorScheme.primary,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Disaster Risk Reduction & Management Information System',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: StadiumBorder(),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                elevation: 2,
                              ),
                              onPressed: _loading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        _login();
                                      }
                                    },
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement registration navigation
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      child: const Text('No account? Register'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}