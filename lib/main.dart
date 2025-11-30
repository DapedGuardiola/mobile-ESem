import 'package:flutter/material.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/event_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const LandingPageScreen(),
        "/auth": (context) => const AuthChoiceScreen(),
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/home": (context) => const HomeScreen(),
        "/event-detail": (context) => const EventDetailScreen(),
        "/dashboard": (context) => const DashboardScreen(),
        "/profile": (context) => const ProfileScreen(),
      },
    );
  }
}