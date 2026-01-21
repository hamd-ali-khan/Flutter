import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/edit_profile.dart';
import 'add_product.dart';
import 'branch.dart';
import 'roles.dart';
import 'users.dart';
import '/login.dart';
import 'package:my_app/apis/api_services.dart';

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

  AnimationController? _controller;
  Animation<double> _fadeAnimation = const AlwaysStoppedAnimation(1);
  Animation<Offset> _slideAnimation = const AlwaysStoppedAnimation(Offset.zero);

  final List<Widget> _pages = const [
    Center(child: Text("Home Page", style: TextStyle(fontSize: 22))),
    AdminUsersPage(),
    Center(child: Text("Profile Page", style: TextStyle(fontSize: 22))),
  ];

  int totalUsers = 0;
  int totalProducts = 0;

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchTotalUsers();
    fetchTotalProducts();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOut));

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

  Future<void> fetchTotalUsers() async {
    try {
      final response = await ApiService.get("users");
      List data = [];
      if (response is Map && response.containsKey("data"))
        data = response["data"];
      else if (response is List)
        data = response;
      setState(() => totalUsers = data.length);
    } catch (_) {
      setState(() => totalUsers = 0);
    }
  }

  Future<void> fetchTotalProducts() async {
    try {
      final data = await ApiService.get("products");
      List productsList = [];
      if (data is Map && data.containsKey("data"))
        productsList = data["data"];
      else if (data is List)
        productsList = data;
      setState(() => totalProducts = productsList.length);
    } catch (_) {
      setState(() => totalProducts = 0);
    }
  }

  // ================= Modern Summary Card =================
  Widget summaryCard(
    String title,
    String count,
    IconData icon, {
    Color startColor = Colors.blue,
    Color endColor = Colors.lightBlue,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: startColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      count,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= Modern Action Card =================
  Widget actionCard(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= Build Modern Dashboard =================
  Widget buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                summaryCard(
                  "Total Users",
                  totalUsers.toString(),
                  Icons.supervised_user_circle,
                  startColor: Colors.blueAccent,
                  endColor: Colors.lightBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminUsersPage()),
                    ).then((_) => fetchTotalUsers());
                  },
                ),
                const SizedBox(width: 16),
                summaryCard(
                  "Total Products",
                  totalProducts.toString(),
                  Icons.shopping_cart,
                  startColor: Colors.orangeAccent,
                  endColor: Colors.deepOrange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAddProductPage(),
                      ),
                    ).then((_) => fetchTotalProducts());
                  },
                ),
                const SizedBox(width: 16),
                summaryCard(
                  "Orders",
                  "75",
                  Icons.receipt_long,
                  startColor: Colors.green,
                  endColor: Colors.lightGreen,
                ),
                const SizedBox(width: 16),
                summaryCard(
                  "Revenue",
                  "\$12,500",
                  Icons.monetization_on,
                  startColor: Colors.purpleAccent,
                  endColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900
                ? 4
                : MediaQuery.of(context).size.width > 600
                ? 3
                : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              actionCard(
                "Add Product",
                Icons.add_shopping_cart,
                Colors.blueAccent,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminAddProductPage(),
                    ),
                  ).then((_) => fetchTotalProducts());
                },
              ),
              actionCard(
                "View Users",
                Icons.supervised_user_circle,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUsersPage()),
                  ).then((_) => fetchTotalUsers());
                },
              ),
              actionCard("Roles", Icons.admin_panel_settings, Colors.green, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminRolesPage()),
                );
              }),
              actionCard(
                "Branches",
                Icons.location_city,
                Colors.purpleAccent,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminBranchPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= Drawer Item =================
  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.blueAccent,
    Color titleColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
        iconTheme: const IconThemeData(
          color: Colors.white, // <-- All AppBar icons (menu/back) will be white
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              accountName: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                userEmail,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blueAccent, size: 36),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  drawerItem(
                    icon: Icons.home,
                    title: "Home",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  drawerItem(
                    icon: Icons.shopping_cart,
                    title: "Products",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAddProductPage(),
                        ),
                      ).then((_) => fetchTotalProducts());
                    },
                  ),
                  drawerItem(
                    icon: Icons.supervised_user_circle,
                    title: "Users",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersPage(),
                        ),
                      ).then((_) => fetchTotalUsers());
                    },
                  ),
                  drawerItem(
                    icon: Icons.admin_panel_settings,
                    title: "Roles",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminRolesPage(),
                        ),
                      );
                    },
                  ),
                  drawerItem(
                    icon: Icons.location_city,
                    title: "Branches",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminBranchPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(thickness: 1, height: 32),
                  drawerItem(
                    icon: Icons.logout,
                    title: "Logout",
                    iconColor: Colors.redAccent,
                    titleColor: Colors.redAccent,
                    onTap: logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _currentIndex == 0 ? buildHomePage() : _pages[_currentIndex],
    );
  }
}
