import 'package:flutter/material.dart';
import 'edit_profile.dart';
import 'apis/api_services.dart';

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
    _profileFuture = fetchProfile();
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await ApiService.get("profile");
    if (response is Map<String, dynamic>) return response;
    throw Exception("Invalid profile data");
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
                  Text(snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _profileFuture = fetchProfile();
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final name = data['name'] ?? '';
          final email = data['email'] ?? '';
          final role = data['role']?['title'] ?? 'N/A';
          final branch = data['branch']?['branch_name'] ?? 'N/A';
          final joined = _formatDate(data['created_at'] ?? '');
          final profileImage =
          (data['profile_photo_url'] != null && data['profile_photo_url'] != "")
              ? data['profile_photo_url']
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                  child: profileImage == null ? const Icon(Icons.person, size: 55) : null,
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
                _infoTile(Icons.calendar_today, "Joined", joined),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Edit Profile",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
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
