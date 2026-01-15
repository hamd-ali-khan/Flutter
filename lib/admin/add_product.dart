import 'package:flutter/material.dart';
import 'package:my_app/apis/api_services.dart';

class AdminAddProductPage extends StatefulWidget {
  const AdminAddProductPage({super.key});

  @override
  State<AdminAddProductPage> createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void clearForm() {
    nameController.clear();
    detailController.clear();
    editingIndex = null;
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      final data = await ApiService.get("products");
      setState(() {
        products = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to fetch products: $e")));
    }
  }

  // ================= SAVE / UPDATE PRODUCT =================
  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "name": nameController.text,
      "detail": detailController.text,
    };

    try {
      if (editingIndex == null) {
        // CREATE NEW
        final newProduct = await ApiService.post("products", body);
        setState(() {
          products.add(Map<String, dynamic>.from(newProduct));
        });
      } else {
        // UPDATE EXISTING
        final id = products[editingIndex!]["id"];
        final updatedProduct = await ApiService.put("products/$id", body);
        setState(() {
          products[editingIndex!] = Map<String, dynamic>.from(updatedProduct);
        });
      }

      Navigator.pop(context);
      clearForm();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product saved successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to save product: $e")));
    }
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(int index) async {
    try {
      final id = products[index]["id"];
      await ApiService.delete("products/$id");
      setState(() {
        products.removeAt(index);
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Product deleted")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to delete product: $e")));
    }
  }

  // ================= OPEN MODAL FORM =================
  void openProductForm({int? index}) {
    if (index != null) {
      editingIndex = index;
      nameController.text = products[index]["name"];
      detailController.text = products[index]["detail"];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editingIndex == null ? "Add New Product" : "Edit Product",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: detailController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Product Detail",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: saveProduct,
                    child: Text(editingIndex == null ? "Add Product" : "Update Product"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Products"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: products.isEmpty
          ? const Center(
        child: Text(
          "No products added yet.\nTap + to add product",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          final String name = p["name"] ?? "";
          final String initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: Text(name),
              subtitle: Text(
                p["detail"] ?? "",
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => openProductForm(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteProduct(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          clearForm();
          openProductForm();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
