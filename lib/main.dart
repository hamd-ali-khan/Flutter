import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/login.dart';
import '/dashboard.dart';
import 'package:my_app/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user is already logged in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? role = prefs.getString('role');

  Widget initialScreen;

  if (role == 'admin') {
    initialScreen = const AdminDashboard();
  } else if (role == 'user') {
    initialScreen = const Dashboard();
  } else {
    initialScreen = const Login();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({required this.initialScreen, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: initialScreen);
  }
}
