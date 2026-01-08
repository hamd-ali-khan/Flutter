import 'package:flutter/material.dart';
import 'edit_profile.dart';
import '../apis/api_services.dart'; // import ApiService

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.get("profile");// use API service
  }

  String _formatDate(String rawDate) {
    try {
      return rawDate.split(" ").first;
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _profileFuture = ApiService.get("profile");
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final String name = data['name'];
          final String email = data['email'];
          final String role = data['role']['title'];
          final String branch = data['branch']['branch_name'];
          final String createdAt = _formatDate(data['created_at']);
          final String? profileImage = data['profile_photo_url'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                  profileImage != null ? NetworkImage(profileImage) : null,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 55)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                _infoTile(Icons.badge, "Role", role),
                _infoTile(Icons.store, "Branch", branch),
                _infoTile(Icons.calendar_today, "Joined", createdAt),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  },
                  child: const Text("Edit Profile"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
