import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _showOldPassword = false;
  bool _showNewPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const ProfilePic(isShowPhotoUpload: true),
              const SizedBox(height: 24),
              EditProfileForm(
                showOldPassword: _showOldPassword,
                showNewPassword: _showNewPassword,
                onOldPasswordToggle: () {
                  setState(() {
                    _showOldPassword = !_showOldPassword;
                  });
                },
                onNewPasswordToggle: () {
                  setState(() {
                    _showNewPassword = !_showNewPassword;
                  });
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// Profile picture with camera overlay
class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    this.isShowPhotoUpload = false,
    this.imageUploadBtnPress,
  });

  final bool isShowPhotoUpload;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          if (isShowPhotoUpload)
            InkWell(
              onTap: imageUploadBtnPress,
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

// Rounded input field with optional icon and password toggle
class RoundedInputField extends StatelessWidget {
  const RoundedInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: suffixIcon,
          labelText: label,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }
}

// Form for editing profile
class EditProfileForm extends StatelessWidget {
  const EditProfileForm({
    super.key,
    required this.showOldPassword,
    required this.showNewPassword,
    required this.onOldPasswordToggle,
    required this.onNewPasswordToggle,
  });

  final bool showOldPassword;
  final bool showNewPassword;
  final VoidCallback onOldPasswordToggle;
  final VoidCallback onNewPasswordToggle;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const RoundedInputField(
            label: "First Name",
            hintText: "Enter your first name",
            icon: Icons.person,
          ),
          const RoundedInputField(
            label: "Last Name",
            hintText: "Enter your last name",
            icon: Icons.person,
          ),
          const RoundedInputField(
            label: "Email",
            hintText: "Enter your email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          RoundedInputField(
            label: "Old Password",
            hintText: "Enter old password",
            icon: Icons.lock,
            obscureText: !showOldPassword,
            suffixIcon: InkWell(
              onTap: onOldPasswordToggle,
              child: Icon(
                showOldPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
          ),
          RoundedInputField(
            label: "New Password",
            hintText: "Enter new password",
            icon: Icons.lock,
            obscureText: !showNewPassword,
            suffixIcon: InkWell(
              onTap: onNewPasswordToggle,
              child: Icon(
                showNewPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Update Profile"),
          )
        ],
      ),
    );
  }
}
