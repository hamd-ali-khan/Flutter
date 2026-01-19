import 'package:flutter/material.dart';
import '../apis/api_services.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  int? selectedRoleId;
  int? selectedBranchId;

  bool _isLoading = false;
  bool _isFetching = true;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> roles = [];
  List<Map<String, dynamic>> branches = [];

  @override
  void initState() {
    super.initState();
    _fetchRoles();
    _fetchBranches();
    _fetchUsers();
  }

  // ================= FETCH USERS =================
  Future<void> _fetchUsers() async {
    setState(() => _isFetching = true);
    try {
      final data = await ApiService.get("users");
      if (data is List) users = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      _showSnackBar("Failed to fetch users: $e");
    } finally {
      setState(() => _isFetching = false);
    }
  }

  // ================= FETCH ROLES =================
  Future<void> _fetchRoles() async {
    try {
      final data = await ApiService.get("roles");
      if (data is List) {
        setState(() {
          roles = List<Map<String, dynamic>>.from(data);
          if (roles.isNotEmpty) selectedRoleId = int.parse(roles.first["id"].toString());
        });
      }
    } catch (e) {
      _showSnackBar("Failed to fetch roles: $e");
    }
  }

  // ================= FETCH BRANCHES =================
  Future<void> _fetchBranches() async {
    try {
      final data = await ApiService.get("branches");
      if (data is List) {
        setState(() {
          branches = List<Map<String, dynamic>>.from(data);
          if (branches.isNotEmpty) selectedBranchId = int.parse(branches.first["id"].toString());
        });
      }
    } catch (e) {
      _showSnackBar("Failed to fetch branches: $e");
    }
  }

  // ================= CREATE USER =================
  Future<void> _createUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty || selectedRoleId == null || selectedBranchId == null) {
      _showSnackBar("All fields are required");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.post("new_user", {
        "name": name,
        "email": email,
        "password": password,
        "role_id": selectedRoleId,
        "branch_id": selectedBranchId,
      });
      Navigator.pop(context);
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      await _fetchUsers();
      _showSnackBar("User created successfully", isError: false);
    } catch (e) {
      _showSnackBar("Failed to create user: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= UPDATE USER =================
  Future<void> _updateUser(int userId) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      _showSnackBar("Name & Email required");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.post("users/$userId", {
        "name": name,
        "email": email,
        "role_id": selectedRoleId,
        "branch_id": selectedBranchId,
      });
      Navigator.pop(context);
      await _fetchUsers();
      _showSnackBar("User updated successfully", isError: false);
    } catch (e) {
      _showSnackBar("Update failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= SOFT DELETE USER =================
  void _softDeleteUser(int userId) {
    setState(() {
      users.removeWhere((u) => u["id"] == userId);
    });
    _showSnackBar("User removed from app (not deleted from database)", isError: false);
  }

  // ================= DELETE CONFIRMATION =================
  void _confirmDeleteUser(int userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove User"),
        content: const Text("This will remove the user from the app, but keep them in the database. Proceed?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _softDeleteUser(userId);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)), // white text
          ),
        ],
      ),
    );
  }

  // ================= CREATE USER MODAL =================
  void _openCreateUserModal() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    if (roles.isNotEmpty) selectedRoleId = int.parse(roles.first["id"].toString());
    if (branches.isNotEmpty) selectedBranchId = int.parse(branches.first["id"].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Create User", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 20),
              _inputField(nameController, "Name"),
              _inputField(emailController, "Email"),
              _inputField(passwordController, "Password", obscure: true),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedRoleId,
                items: roles.map((r) => DropdownMenuItem(
                    value: int.parse(r["id"].toString()), child: Text(r["title"].toString()))).toList(),
                onChanged: (v) => setState(() => selectedRoleId = v),
                decoration: _inputDecoration("Role"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedBranchId,
                items: branches.map((b) => DropdownMenuItem(
                    value: int.parse(b["id"].toString()), child: Text(b["branch_name"].toString()))).toList(),
                onChanged: (v) => setState(() => selectedBranchId = v),
                decoration: _inputDecoration("Branch"),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _createUser,
                    child: Text(_isLoading ? "Creating..." : "Create User",
                        style: const TextStyle(fontSize: 16, color: Colors.white)), // white text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EDIT USER MODAL =================
  void _openEditUserModal(Map<String, dynamic> user) {
    nameController.text = user["name"] ?? "";
    emailController.text = user["email"] ?? "";
    passwordController.clear();
    selectedRoleId = int.parse(user["role_id"].toString());
    selectedBranchId = int.parse(user["branch_id"].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Edit User", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 20),
              _inputField(nameController, "Name"),
              _inputField(emailController, "Email"),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedRoleId,
                items: roles.map((r) => DropdownMenuItem(
                    value: int.parse(r["id"].toString()), child: Text(r["title"].toString()))).toList(),
                onChanged: (v) => setState(() => selectedRoleId = v),
                decoration: _inputDecoration("Role"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedBranchId,
                items: branches.map((b) => DropdownMenuItem(
                    value: int.parse(b["id"].toString()), child: Text(b["branch_name"].toString()))).toList(),
                onChanged: (v) => setState(() => selectedBranchId = v),
                decoration: _inputDecoration("Branch"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : () => _updateUser(user["id"]),
                  child: Text(_isLoading ? "Updating..." : "Update User",
                      style: const TextStyle(fontSize: 16, color: Colors.white)), // white text
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
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white), // white back arrow
      ),
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text("No users found"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text(u["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${u["email"] ?? ""} | ${u["role"]?["title"] ?? ""} | ${u["branch"]?["branch_name"] ?? ""}"),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.blue),
                onSelected: (value) {
                  if (value == "edit") _openEditUserModal(u);
                  if (value == "delete") _confirmDeleteUser(u["id"]); // soft delete
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white, // white icon
        onPressed: _openCreateUserModal,
        child: const Icon(Icons.add),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
}
