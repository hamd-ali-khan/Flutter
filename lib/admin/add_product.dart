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
      _showMessage("Failed to fetch products: $e", isError: true);
    }
  }

  // ================= SAVE / UPDATE PRODUCT =================
  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {"name": nameController.text, "detail": detailController.text};

    try {
      Map<String, dynamic> response;

      if (editingIndex == null) {
        // ADD NEW PRODUCT
        response = await ApiService.post("new_product", body);

        setState(() {
          products.add(Map<String, dynamic>.from(response['data']));
        });

        Navigator.pop(context);
        clearForm();

        _showMessage(response['message'] ?? "Product added successfully");
      } else {
        // UPDATE EXISTING PRODUCT
        final id = products[editingIndex!]["id"];
        response = await ApiService.post("update_product/$id", body);

        setState(() {
          products[editingIndex!] = Map<String, dynamic>.from(response['data']);
        });

        Navigator.pop(context);
        clearForm();

        _showMessage(response['message'] ?? "Product updated successfully");
      }
    } catch (e) {
      _showMessage("Failed to save product: $e", isError: true);
    }
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(int index) async {
    final confirm = await _showConfirmationDialog(
      title: "Delete Product",
      message: "Are you sure you want to delete this product?",
    );

    if (!confirm) return;

    try {
      final id = products[index]["id"];
      await ApiService.delete("delete_product/$id");

      setState(() {
        products.removeAt(index);
      });

      _showMessage("Product deleted successfully");
    } catch (e) {
      _showMessage("Failed to delete product: $e", isError: true);
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
      builder: (context) => Padding(
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Title color
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: detailController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Product Detail",
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue background
                    foregroundColor: Colors.white, // White text
                  ),
                  onPressed: saveProduct,
                  child: Text(
                    editingIndex == null ? "Add Product" : "Update Product",
                    style: const TextStyle(
                      color: Colors.white, // White text
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MESSAGE MODAL =================
  void _showMessage(String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: isError ? const Text("Error") : const Text("Success"),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Blue button
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= CONFIRMATION MODAL =================
  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Blue button
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Products"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        // Stronger shadow
        shadowColor: Colors.grey,
        // Grey shadow
        titleTextStyle: const TextStyle(
          color: Colors.white, // Title color
          fontSize: 20, // Font size 20
          fontWeight: FontWeight.bold, // Bold font
        ),
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final String name = p["name"] ?? "";
                final String initial = name.isNotEmpty
                    ? name[0].toUpperCase()
                    : "?";

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
