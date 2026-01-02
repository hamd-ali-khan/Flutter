import 'package:flutter/material.dart';

class BakerProductPage extends StatefulWidget {
  const BakerProductPage({super.key});

  @override
  State<BakerProductPage> createState() => _BakerProductPageState();
}

class _BakerProductPageState extends State<BakerProductPage> {
  final List<Map<String, dynamic>> products = [
    {"name": "Bread", "price": 120, "qty": 0},
    {"name": "Cake", "price": 850, "qty": 0},
    {"name": "Cookies", "price": 300, "qty": 0},
    {"name": "Pastry", "price": 250, "qty": 0},
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
        title: const Text(
          "Bakery Products",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: Column(
        children: [
          // Total items counter
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.blueAccent.withOpacity(0.1),
            child: Text(
              "Total Items: $totalItems",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Product list
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _productCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(int index) {
    final product = products[index];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Product info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rs ${product["price"]}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            // Quantity controller
            Row(
              children: [
                _qtyButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (product["qty"] > 0) {
                      setState(() {
                        product["qty"]--;
                      });
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    product["qty"].toString(),
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
            )
          ],
        ),
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
