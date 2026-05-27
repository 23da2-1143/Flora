import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/cart.dart';
import '../../widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Bag',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.darkGray,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.blushPink),
                  const SizedBox(height: 16),
                  Text(
                    'Your bag is empty',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, item, cart);
                  },
                ),
              ),
              _buildCheckoutBar(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.product.imageUrl,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.selectedSize} | Color: ${item.selectedColor}',
                  style: const TextStyle(color: AppColors.lightGray, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${item.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.lightGray),
                          onPressed: () => cart.updateQuantity(item, item.quantity - 1),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.darkGray),
                          onPressed: () => cart.updateQuantity(item, item.quantity + 1),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => cart.removeItem(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 18, color: AppColors.lightGray)),
              Text(
                'Rs ${cart.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Proceed to Checkout',
            onPressed: () {
              Navigator.pushNamed(context, '/checkout');
            },
          ),
        ],
      ),
    );
  }
}
