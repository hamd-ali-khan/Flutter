import 'package:flutter/material.dart';
import 'package:my_app/dashboard.dart';

class BakerProductPage extends StatefulWidget {
  const BakerProductPage({super.key});

  @override
  State<BakerProductPage> createState() => _BakerProductPageState();
}

class _BakerProductPageState extends State<BakerProductPage> {
  final List<Map<String, dynamic>> products = [
    {"name": "Bread", "price": 120, "qty": 0, "image": "images/img_3.png"},
    {"name": "Cake", "price": 850, "qty": 0, "image": "images/img.png"},
    {"name": "Cookies", "price": 300, "qty": 0, "image": "images/img_1.png"},
    {"name": "Pastry", "price": 250, "qty": 0, "image": "images/img_2.png"},
    {"name": "Bread", "price": 120, "qty": 0, "image": "images/img_3.png"},
    {"name": "Cake", "price": 850, "qty": 0, "image": "images/img.png"},
    {"name": "Cookies", "price": 300, "qty": 0, "image": "images/img_1.png"},
    {"name": "Pastry", "price": 250, "qty": 0, "image": "images/img_2.png"},
    {"name": "Pastry", "price": 250, "qty": 0, "image": "images/img_2.png"},
  ];

  int get totalItems =>
      products.fold<int>(0, (sum, item) => sum + item["qty"] as int);

  int get totalPrice => products.fold<int>(
    0,
        (sum, item) => sum + (item["qty"] * item["price"]) as int,
  );

  // ================= LOADER =================
  void _showLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // ================= SAVE ACTION =================
  void _save() async {
    if (totalItems == 0) return;

    _showLoader();

    await Future.delayed(const Duration(seconds: 2)); // simulate save

    // reset quantities
    setState(() {
      for (var product in products) {
        product["qty"] = 0;
      }
    });

    Navigator.pop(context); // close loader

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Dashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text("Bakery Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),

      // ================= PRODUCT LIST =================
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _productCard(products[index]);
        },
      ),

      // ================= BOTTOM BAR =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$totalItems items selected",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs: $totalPrice/-",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: totalItems == 0 ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,                 // enabled
                // shadow when disabled
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
            )

          ],
        ),
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product["image"],
              height: 64,
              width: 64,
              fit: BoxFit.cover,
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
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "Rs: ${product["price"]}/-",
                  style: const TextStyle(color: Colors.black54),
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
          enabled: product["qty"] > 0,
          onTap: () => setState(() => product["qty"]--),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "${product["qty"]}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        _qtyButton(
          icon: Icons.add,
          enabled: true,
          onTap: () => setState(() => product["qty"]++),
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
