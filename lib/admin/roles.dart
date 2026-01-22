import 'package:flutter/material.dart';
import 'package:my_app/apis/api_services.dart';
import 'package:intl/intl.dart'; // For date formatting

class AdminRolesPage extends StatefulWidget {
  const AdminRolesPage({super.key});

  @override
  State<AdminRolesPage> createState() => _AdminRolesPageState();
}

class _AdminRolesPageState extends State<AdminRolesPage> {
  final TextEditingController roleController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> roles = [];
  List<Map<String, dynamic>> filteredRoles = [];

  bool _isFetching = true;
  bool _isSaving = false;
  bool showDeleted = false;

  int? editingRoleId;

  @override
  void initState() {
    super.initState();
    fetchRoles();
    searchController.addListener(_filterRoles);
  }

  // ================= FORMAT ROLE TITLE =================
  String formatRoleTitle(String value) {
    final clean = value.trim().toLowerCase();
    if (clean.isEmpty) return '';
    return clean[0].toUpperCase() + clean.substring(1);
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

  // ================= FETCH ROLES =================
  Future<void> fetchRoles() async {
    setState(() => _isFetching = true);
    try {
      final endpoint = showDeleted ? "roles?deleted=true" : "roles";
      final data = await ApiService.get(endpoint);

      roles = List<Map<String, dynamic>>.from(data)
          .map(
            (r) => {
              "id": r["id"],
              "title": r["title"] ?? "",
              "created_at": r["created_at"] ?? "",
              "deleted_at": r["deleted_at"],
            },
          )
          .toList();

      _filterRoles();
    } catch (_) {
      _showSnackBar("Failed to fetch roles");
    } finally {
      setState(() => _isFetching = false);
    }
  }

  // ================= FILTER =================
  void _filterRoles() {
    final q = searchController.text.toLowerCase();
    setState(() {
      filteredRoles = roles.where((r) {
        final title = r["title"].toString().toLowerCase();
        final deleted = r["deleted_at"] != null;
        return title.contains(q) && (showDeleted ? deleted : !deleted);
      }).toList();
    });
  }

  // ================= SAVE ROLE =================
  Future<void> _saveRole() async {
    final title = formatRoleTitle(roleController.text);

    if (title.isEmpty) {
      _showSnackBar("Role title is required");
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService.post("new_role", {"title": title});
      Navigator.pop(context);
      roleController.clear();
      await fetchRoles();
      _showSnackBar("Role saved successfully", isError: false);
    } catch (_) {
      _showSnackBar("Failed to save role");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ================= DELETE ROLE =================
  Future<void> _deleteRole(int id) async {
    try {
      await ApiService.delete("delete_role/$id");
      await fetchRoles();
      _showSnackBar("Role deleted successfully", isError: false);
    } catch (_) {
      _showSnackBar("Failed to delete role");
    }
  }

  // ================= CONFIRM DELETE =================
  Future<void> _confirmDeleteRole(int id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Delete Role"),
        content: const Text(
          "Are you sure you want to delete this role?\nYou can restore it later.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteRole(id);
    }
  }

  // ================= RESTORE ROLE =================
  Future<void> _restoreRole(int id) async {
    try {
      await ApiService.post("restore_role/$id", {});
      await fetchRoles();
      _showSnackBar("Role restored successfully", isError: false);
    } catch (_) {
      _showSnackBar("Failed to restore role");
    }
  }

  // ================= MODAL =================
  void _openRoleModal() {
    roleController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Role",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: roleController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: "Role Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Create Role",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SNACKBAR =================
  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ================= TOGGLE BUTTON =================
  Widget _toggleBtn(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: active ? Colors.blue : Colors.grey[300],
            foregroundColor: active ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onTap,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Role Management"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 6,
        // Increase for a more visible shadow
        shadowColor: Colors.black54,
        // Shadow color
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchRoles),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search roles",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Row(
            children: [
              _toggleBtn("Active", !showDeleted, () {
                setState(() => showDeleted = false);
                fetchRoles();
              }),
              _toggleBtn("Deleted", showDeleted, () {
                setState(() => showDeleted = true);
                fetchRoles();
              }),
            ],
          ),
          Expanded(
            child: _isFetching
                ? const Center(child: CircularProgressIndicator())
                : filteredRoles.isEmpty
                ? const Center(child: Text("No roles found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredRoles.length,
                    itemBuilder: (_, i) {
                      final r = filteredRoles[i];
                      final deleted = r["deleted_at"] != null;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: deleted
                                ? Colors.grey
                                : Colors.blue,
                            child: const Icon(
                              Icons.security,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            r["title"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: deleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            formatDateTime(r["created_at"]),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == "delete") _confirmDeleteRole(r["id"]);
                              if (v == "restore") _restoreRole(r["id"]);
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: deleted ? "restore" : "delete",
                                child: Text(deleted ? "Restore" : "Delete"),
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
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Role", style: TextStyle(color: Colors.white)),
        onPressed: _openRoleModal,
      ),
    );
  }
}
