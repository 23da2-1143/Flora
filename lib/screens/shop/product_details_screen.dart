import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/product.dart';
import '../../models/cart.dart';
import '../../widgets/custom_button.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedSize = '';
  String _selectedColor = '';

  @override
  void initState() {
    super.initState();
    if (widget.product.sizes.isNotEmpty) _selectedSize = widget.product.sizes[0];
    if (widget.product.colors.isNotEmpty) _selectedColor = widget.product.colors[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white70,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.darkGray),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
              child: StreamBuilder<List<String>>(
                stream: FirestoreService.getWishlistIds(),
                builder: (context, snapshot) {
                  final wishlistIds = snapshot.data ?? [];
                  final isWishlisted = wishlistIds.contains(widget.product.id);
                  return IconButton(
                    icon: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.redAccent : AppColors.darkGray,
                    ),
                    onPressed: () async {
                      if (isWishlisted) {
                        await FirestoreService.removeFromWishlist(widget.product.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed from Wishlist'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      } else {
                        await FirestoreService.addToWishlist(widget.product.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to Wishlist'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 450,
              child: PageView.builder(
                itemCount: widget.product.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.product.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0, -30, 0),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                      Text(
                        'Rs ${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.product.rating} (${widget.product.reviews} reviews)',
                        style: const TextStyle(color: AppColors.lightGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: widget.product.sizes.map((size) {
                      final isSelected = size == _selectedSize;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSize = size),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.gold : AppColors.lightGray.withValues(alpha: 0.3),
                            ),
                            color: isSelected ? AppColors.gold : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              size,
                              style: TextStyle(
                                color: isSelected ? AppColors.white : AppColors.darkGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: widget.product.colors.map((color) {
                      final isSelected = color == _selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.darkGray : AppColors.lightGray.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected ? AppColors.darkGray : Colors.transparent,
                          ),
                          child: Text(
                            color,
                            style: TextStyle(
                              color: isSelected ? AppColors.white : AppColors.darkGray,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description,
                    style: const TextStyle(color: AppColors.lightGray, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'Add to Cart',
                    onPressed: () {
                      context.read<CartProvider>().addItem(widget.product, _selectedSize, _selectedColor);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to Cart!'),
                          backgroundColor: AppColors.gold,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
