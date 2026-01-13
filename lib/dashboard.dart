import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'product.dart';
import 'profile.dart';
import 'login.dart';

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
  List<Map<String, dynamic>> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ================= LOAD USER DATA =================
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('selected_products');

    setState(() {
      userName = prefs.getString('name') ?? 'Admin';
      userEmail = prefs.getString('email') ?? '';
      selectedProducts = productsJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(productsJson))
          : [];
    });
  }

  // ================= CLEAR SELECTED PRODUCTS =================
  Future<void> clearAllSelectedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_products');
    setState(() => selectedProducts = []);
  }

  // ================= DELETE SINGLE PRODUCT =================
  Future<void> deleteProduct(int index) async {
    selectedProducts.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_products', jsonEncode(selectedProducts));
    setState(() {});
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
          (_) => false,
    );
  }

  // ================= IMAGE FALLBACK =================
  Widget _imageWidget(Map<String, dynamic> product) {
    final image = product["image"];
    if (image != null && image.toString().isNotEmpty) {
      return Image.network(
        image,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _firstChar(product["name"]),
      );
    }
    return _firstChar(product["name"]);
  }

  Widget _firstChar(String? name) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        (name != null && name.isNotEmpty) ? name[0].toUpperCase() : "?",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // ================= FORMAT CREATED_AT =================
  String formatCreatedAt(String createdAt) {
    try {
      DateTime dt = DateTime.parse(createdAt);
      return "${dt.day.toString().padLeft(2,'0')}/"
          "${dt.month.toString().padLeft(2,'0')}/"
          "${dt.year} "
          "${dt.hour.toString().padLeft(2,'0')}:"
          "${dt.minute.toString().padLeft(2,'0')}";
    } catch (e) {
      return createdAt;
    }
  }

  // ================= TOTAL PRICE =================
  double getTotalPrice() {
    return selectedProducts.fold(
      0,
          (sum, p) => sum + ((p['qty'] ?? 0) * (p['price'] ?? 0)),
    );
  }

  // ================= ADD OR UPDATE PRODUCT =================
  Future<void> addOrUpdateProduct(Map<String, dynamic> newProduct) async {
    bool exists = false;

    for (var product in selectedProducts) {
      if (product['product_id'] == newProduct['product_id']) {
        product['qty'] = newProduct['qty'];
        product['created_at'] = newProduct['created_at'];
        exists = true;
        break;
      }
    }

    if (!exists) {
      selectedProducts.add(newProduct);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_products', jsonEncode(selectedProducts));

    setState(() {});
  }

  // ================= HOME PAGE =================
  Widget buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Selected Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (selectedProducts.isNotEmpty)
                TextButton.icon(
                  onPressed: clearAllSelectedProducts,
                  icon: const Icon(Icons.clear_all, color: Colors.red),
                  label: const Text("Clear All",
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
          const SizedBox(height: 16),
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
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _imageWidget(product),
                          ),
                          const SizedBox(width: 12),
                          // Name + CreatedAt
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product["name"] ?? "Unknown",
                                  style:
                                  const TextStyle(fontSize: 16),
                                ),
                                if (product["created_at"] != null)
                                  Text(
                                    "Created at: ${formatCreatedAt(product["created_at"])}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                          // Qty + Delete Button
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.lightBlueAccent
                                      .withOpacity(0.3),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Qty: ${product["qty"] ?? 0}",
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 4),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    deleteProduct(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Total price card
              Card(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rs: ${getTotalPrice().toStringAsFixed(2)}/-",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
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

  Widget buildUsersPage() =>
      const Center(child: Text("Users Page", style: TextStyle(fontSize: 22)));

  Widget buildProfilePage() => const ProfileScreen();

  // ================= MAIN =================
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
      // ================= APPBAR WITH SHADOW =================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4), // Shadow below AppBar
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0, // Remove default shadow
            title: const Text("Dashboard",
                style: TextStyle(color: Colors.black)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  },
                  child:
                  const CircleAvatar(radius: 20, child: Icon(Icons.person)),
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
              currentAccountPicture:
              const CircleAvatar(child: Icon(Icons.person)),
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
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Products"),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BakerProductPage()),
                );
                if (result != null && result is Map<String, dynamic>) {
                  await addOrUpdateProduct(result);
                }
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
            )
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
            onTap: (index) async {
              if (index == 1) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BakerProductPage()),
                );
                if (result != null && result is Map<String, dynamic>) {
                  await addOrUpdateProduct(result);
                }
              } else if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else {
                setState(() {
                  _selectedBottomIndex = index;
                  if (index == 0) _currentIndex = 0;
                  if (index == 2) _currentIndex = 1;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 28), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart, size: 28), label: "Items"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.supervised_user_circle, size: 28),
                  label: "Users"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 28), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
