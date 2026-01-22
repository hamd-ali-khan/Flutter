import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'apis/api_services.dart';

class BakerProductPage extends StatefulWidget {
  const BakerProductPage({super.key});

  @override
  State<BakerProductPage> createState() => _BakerProductPageState();
}

class _BakerProductPageState extends State<BakerProductPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      setState(() => isLoading = true);

      final response = await ApiService.get("products");

      List data = [];
      if (response is Map && response.containsKey('data')) {
        data = response['data'];
      } else if (response is List) {
        data = response;
      }

      setState(() {
        products = data.map<Map<String, dynamic>>((item) {
          return {
            "id": item["id"],
            "name": item["name"] ?? "",
            "detail": item["detail"] ?? "",
            "image": item["image"] ?? "",
            "unit_price": item["price"] ?? 0, // kept for backend
            "qty": 0,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load products")));
    }
  }

  // ================= TOTAL QTY =================
  int get totalItems =>
      products.fold(0, (sum, item) => sum + ((item["qty"] ?? 0) as int));

  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  // ================= SAVE PRODUCTS =================
  Future<void> _save() async {
    if (totalItems == 0) return;

    _showLoader();

    final now = DateTime.now().toIso8601String();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final existingJson = prefs.getString('selected_products');
    List<Map<String, dynamic>> existingProducts = existingJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(existingJson))
        : [];

    List<Map<String, dynamic>> newProducts = products
        .where((p) => (p["qty"] ?? 0) > 0)
        .map(
          (p) => {
            "product_id": p["id"],
            "name": p["name"],
            "qty": p["qty"],
            "unit_price": p["unit_price"],
            "image": p["image"],
            "created_at": now,
          },
        )
        .toList();

    for (var newP in newProducts) {
      bool exists = false;
      for (var existP in existingProducts) {
        if (existP['product_id'] == newP['product_id']) {
          existP['qty'] = (existP['qty'] ?? 0) + (newP['qty'] ?? 0);
          existP['created_at'] = now;
          exists = true;
          break;
        }
      }
      if (!exists) {
        existingProducts.add(newP);
      }
    }

    await prefs.setString('selected_products', jsonEncode(existingProducts));

    await prefs.setInt(
      'total_products_qty',
      existingProducts.fold<int>(0, (sum, p) => sum + ((p['qty'] ?? 0) as int)),
    );

    for (var p in products) {
      p["qty"] = 0;
    }

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Dashboard()),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Bakery Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchProducts,
              child: products.isEmpty
                  ? const Center(child: Text("No products found"))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      itemCount: products.length,
                      itemBuilder: (context, index) =>
                          _productCard(products[index]),
                    ),
            ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ================= BOTTOM BAR =================
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$totalItems items selected",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: totalItems == 0 ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT CARD =================
  Widget _productCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                (product["image"] != null &&
                    product["image"].toString().isNotEmpty)
                ? Image.network(
                    product["image"],
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                  )
                : CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    child: Text(
                      product["name"].isNotEmpty
                          ? product["name"][0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product["detail"] ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          _quantitySelector(product),
        ],
      ),
    );
  }

  // ================= QTY SELECTOR =================
  Widget _quantitySelector(Map<String, dynamic> product) {
    return Row(
      children: [
        _qtyButton(
          icon: Icons.remove,
          enabled: (product["qty"] ?? 0) > 0,
          onTap: () {
            setState(() {
              if ((product["qty"] ?? 0) > 0) {
                product["qty"] = product["qty"] - 1;
              }
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "${product["qty"] ?? 0}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        _qtyButton(
          icon: Icons.add,
          enabled: true,
          onTap: () {
            setState(() {
              product["qty"] = (product["qty"] ?? 0) + 1;
            });
          },
        ),
      ],
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
