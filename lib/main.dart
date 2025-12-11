import 'package:flutter/material.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/active_event_screen.dart';
import 'screens/event_list_screen.dart';
import 'screens/add_planning_event_screen.dart';
import 'screens/event_detail_full_screen.dart';
import 'screens/history_screen.dart';
import 'screens/scan_qr_screen.dart'; 

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
        "/profile": (context) => const ProfileScreen(),
        
        // Event routes - hanya yang utama
        "/event-list": (context) => const EventListScreen(),
        "/add-planning-event": (context) => const AddPlanningEventScreen(),
        "/history": (context) => const HistoryScreen(),
        "/scan-qr": (context) => const ScanQRScreen(),
        
        // Event detail dengan parameter
        "/event-detail": (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          
          if (args is Map<String, dynamic>) {
            return EventDetailFullScreen(
              eventId: args['event_id'],
              showExport: args['show_export'] ?? false,
            );
          } else {
            // Fallback jika tidak ada parameter
            return const EventDetailFullScreen();
          }
        },
      },
    );
  }
}