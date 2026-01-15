import 'package:flutter/material.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Users"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 10, // later replace with API users
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text("User #$index"),
              subtitle: const Text("user@email.com"),
              trailing: PopupMenuButton(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: "block", child: Text("Block")),
                  PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
