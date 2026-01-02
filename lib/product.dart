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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: [
          // Total items counter
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50, // background color
              borderRadius: BorderRadius.circular(12), // round corners
              border: Border.all(
                color: Colors.deepPurple.shade200, // optional border color
                width: 2, // optional border width
              ),
            ),
            child: Text(
              "Total Items: $totalItems",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),
          // Product list
          ...products.map((product) => _productCard(product)).toList(),
        ],
      ),
    );
  }

  Widget _productCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(product["image"]),
          ),
          const SizedBox(width: 16),
          // Product name & price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rs: ${product["price"]}/-",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
          // Quantity buttons
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
