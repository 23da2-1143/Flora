import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../services/firestore_service.dart';

class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() => _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showAddAddressSheet() {
    _labelController.clear();
    _addressController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(builderContext).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Address',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'Address Label (e.g. Home, Office)',
                    prefixIcon: Icons.label_outline,
                    controller: _labelController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Street Address',
                    prefixIcon: Icons.location_on_outlined,
                    controller: _addressController,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: _isAdding ? 'Adding...' : 'Add Address',
                    onPressed: _isAdding
                        ? null
                        : () async {
                            if (_labelController.text.trim().isEmpty ||
                                _addressController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(builderContext).showSnackBar(
                                const SnackBar(content: Text('Please fill all fields')),
                              );
                              return;
                            }
                            setModalState(() => _isAdding = true);
                            try {
                              await FirestoreService.addAddress(
                                label: _labelController.text.trim(),
                                address: _addressController.text.trim(),
                              );
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Address added successfully!')),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                            } finally {
                              setModalState(() => _isAdding = false);
                            }
                          },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Addresses', style: TextStyle(color: AppColors.darkGray)),
        iconTheme: const IconThemeData(color: AppColors.darkGray),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService.getAddresses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 80, color: AppColors.blushPink),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No addresses found. Add one to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.lightGray, fontSize: 16),
                    ),
                  ),
                  const Spacer(),
                  CustomButton(text: 'Add New Address', onPressed: _showAddAddressSheet),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: addresses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = addresses[index];
                      final id = item['id'] as String;
                      final label = item['label'] ?? 'Address';
                      final address = item['address'] ?? '';

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.gold, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home_outlined, color: AppColors.gold, size: 30),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    address,
                                    style: const TextStyle(color: AppColors.lightGray),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Address'),
                                    content: const Text('Are you sure you want to delete this address?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirestoreService.deleteAddress(id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Address deleted successfully!')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(text: 'Add New Address', onPressed: _showAddAddressSheet),
              ],
            ),
          );
        },
      ),
    );
  }
}

