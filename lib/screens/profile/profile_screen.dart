import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import 'dart:convert';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  ImageProvider? _getAvatarImageProvider(String url) {
    if (url.isEmpty) return null;
    if (url.startsWith('data:image')) {
      try {
        final base64Content = url.split(',').last;
        return MemoryImage(base64.decode(base64Content));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return null;
      }
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.darkGray,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FirestoreService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          final name = data?['name'] ?? AuthService.currentUser?.displayName ?? 'User';
          final email = data?['email'] ?? AuthService.currentUser?.email ?? 'No email';
          final photoUrl = data?['photoUrl'] ?? '';
          final initials = _getInitials(name);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.blushPink,
                        backgroundImage: _getAvatarImageProvider(photoUrl),
                        child: photoUrl.isEmpty
                            ? Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: AppColors.darkGray,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/edit-profile');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 20, color: AppColors.gold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: AppColors.lightGray),
                ),
                const SizedBox(height: 32),
                _buildProfileMenu(context, 'Edit Profile', Icons.person_outline),
                _buildProfileMenu(context, 'Manage Products', Icons.admin_panel_settings_outlined),
                _buildProfileMenu(context, 'My Orders', Icons.shopping_bag_outlined),
                _buildProfileMenu(context, 'Wishlist', Icons.favorite_border),
                _buildProfileMenu(context, 'Shipping Addresses', Icons.location_on_outlined),
                _buildProfileMenu(context, 'Settings', Icons.settings_outlined),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthService.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      side: const BorderSide(color: Colors.redAccent),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.darkGray),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.lightGray),
      onTap: () {
        String routeName = '';
        switch(title) {
          case 'Edit Profile': routeName = '/edit-profile'; break;
          case 'Manage Products': routeName = '/manage-products'; break;
          case 'My Orders': routeName = '/my-orders'; break;
          case 'Wishlist': routeName = '/wishlist'; break;
          case 'Shipping Addresses': routeName = '/shipping-addresses'; break;
          case 'Settings': routeName = '/settings'; break;
        }
        if (routeName.isNotEmpty) {
          Navigator.pushNamed(context, routeName);
        }
      },
    );
  }
}
