import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://lvsudrxnhvleoaibpzfd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2c3VkcnhuaHZsZW9haWJwemZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExODc1NTgsImV4cCI6MjA2Njc2MzU1OH0.978IUIyDZ6Y58hRxmdSfZwbVPz-jx9UA0tmafU-PQ2Q');
  // Check Supabase connection
  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      print('Supabase connection failed: No active session');
    } else {
      print('Supabase connection successful');
    }
  } catch (e) {
    print('Supabase connection error: $e');
  }
  // Check Supabase connection by making a simple API call
  try {
    final response = await Supabase.instance.client.from('test').select().limit(1).maybeSingle();
    if (response != null) {
      print('Supabase connection successful');
    } else {
      print('Supabase connection failed: No data returned');
    }
  } catch (e) {
    print('Supabase connection error: $e');
  }
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