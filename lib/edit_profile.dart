import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/apis/api_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _showOldPassword = false;
  bool _showNewPassword = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  File? _imageFile; // Selected profile image
  late Future<Map<String, dynamic>> _profileFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = fetchProfile();
  }

  // Fetch profile data
  Future<Map<String, dynamic>> fetchProfile() async {
    final data = await ApiService.get("profile");

    // Auto-fill text controllers
    final nameParts = (data['name'] as String).split(" ");
    _firstNameController.text = nameParts.first;
    _lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
    _emailController.text = data['email'];

    return data;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final fields = {
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
      };

      // Add password fields if filled
      if (_oldPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty) {
        fields["old_password"] = _oldPasswordController.text.trim();
        fields["new_password"] = _newPasswordController.text.trim();
      }

      final response = await ApiService.uploadProfile(fields, _imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Profile updated successfully")),
      );

      // Refresh profile after update
      setState(() {
        _profileFuture = fetchProfile();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile"),
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
              child: Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red)),
            );
          }

          final data = snapshot.data!;
          final String? profileImageUrl = data['profile_photo_url'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : (profileImageUrl != null ? NetworkImage(profileImageUrl) : null),
                      child: (_imageFile == null && profileImageUrl == null)
                          ? const Icon(Icons.person, size: 55)
                          : null,
                    ),
                    InkWell(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: "First Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    labelText: "Last Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: !_showOldPassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "Old Password",
                    suffixIcon: IconButton(
                      icon: Icon(_showOldPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showOldPassword = !_showOldPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "New Password",
                    suffixIcon: IconButton(
                      icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isUpdating ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isUpdating ? "Updating..." : "Update Profile"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
