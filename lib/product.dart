import 'package:flutter/material.dart';

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
    {"name": "Bread", "price": 120, "qty": 0, "image": "images/img_3.png"},
    {"name": "Cake", "price": 850, "qty": 0, "image": "images/img.png"},
    {"name": "Cookies", "price": 300, "qty": 0, "image": "images/img_1.png"},
    {"name": "Pastry", "price": 250, "qty": 0, "image": "images/img_2.png"},
    {"name": "Bread", "price": 120, "qty": 0, "image": "images/img_3.png"},
    {"name": "Cake", "price": 850, "qty": 0, "image": "images/img.png"},
    {"name": "Cookies", "price": 300, "qty": 0, "image": "images/img_1.png"},
    {"name": "Pastry", "price": 250, "qty": 0, "image": "images/img_2.png"},
  ];

  int get totalItems {
    return products.fold(0, (sum, item) => sum + item["qty"] as int);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Bakery Products",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      // Product list
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        children: [
          ...products.map((product) => _productCard(product)).toList(),
          const SizedBox(
              height: 100), // extra space so last product is not hidden
        ],
      ),
      // Fixed Total Items at bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1), // transparent background
            borderRadius: BorderRadius.circular(20), // rounded corners
            border: Border.all(
              color: Colors.deepPurple.shade200.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            "Total Items: $totalItems",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(product["image"]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  "Rs: ${product["price"]}/-",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _qtyButton(
                icon: Icons.remove,
                onTap: () {
                  setState(() {
                    if (product["qty"] > 0) product["qty"]--;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "${product["qty"]}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              _qtyButton(
                icon: Icons.add,
                onTap: () {
                  setState(() {
                    product["qty"]++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
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
