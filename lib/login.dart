import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/dashboard.dart';
import '/user_dashboard.dart';
import '../apis/api_services.dart';
import '../utils/token_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if already logged in
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? roleId = prefs.getInt('role_id');

    if (roleId != null) {
      _navigateToDashboard(roleId);
    }
  }

  // Navigate based on role
  void _navigateToDashboard(int roleId) {
    if (roleId == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserDashboard()),
      );
    }
  }

  // Login API using ApiService
  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter email and password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await ApiService.post("login", {
        "email": email,
        "password": password,
      });

      // Save token
      String token = data['token'] ?? '';
      await TokenStorage.saveToken(token);

      // Save user info
      final user = data['user'];
      int userId = user['id'];
      int roleId = user['role_id'];
      String name = user['name'] ?? '';
      String userEmail = user['email'] ?? '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
      await prefs.setInt('role_id', roleId);
      await prefs.setString('name', name);
      await prefs.setString('email', userEmail);

      // Navigate based on role
      _navigateToDashboard(roleId);
    } catch (e) {
      _showSnackBar("Login failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show error message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.red.shade600,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: Text(
                      _isLoading ? "Please wait..." : "Login",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
