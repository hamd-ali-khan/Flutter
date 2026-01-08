import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'product.dart';
import 'profile.dart';
import '/login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0; // Tracks body page
  int _selectedBottomIndex = 0; // Tracks bottom nav selected
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Load user data from shared preferences
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Admin';
      userEmail = prefs.getString('email') ?? '';
    });
  }

  // Logout function
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
          (route) => false,
    );
  }

  // =========================
  // Home Page
  // =========================
  Widget buildHomePage() {
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
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              summaryCard("Total Users", "150", Icons.supervised_user_circle, Colors.blueAccent),
              summaryCard("Total Products", "120", Icons.shopping_cart, Colors.orangeAccent),
              summaryCard("Orders", "75", Icons.receipt_long, Colors.green),
              summaryCard("Revenue", "\$12,500", Icons.monetization_on, Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              actionCard("Add Product", Icons.add_shopping_cart, Colors.blueAccent, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BakerProductPage()));
              }),
              actionCard("View Users", Icons.supervised_user_circle, Colors.orangeAccent, () {
                setState(() {
                  _currentIndex = 1;
                  _selectedBottomIndex = 2; // Highlight Users in bottom nav
                });
              }),
              actionCard("Reports", Icons.bar_chart, Colors.green, () {
                // TODO: Add Reports Page
              }),
              actionCard("Settings", Icons.settings, Colors.purpleAccent, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // Summary Card Widget
  // =========================
  Widget summaryCard(String title, String count, IconData icon, Color iconColor) {
    return Container(
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
        children: [
          CircleAvatar(
            radius: 0,
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16)),
              const SizedBox(height: 4),
              Text(count,
                  style: const TextStyle(
                      color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // Action Card Widget
  // =========================
  Widget actionCard(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
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
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  // =========================
  // Users Page Placeholder
  // =========================
  Widget buildUsersPage() {
    return const Center(child: Text("Users Page", style: TextStyle(fontSize: 22)));
  }

  // =========================
  // Profile Page Placeholder
  // =========================
  Widget buildProfilePage() {
    return const ProfileScreen();
  }

  // =========================
  // Main Build
  // =========================
  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_currentIndex == 0) {
      body = buildHomePage();
    } else if (_currentIndex == 1) {
      body = buildUsersPage();
    } else {
      body = buildProfilePage();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            title: const Text(
              "Dashboard",
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
              decoration: const BoxDecoration(color: Colors.blueAccent),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                  _selectedBottomIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu),
              title: const Text("Products"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BakerProductPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text("Users"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                  _selectedBottomIndex = 2;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                  _selectedBottomIndex = 3;
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),

      body: body,

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedBottomIndex,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BakerProductPage()));
              } else if (index == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else {
                setState(() {
                  _selectedBottomIndex = index;
                  if (index == 0) _currentIndex = 0;
                  if (index == 2) _currentIndex = 1;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart, size: 28), label: "Items"),
              BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle, size: 28), label: "Users"),
              BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
