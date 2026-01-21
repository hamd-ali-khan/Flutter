import 'package:flutter/material.dart';
import 'package:my_app/apis/api_services.dart';

class AdminBranchPage extends StatefulWidget {
  const AdminBranchPage({super.key});

  @override
  State<AdminBranchPage> createState() => _AdminBranchPageState();
}

class _AdminBranchPageState extends State<AdminBranchPage> {
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> filteredBranches = [];
  bool isLoading = true;
  bool isAddingBranch = false;

  final TextEditingController branchSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBranches();
    branchSearchController.addListener(_filterBranches);
  }

  @override
  void dispose() {
    branchSearchController.dispose();
    super.dispose();
  }

  // ================= FETCH BRANCHES =================
  Future<void> fetchBranches() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.get("branches");
      if (response is List) {
        branches = List<Map<String, dynamic>>.from(response);
      } else if (response is Map && response.containsKey('data')) {
        branches = List<Map<String, dynamic>>.from(response['data']);
      }

      // Sort alphabetically by branch_name
      branches.sort((a, b) {
        final nameA = (a['branch_name'] ?? "").toString().toLowerCase();
        final nameB = (b['branch_name'] ?? "").toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      filteredBranches = List<Map<String, dynamic>>.from(branches);
    } catch (e) {
      debugPrint("Error fetching branches: $e");
      branches = [];
      filteredBranches = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= SEARCH FILTER =================
  void _filterBranches() {
    final query = branchSearchController.text.toLowerCase();
    setState(() {
      filteredBranches = branches
          .where((branch) =>
          (branch['branch_name'] ?? "").toLowerCase().contains(query))
          .toList();
    });
  }

  // ================= ADD NEW BRANCH =================
  Future<void> addNewBranch(String branchName) async {
    setState(() => isAddingBranch = true);
    try {
      final response = await ApiService.post(
        "new_branch",
        {"branch_name": branchName},
      );

      if (response['status'] == true) {
        await fetchBranches();
        _showMessage("Branch added successfully");
      } else {
        _showMessage("Failed to add branch", isError: true);
      }
    } catch (e) {
      debugPrint("Error adding branch: $e");
      _showMessage("Something went wrong", isError: true);
    } finally {
      setState(() => isAddingBranch = false);
    }
  }

  // ================= DELETE BRANCH =================
  Future<bool?> showDeleteDialog(int branchId) async {
    bool isDeleting = false;

    return showDialog<bool>(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setDialogState) =>
                Dialog(
                  shape:
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2)
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child:
                          const Icon(Icons.delete_outline, size: 30,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Delete Branch",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Are you sure you want to delete this branch?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                ),
                                onPressed:
                                isDeleting ? null : () =>
                                    Navigator.pop(context, false),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  elevation: 4,
                                ),
                                onPressed: isDeleting
                                    ? null
                                    : () async {
                                  setDialogState(() => isDeleting = true);
                                  try {
                                    await ApiService.delete(
                                        "delete_branch/$branchId");
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    Navigator.pop(context, false);
                                    _showMessage(
                                        "Failed to delete branch: $e",
                                        isError: true);
                                  }
                                },
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: isDeleting
                                      ? Row(
                                    key: const ValueKey("deleting"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Deleting...",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  )
                                      : const Text(
                                    "Delete",
                                    key: ValueKey("delete"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Future<void> deleteBranch(int index) async {
    final int branchId = filteredBranches[index]['id'];
    final confirmed = await showDeleteDialog(branchId);

    if (confirmed == true) {
      branches.removeWhere((b) => b['id'] == branchId);
      _filterBranches();
      _showMessage("Branch deleted successfully");
    }
  }

  // ================= BEAUTIFUL MESSAGE DIALOG =================
  void _showMessage(String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) =>
          Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Icon(
                      isError ? Icons.error_outline : Icons
                          .check_circle_outline,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isError ? "Error" : "Success",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // ================= ADD BRANCH DIALOG =================
  void showAddBranchDialog() {
    final TextEditingController branchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setDialogState) =>
                Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.85,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Add New Branch",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: branchController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: "Branch Name",
                              labelStyle: const TextStyle(color: Colors.blue),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final name = branchController.text.trim();
                                    if (name.isEmpty) return;
                                    Navigator.pop(context);
                                    addNewBranch(name);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12)),
                                    elevation: 4,
                                  ),
                                  child: const Text(
                                    "Add Branch",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  // ================= UI =================
  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Branches"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: branchSearchController,
              decoration: InputDecoration(
                hintText: "Search Branch...",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          // Branch list
          Expanded(
            child: filteredBranches.isEmpty
                ? const Center(child: Text("No branches found"))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: filteredBranches.length,
              itemBuilder: (context, index) {
                final branch = filteredBranches[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.business, color: Colors.blue),
                    ),
                    title: Text(
                      branch['branch_name'] ?? "Branch",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {}),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteBranch(index)),
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
        onPressed: isAddingBranch ? null : showAddBranchDialog,
        icon: isAddingBranch
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
        )
            : const Icon(Icons.add, color: Colors.white),
        label: Text(
          isAddingBranch ? "Adding..." : "Add Branch",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
