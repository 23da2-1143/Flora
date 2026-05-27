import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _photoUrlController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingImage = false;
  String _livePhotoUrl = '';

  // Curated premium portrait preset URLs
  final List<String> _presetAvatars = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    
    _photoUrlController.addListener(() {
      setState(() {
        _livePhotoUrl = _photoUrlController.text.trim();
      });
    });
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await FirestoreService.getUserProfile().first;
      if (profile != null) {
        _nameController.text = profile['name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _photoUrlController.text = profile['photoUrl'] ?? '';
        
        setState(() {
          _livePhotoUrl = profile['photoUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200, // Fit exact avatar size limits
        maxHeight: 200,
        imageQuality: 50, // Compress to stay well within 1MB Firestore limit
      );

      if (pickedFile == null) return;

      setState(() => _isLoadingImage = true);

      // Read image bytes (cross-platform compatible)
      final bytes = await pickedFile.readAsBytes();
      
      // Convert to Base64 data URI
      final base64String = 'data:image/jpeg;base64,${base64.encode(bytes)}';

      setState(() {
        _photoUrlController.text = base64String;
        _livePhotoUrl = base64String;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image loaded successfully!'),
            backgroundColor: AppColors.gold,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingImage = false);
    }
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

  void _showAvatarSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.softPink,
                      child: Icon(Icons.photo_library_outlined, color: AppColors.darkGray),
                    ),
                    title: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Choose a local photo instantly', style: TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage();
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Or Choose a Premium Preset',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presetAvatars.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final url = _presetAvatars[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _photoUrlController.text = url;
                              _livePhotoUrl = url;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _livePhotoUrl == url ? AppColors.gold : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(url),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirestoreService.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        photoUrl: _photoUrlController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.gold,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.darkGray,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkGray),
        elevation: 0,
        backgroundColor: AppColors.white,
      ),
      body: _isLoading && _nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileImageAvatar(),
                    const SizedBox(height: 20),
                    const Text(
                      'Choose a Premium Avatar Preset',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGray,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      child: Center(
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: _presetAvatars.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final url = _presetAvatars[index];
                            final isSelected = _livePhotoUrl == url;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _photoUrlController.text = url;
                                  _livePhotoUrl = url;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.gold : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(url),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Profile details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Phone number is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Street Address',
                      prefixIcon: Icons.location_on_outlined,
                      controller: _addressController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Street address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Profile Image URL',
                      prefixIcon: Icons.link,
                      controller: _photoUrlController,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: _isLoading ? 'Saving...' : 'Save Changes',
                      onPressed: _isLoading ? null : _saveChanges,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImageAvatar() {
    return Center(
      child: GestureDetector(
        onTap: _isLoadingImage ? null : _showAvatarSelectorBottomSheet,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: AppColors.blushPink.withValues(alpha: 0.5),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.softPink,
                backgroundImage: _getAvatarImageProvider(_livePhotoUrl),
                child: _isLoadingImage
                    ? const CircularProgressIndicator(color: AppColors.gold)
                    : (_livePhotoUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: AppColors.darkGray)
                        : null),
              ),
            ),
            if (!_isLoadingImage)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 18, color: AppColors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
