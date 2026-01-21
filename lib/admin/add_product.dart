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

  // ================= OPEN MODAL WITH LOADER =================
  void openProductForm({int? index}) {
    if (index != null) {
      editingIndex = index;
      nameController.text = products[index]["name"];
      detailController.text = products[index]["detail"];
    }

    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    editingIndex == null ? "Add New Product" : "Edit Product",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Product Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: detailController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: "Product Detail",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setModalState(() => isLoading = true);

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
                            final oldProduct = products[editingIndex!];
                            if (oldProduct["name"] == nameController.text &&
                                oldProduct["detail"] == detailController.text) {
                              Navigator.pop(context);
                              await Future.delayed(const Duration(seconds: 1));
                              _showMessage("No changes were made to the product.");
                              return;
                            }
                            final id = oldProduct["id"];
                            response = await ApiService.post("update_product/$id", body);
                            products[editingIndex!] =
                            Map<String, dynamic>.from(response['data']);
                          }

                          products.sort((a, b) {
                            final nameA = (a["name"] ?? "").toString().toLowerCase();
                            final nameB = (b["name"] ?? "").toString().toLowerCase();
                            return nameA.compareTo(nameB);
                          });

                          await Future.delayed(const Duration(seconds: 1));
                          Navigator.pop(context);
                          clearForm();
                          _filterProducts(searchController.text);
                          _showMessage(response['message'] ?? "Success");
                        } catch (e) {
                          _showMessage("Failed to save product: $e", isError: true);
                        } finally {
                          setModalState(() => isLoading = false);
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          key: const ValueKey("loading"),
                          children: const [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Please wait...",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                            : Text(
                          editingIndex == null ? "Add Product" : "Update Product",
                          key: const ValueKey("text"),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= DELETE PRODUCT WITH LOADER =================
  Future<void> deleteProduct(int index) async {
    bool isDeleting = false;
    final id = products[index]["id"];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue, width: 2),
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.delete_outline, size: 30, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                const Text("Delete Product",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 8),
                const Text("Are you sure you want to delete this product?",
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: isDeleting ? null : () => Navigator.pop(context, false),
                        child: const Text("Cancel", style: TextStyle(color: Colors.blue, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 4,
                        ),
                        onPressed: isDeleting
                            ? null
                            : () async {
                          setDialogState(() => isDeleting = true);
                          try {
                            await ApiService.delete("delete_product/$id");
                            Navigator.pop(context, true);
                          } catch (e) {
                            Navigator.pop(context, false);
                            _showMessage("Failed to delete product: $e", isError: true);
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isDeleting
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            key: const ValueKey("deleting"),
                            children: const [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Deleting...",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                              : const Text("Delete",
                              key: ValueKey("delete"),
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      products.removeAt(index);
      products.sort((a, b) {
        final nameA = (a["name"] ?? "").toString().toLowerCase();
        final nameB = (b["name"] ?? "").toString().toLowerCase();
        return nameA.compareTo(nameB);
      });
      _filterProducts(searchController.text);
      _showMessage("Product deleted successfully");
    }
  }

  // ================= BEAUTIFUL MESSAGE DIALOG =================
  void _showMessage(String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue, width: 2),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(
                  message.contains("No changes")
                      ? Icons.info_outline
                      : (isError ? Icons.error_outline : Icons.check_circle_outline),
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message.contains("No changes") ? "Notice" : (isError ? "Error" : "Success"),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manage Products"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.grey.shade400,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("No products found", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final p = filteredProducts[index];
                final name = p["name"] ?? "";
                final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        initial,
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(
                      p["detail"] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          clearForm();
          openProductForm();
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Product",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

    );
  }
}
