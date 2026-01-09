import 'dart:convert';
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
  int _currentIndex = 0;
  int _selectedBottomIndex = 0;
  String userName = '';
  String userEmail = '';
  int totalProductsQty = 0;
  List<Map<String, dynamic>> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Admin';
      userEmail = prefs.getString('email') ?? '';
      totalProductsQty = prefs.getInt('total_products_qty') ?? 0;

      String? productsJson = prefs.getString('selected_products');
      if (productsJson != null && productsJson.isNotEmpty) {
        selectedProducts = List<Map<String, dynamic>>.from(jsonDecode(productsJson));
      } else {
        selectedProducts = [];
      }
    });
  }

  Future<void> removeProduct(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      totalProductsQty -= selectedProducts[index]["qty"] as int;
      selectedProducts.removeAt(index);
    });

    await prefs.setString(
      'selected_products',
      jsonEncode(selectedProducts),
    );

    await prefs.setInt(
      'total_products_qty',
      totalProductsQty,
    );
  }


  Future<void> clearAllSelectedProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_products');
    await prefs.remove('total_products_qty');
    setState(() {
      selectedProducts = [];
      totalProductsQty = 0;
    });
  }

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

  double getTotalPrice() {
    double total = 0;
    for (var product in selectedProducts) {
      total += (product["qty"] * product["price"]);
    }
    return total;
  }

  // ================= HOME PAGE =================
  Widget buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= Selected Products Section =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (selectedProducts.isNotEmpty)
                TextButton.icon(
                  onPressed: clearAllSelectedProducts,
                  icon: const Icon(Icons.clear_all, color: Colors.red),
                  label: const Text("Clear All", style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ================= Selected Products List =================
          selectedProducts.isEmpty
              ? const Text(
            "No products selected",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          )
              : Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = selectedProducts[index];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              product["image"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name & Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product name at top
                                Text(
                                  product["name"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Created/Updated date
                                if (product["addedAt"] != null)
                                  Text(
                                    "Created at: ${product["addedAt"]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                // Bottom row with quantity and delete button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Quantity at bottom left
                                    Text(
                                      "Qty: ${product["qty"]}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    // Delete button at bottom right
                                    InkWell(
                                      onTap: () => removeProduct(index),
                                      borderRadius: BorderRadius.circular(20),
                                      child: const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
              Card(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        "Rs: ${getTotalPrice().toStringAsFixed(2)}/-",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildUsersPage() => const Center(child: Text("Users Page", style: TextStyle(fontSize: 22)));
  Widget buildProfilePage() => const ProfileScreen();

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
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  },
                  child: const CircleAvatar(radius: 20, child: Icon(Icons.person)),
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
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const BakerProductPage()))
                    .then((_) => loadUserData());
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
                color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))
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
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const BakerProductPage()))
                    .then((_) => loadUserData());
              } else if (index == 3) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()));
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
