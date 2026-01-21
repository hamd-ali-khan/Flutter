import 'package:flutter/material.dart';
import '../apis/api_services.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // For date formatting

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  int? selectedRoleId;
  int? selectedBranchId;

  bool _isLoading = false;
  bool _isDeleting = false;
  bool _isFetching = true;
  bool _obscurePassword = true;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> roles = [];
  List<Map<String, dynamic>> branches = [];

  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
    _fetchBranches();
    _fetchUsers();
  }

  // ================= CAPITALIZE HELPER =================
  String capitalize(String value) {
    if (value.isEmpty) return '';
    value = value.trim();
    return value[0].toUpperCase() + value.substring(1);
  }

  // ================= FORMAT DATE =================
  String formatDateTime(String dateTime) {
    try {
      final dtUtc = DateTime.parse(dateTime).toUtc();
      final dtLocal = dtUtc.toLocal();
      return DateFormat('MMM dd, yyyy hh:mm a').format(dtLocal);
    } catch (_) {
      return dateTime;
    }
  }

  // ================= SEARCH FILTER =================
  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => filteredUsers = List.from(users));
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      filteredUsers = users.where((u) {
        final name = (u["name"] ?? "").toString().toLowerCase();
        final email = (u["email"] ?? "").toString().toLowerCase();
        final role = (u["role"]?["title"] ?? "").toString().toLowerCase();
        final branch =
        (u["branch"]?["branch_name"] ?? "").toString().toLowerCase();
        return name.contains(q) ||
            email.contains(q) ||
            role.contains(q) ||
            branch.contains(q);
      }).toList();
    });
  }

  // ================= FETCH USERS =================
  Future<void> _fetchUsers() async {
    setState(() => _isFetching = true);
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final response = await ApiService.get("users");
      List data = [];
      if (response is Map && response.containsKey("data")) data = response["data"];
      else if (response is List) data = response;

      users = List<Map<String, dynamic>>.from(data);
      users.sort((a, b) =>
          ((a["name"] ?? "").toString().toLowerCase())
              .compareTo(((b["name"] ?? "").toString().toLowerCase())));
      setState(() => filteredUsers = List.from(users));
    } catch (e) {
      _showSnackBar("Unable to fetch users. Please try again.", isError: true);
    } finally {
      setState(() => _isFetching = false);
    }
  }

  // ================= FETCH ROLES =================
  Future<void> _fetchRoles() async {
    try {
      final response = await ApiService.get("roles");
      List data = [];
      if (response is Map && response.containsKey("data")) data = response["data"];
      else if (response is List) data = response;

      setState(() {
        roles = List<Map<String, dynamic>>.from(data);
        if (roles.isNotEmpty) selectedRoleId = int.parse(roles.first["id"].toString());
      });
    } catch (_) {
      _showSnackBar("Unable to fetch roles.", isError: true);
    }
  }

  // ================= FETCH BRANCHES =================
  Future<void> _fetchBranches() async {
    try {
      final response = await ApiService.get("branches");
      List data = [];
      if (response is Map && response.containsKey("data")) data = response["data"];
      else if (response is List) data = response;

      setState(() {
        branches = List<Map<String, dynamic>>.from(data);
        if (branches.isNotEmpty)
          selectedBranchId = int.parse(branches.first["id"].toString());
      });
    } catch (_) {
      _showSnackBar("Unable to fetch branches.", isError: true);
    }
  }

  // ================= SAVE/UPDATE USER =================
  Future<void> _saveUser() async {
    final name = capitalize(nameController.text.trim()); // <-- Capitalized
    final email = (emailController.text.trim() + "@gmail.com").toLowerCase();
    final password = passwordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        selectedRoleId == null ||
        selectedBranchId == null ||
        (editingIndex == null && password.isEmpty)) {
      _showSnackBar("Please fill all required fields.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      "name": name,
      "email": email,
      "role_id": selectedRoleId,
      "branch_id": selectedBranchId,
      if (editingIndex == null) "password": password,
    };

    try {
      Map<String, dynamic> response;
      await Future.delayed(const Duration(milliseconds: 300));

      if (editingIndex == null) {
        response = await ApiService.post("new_user", body);
        users.add(Map<String, dynamic>.from(response["data"]));
      } else {
        final id = users[editingIndex!]["id"];
        response = await ApiService.post("update_user/$id", body);
        users[editingIndex!] = Map<String, dynamic>.from(response["data"]);
      }

      users.sort((a, b) =>
          ((a["name"] ?? "").toString().toLowerCase())
              .compareTo(((b["name"] ?? "").toString().toLowerCase())));

      _filterUsers(searchController.text);
      Navigator.pop(context);
      clearForm();
      await _fetchUsers();

      _showSnackBar(
          response["message"] ?? "User saved successfully.", isError: false);
    } catch (_) {
      _showSnackBar("Failed to save user. Please try again.", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= DELETE USER =================
  Future<void> _softDeleteUser(int index) async {
    final id = users[index]["id"];
    setState(() => _isDeleting = true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      await ApiService.delete("delete_user/$id");
      users.removeAt(index);
      _filterUsers(searchController.text);
      await _fetchUsers();
      _showSnackBar("User has been removed successfully.", isError: false);
    } catch (_) {
      _showSnackBar("Failed to remove user. Please try again.", isError: true);
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  void _confirmDeleteUser(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to permanently remove this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: _isDeleting
                ? null
                : () async {
              Navigator.pop(ctx);
              await _softDeleteUser(index);
            },
            child: _isDeleting
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================= OPEN MODAL =================
  void _openUserModal({int? index}) {
    if (index != null) {
      editingIndex = index;
      final u = users[index];
      nameController.text = u["name"] ?? "";
      emailController.text = u["email"]?.toString().replaceAll("@gmail.com", "") ?? "";
      passwordController.clear();
      selectedRoleId = int.parse(u["role_id"].toString());
      selectedBranchId = int.parse(u["branch_id"].toString());
    } else {
      clearForm();
      if (roles.isNotEmpty) selectedRoleId = int.parse(roles.first["id"].toString());
      if (branches.isNotEmpty) selectedBranchId = int.parse(branches.first["id"].toString());
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  editingIndex == null ? "Add New User" : "Update User Info",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                _inputField(nameController, "Full Name"),
                _emailField(),
                _passwordField(setModalState),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedRoleId,
                  items: roles
                      .map((r) => DropdownMenuItem(
                    value: int.parse(r["id"].toString()),
                    child: Text(r["title"].toString()),
                  ))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedRoleId = v),
                  decoration: _inputDecoration("Role"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedBranchId,
                  items: branches
                      .map((b) => DropdownMenuItem(
                    value: int.parse(b["id"].toString()),
                    child: Text(b["branch_name"].toString()),
                  ))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedBranchId = v),
                  decoration: _inputDecoration("Branch"),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                      setModalState(() => _isLoading = true);
                      await _saveUser();
                      setModalState(() => _isLoading = false);
                    },
                    child: _isLoading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Please Wait...",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(width: 12),
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      ],
                    )
                        : Text(
                      editingIndex == null ? "Create User" : "Update User",
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= INPUT FIELDS =================
  Widget _passwordField(StateSetter setModalState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: "Password",
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setModalState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: "Email",
          suffixText: "@gmail.com",
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(12)),
    );
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    editingIndex = null;
    _obscurePassword = true;
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("User Management"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 8, // Height of shadow
        shadowColor: Colors.black54, // Shadow color
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: "Search users by name, email, role or branch",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isFetching
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                ? const Center(
              child: Text(
                "No users found. Add new users to get started.",
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filteredUsers.length,
              itemBuilder: (_, i) {
                final u = filteredUsers[i];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(u["name"] ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u["email"] ?? "", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 6),
                        if (u["created_at"] != null)
                          Text("Joined: ${formatDateTime(u["created_at"])}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (u["role"]?["title"] != null && u["role"]?["title"] != "")
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  u["role"]?["title"] ?? "",
                                  style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(width: 8),
                            if (u["branch"]?["branch_name"] != null && u["branch"]?["branch_name"] != "")
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  u["branch"]?["branch_name"] ?? "",
                                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.blue),
                      onSelected: (value) {
                        if (value == "edit") _openUserModal(index: i);
                        if (value == "delete") _confirmDeleteUser(i);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: "edit", child: Text("Edit")),
                        PopupMenuItem(value: "delete", child: Text("Delete")),
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
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add User",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _openUserModal(),
      ),
    );
  }
}
