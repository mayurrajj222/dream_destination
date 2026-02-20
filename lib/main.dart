import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/employee_details_screen.dart';
import 'screens/train_details_screen_new.dart';
import 'screens/schedule_details_screen.dart';
import 'screens/tripwise_attendance_report_screen.dart';
import 'screens/psi_reports_dashboard_screen.dart';
import 'screens/trip_card_screen.dart';
import 'screens/ehk_staff_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dream Destination',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/employees': (context) => EmployeeDetailsScreen(),
        '/trains': (context) => TrainDetailsScreen(),
        '/schedules': (context) => ScheduleDetailsScreen(),
        '/attendance': (context) => TripwiseAttendanceReportScreen(),
        '/psi': (context) => PSIReportsDashboardScreen(),
        '/tripcard': (context) => TripCardScreen(),
        '/ehkstaff': (context) => EHKStaffScreen(),
      },
    );
  }
}
