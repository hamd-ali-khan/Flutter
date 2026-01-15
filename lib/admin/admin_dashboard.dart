import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/edit_profile.dart';
import 'package:my_app/product.dart';
import '/login.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String userName = '';
  String userEmail = '';

  // ✅ SAFE animation setup (NO late errors)
  AnimationController? _controller;
  Animation<double> _fadeAnimation = const AlwaysStoppedAnimation(1);
  Animation<Offset> _slideAnimation =
  const AlwaysStoppedAnimation(Offset.zero);

  final List<Widget> _pages = const [
    Center(child: Text("Home Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Users Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 22))),
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller!, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOut),
    );

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Admin';
      userEmail = prefs.getString('email') ?? '';
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
          (route) => false,
    );
  }

  // =========================
  // Summary Card
  // =========================
  Widget summaryCard(
      String title, String count, IconData icon, Color iconColor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      count,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // Action Card
  // =========================
  Widget actionCard(
      String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // Home Page (Responsive)
  // =========================
  Widget buildHomePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 2;
        if (constraints.maxWidth >= 900) {
          columns = 4;
        } else if (constraints.maxWidth >= 600) {
          columns = 3;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  summaryCard("Total Users", "150",
                      Icons.supervised_user_circle, Colors.blueAccent),
                  summaryCard("Total Products", "120",
                      Icons.shopping_cart, Colors.orangeAccent),
                  summaryCard("Orders", "75",
                      Icons.receipt_long, Colors.green),
                  summaryCard("Revenue", "\$12,500",
                      Icons.monetization_on, Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  actionCard("Add Product", Icons.add_shopping_cart,
                      Colors.blueAccent, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BakerProductPage()),
                        );
                      }),
                  actionCard("View Users",
                      Icons.supervised_user_circle, Colors.orangeAccent, () {
                        setState(() => _currentIndex = 1);
                      }),
                  actionCard("Reports", Icons.bar_chart, Colors.green, () {}),
                  actionCard("Settings", Icons.settings,
                      Colors.purpleAccent, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()),
                        );
                      }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture:
              const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Products"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BakerProductPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: _currentIndex == 0 ? buildHomePage() : _pages[_currentIndex],
    );
  }
}
