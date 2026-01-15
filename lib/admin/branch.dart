import 'package:flutter/material.dart';

class AdminBranchPage extends StatelessWidget {
  const AdminBranchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Branches"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_location),
                label: const Text("Add New Branch"),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 5, // later from API
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text("Branch #$index"),
                    subtitle: const Text("Main Road, City"),
                    trailing: const Icon(Icons.edit),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
