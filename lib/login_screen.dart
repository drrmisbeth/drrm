import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart' as user_role;
import 'app_shell.dart';

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
  bool _obscurePassword = true; // <-- Add this line

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
      // Show dialog for wrong password/email
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Failed'),
              content: const Text('Incorrect password/email'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        setState(() {
          _error = null; // Do not show Firebase error in UI for these cases
          _loading = false;
        });
        return;
      }
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

  Future<void> _forgotPassword() async {
    final email = _usernameController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _error = 'Enter your email to reset password.';
      });
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Failed to send reset email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use only black, white, grey for color scheme
    final Color black = Colors.black;
    final Color white = Colors.white;
    final Color grey = Colors.grey[700]!;

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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: black, // <-- Set background as black
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
                        color: black.withOpacity(0.13),
                        boxShadow: [
                          BoxShadow(
                            color: black.withOpacity(0.10),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Icon(Icons.shield, color: black, size: 48),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to DRRMIS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: black,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Disaster Risk Reduction & Management Information System',
                      style: TextStyle(
                        color: grey,
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
                              prefixIcon: Icon(Icons.person, color: black),
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
                            obscureText: _obscurePassword, // <-- Change here
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                            onFieldSubmitted: (_) {
                              if (_formKey.currentState?.validate() ?? false) {
                                _login();
                              }
                            },
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _loading ? null : _forgotPassword,
                              child: const Text('Forgot password?', style: TextStyle(color: Colors.black)),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: black,
                                foregroundColor: white,
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
