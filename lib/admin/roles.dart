import 'package:flutter/material.dart';

class AdminRolesPage extends StatelessWidget {
  const AdminRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = ["Admin", "Baker", "Staff", "Manager"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Roles"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: Text(roles[index]),
              trailing: const Icon(Icons.edit),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                      Text("Edit ${roles[index]} role coming soon")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
