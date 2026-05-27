import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../models/cart.dart';
import '../../services/firestore_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPayment = 'Card';
  bool _isProcessing = false;
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfileDefaults();
  }

  Future<void> _loadUserProfileDefaults() async {
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await FirestoreService.getUserProfile().first;
      if (profile != null) {
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _addressController.text = profile['address'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile defaults for checkout: $e');
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final items = cart.items.map((item) => {
        'productId': item.product.id,
        'productName': item.product.name,
        'imageUrl': item.product.imageUrl,
        'quantity': item.quantity,
        'price': item.product.price,
        'selectedSize': item.selectedSize,
        'selectedColor': item.selectedColor,
      }).toList();

      final deliveryDetails = {
        'fullName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'deliveryNotes': _notesController.text.trim(),
      };

      await FirestoreService.placeOrder(
        items: items,
        total: cart.totalPrice + 10.00, // Rs 10.00 shipping fee
        deliveryDetails: deliveryDetails,
        paymentMethod: _selectedPayment,
      );

      if (mounted) {
        cart.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order Placed Successfully!'),
            backgroundColor: AppColors.gold,
          ),
        );
        Navigator.popUntil(context, ModalRoute.withName('/main'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.darkGray,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: AppColors.white,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Phone number is required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Street Address',
                      prefixIcon: Icons.location_on_outlined,
                      controller: _addressController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Street address is required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'City',
                      prefixIcon: Icons.location_city_outlined,
                      controller: _cityController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'City is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Delivery Notes (Optional)',
                        prefixIcon: const Icon(Icons.note_alt_outlined, color: AppColors.lightGray),
                        fillColor: AppColors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOption('Card', Icons.credit_card),
                    const SizedBox(height: 12),
                    _buildPaymentOption('Cash on Delivery', Icons.money),
                    const SizedBox(height: 32),
                    const Text(
                      'Order Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkGray),
                    ),
                    const SizedBox(height: 16),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        return Column(
                          children: [
                            _buildSummaryRow('Subtotal', 'Rs ${cart.totalPrice.toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Shipping', 'Rs 10.00'),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              'Total',
                              'Rs ${(cart.totalPrice + 10.00).toStringAsFixed(2)}',
                              isTotal: true,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: _isProcessing ? 'Placing Order...' : 'Place Order',
                      onPressed: _isProcessing ? null : _processCheckout,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSelected = _selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.lightGray.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.gold : AppColors.darkGray),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: AppColors.darkGray),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            color: isTotal ? AppColors.darkGray : AppColors.lightGray,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 16,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            color: AppColors.darkGray,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
            fontSize: isTotal ? 18 : 16,
          ),
        ),
      ],
    );
  }
}
