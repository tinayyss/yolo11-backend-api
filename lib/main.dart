import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import dependencies
import 'services/auth_service.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';

void main() {
  // Sinisigurado na handa ang engine bago mag-check ng login status
  WidgetsFlutterBinding.ensureInitialized();
  
  // Gawing transparent ang status bar para sa modernong itsura
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const YoloThesisApp());
}

class YoloThesisApp extends StatelessWidget {
  const YoloThesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YOLO11 Safety Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        fontFamily: 'Roboto', 
      ),
      // Ang AuthWrapper ang unang screen na lalabas (Splash)
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // DITO ANG PAG-AYOS SA ERROR MO:
  void _checkStatus() async {
    // GAMITIN ANG isLoggedIn() PARA SA AUTO-LOGIN CHECK
    // HINDI .login() DAHIL WALA TAYONG USERNAME/PASS DITO
    bool loggedIn = await AuthService.isLoggedIn();
    
    // 2 seconds delay para makita ang cool splash logo mo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Kung loggedIn == true, dideretso sa Dashboard. Kung hindi, sa Login.
          builder: (_) => loggedIn ? const Dashboard() : const Login(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.radar_rounded,
              size: 100,
              color: Colors.cyanAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              "YOLO11 MONITOR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.cyanAccent,
              strokeWidth: 2,
            ),
            const SizedBox(height: 20),
            Text(
              "INITIALIZING AI CORE...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}