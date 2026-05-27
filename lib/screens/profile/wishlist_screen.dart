import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';

import '../../services/firestore_service.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist', style: TextStyle(color: AppColors.darkGray)),
        iconTheme: const IconThemeData(color: AppColors.darkGray),
      ),
      body: StreamBuilder<List<String>>(
        stream: FirestoreService.getWishlistIds(),
        builder: (context, wishlistSnapshot) {
          if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final wishlistIds = wishlistSnapshot.data ?? [];

          if (wishlistIds.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.blushPink),
                  SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(color: AppColors.lightGray, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<List<Product>>(
            stream: FirestoreService.getProducts(),
            builder: (context, productsSnapshot) {
              if (productsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allProducts = productsSnapshot.data ?? [];
              final wishlistProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();

              if (wishlistProducts.isEmpty) {
                return const Center(
                  child: Text(
                    'No matching products found.',
                    style: TextStyle(color: AppColors.lightGray),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: wishlistProducts.length,
                itemBuilder: (context, index) {
                  final product = wishlistProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.pushNamed(context, '/product-details', arguments: product);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

