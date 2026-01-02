import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'product.dart';
import '/login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  int _selectedBottomIndex = 0;
  String userName = '';
  String userEmail = '';

  final List<Widget> _pages = const [
    Center(child: Text("Home Page", style: TextStyle(fontSize: 22))),
    // Center(child: Text("Products Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Users Page", style: TextStyle(fontSize: 22))),
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 22))),
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  //  LOAD USER DATA FROM SHARED PREFERENCES
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Admin';
      userEmail = prefs.getString('email') ?? '';
    });
  }

  //  LOGOUT FUNCTION
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


  @override
  Widget build(BuildContext context) {
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
            title: Text(
              "Dashboard",
              style: const TextStyle(color: Colors.black),
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

      // Drawer menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userEmail),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              decoration: const BoxDecoration(color: Colors.blueAccent),
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
              leading: const Icon(Icons.menu),
              title: const Text("Products"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text("Users"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout, //  LOGOUT FUNCTION
            ),
          ],
        ),
      ),

      // Main content
      body: _pages[_currentIndex],

      // BottomNavigationBar
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
                // PRODUCTS → OPEN NEW SCREEN
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BakerProductPage(),
                  ),
                );
              } else {
                setState(() {
                  _selectedBottomIndex = index;

                  if (index == 0) {
                    _currentIndex = 0; // Home
                  } else if (index == 2) {
                    _currentIndex = 1; // Users
                  } else if (index == 3) {
                    _currentIndex = 2; // Profile
                  }
                });
              }
            },



            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart, size: 28), label: "Items"),
              BottomNavigationBarItem(icon: Icon(Icons.supervised_user_circle, size: 28), label: "Users"),
              BottomNavigationBarItem(icon: Icon(Icons.lock, size: 28), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
