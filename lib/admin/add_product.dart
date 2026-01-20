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
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
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
      products = List<Map<String, dynamic>>.from(data);

      // Sort alphabetically A → Z
      products.sort((a, b) {
        final nameA = (a["name"] ?? "").toString().toLowerCase();
        final nameB = (b["name"] ?? "").toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      setState(() {
        filteredProducts = List.from(products);
      });
    } catch (e) {
      _showMessage("Failed to fetch products: $e", isError: true);
    }
  }

  // ================= SEARCH FILTER =================
  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => filteredProducts = List.from(products));
      return;
    }

    final q = query.toLowerCase();
    setState(() {
      filteredProducts = products.where((p) {
        final name = (p["name"] ?? "").toString().toLowerCase();
        final detail = (p["detail"] ?? "").toString().toLowerCase();
        return name.contains(q) || detail.contains(q);
      }).toList();
    });
  }

  // ================= SAVE / UPDATE PRODUCT =================
  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "name": nameController.text,
      "detail": detailController.text,
    };

    try {
      Map<String, dynamic> response;

      if (editingIndex == null) {
        response = await ApiService.post("new_product", body);
        products.add(Map<String, dynamic>.from(response['data']));
      } else {
        final id = products[editingIndex!]["id"];
        response = await ApiService.post("update_product/$id", body);
        products[editingIndex!] = Map<String, dynamic>.from(response['data']);
      }

      // Sort after add/update
      products.sort((a, b) {
        final nameA = (a["name"] ?? "").toString().toLowerCase();
        final nameB = (b["name"] ?? "").toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      Navigator.pop(context);
      clearForm();
      _filterProducts(searchController.text); // Update filtered list
      _showMessage(response['message'] ?? "Success");
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
      products.removeAt(index);

      // Sort after deletion
      products.sort((a, b) {
        final nameA = (a["name"] ?? "").toString().toLowerCase();
        final nameB = (b["name"] ?? "").toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      _filterProducts(searchController.text);
      _showMessage("Product deleted successfully");
    } catch (e) {
      _showMessage("Failed to delete product: $e", isError: true);
    }
  }

  // ================= OPEN MODAL =================
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
                  color: Colors.blue,
                ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: saveProduct,
                  child: Text(
                    editingIndex == null ? "Add Product" : "Update Product",
                    style: const TextStyle(
                      color: Colors.white,
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

  // ================= MESSAGE =================
  void _showMessage(String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isError ? "Error" : "Success"),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ================= CONFIRM =================
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.grey,
      ),
      body: Column(
        children: [
          // ===== SEARCH BAR + FILTER ICON =====
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: implement filter modal if needed
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // ===== PRODUCTS LIST =====
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("No products found"))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                final name = p["name"] ?? "";
                final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => openProductForm(index: products.indexOf(p)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteProduct(products.indexOf(p)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
