import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/product_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildSearchBar(context),
              _buildBanner(),
              _buildCategories(),
              _buildSectionTitle(context, 'New Arrivals'),
              _buildFeaturedProducts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Flora & Fern',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 24,
              color: AppColors.gold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for dresses...',
          prefixIcon: const Icon(Icons.search, color: AppColors.lightGray),
          fillColor: AppColors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Spring Collection',
              style: GoogleFonts.playfairDisplay(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Up to 30% off',
              style: GoogleFonts.lato(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DummyData.categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected ? AppColors.gold : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: AppColors.lightGray.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      DummyData.categories[index],
                      style: GoogleFonts.lato(
                        color: isSelected ? AppColors.white : AppColors.darkGray,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          Text(
            'See All',
            style: GoogleFonts.lato(
              color: AppColors.lightGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    final selectedCategory = DummyData.categories[_selectedCategoryIndex];

    return StreamBuilder<List<Product>>(
      stream: FirestoreService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final allProducts = snapshot.data ?? [];
        final products = selectedCategory == 'All' || selectedCategory == 'New Arrivals' || selectedCategory == 'Best Sellers'
            ? allProducts
            : allProducts.where((p) => p.category == selectedCategory).toList();

        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: Text('No products found in this category.', style: TextStyle(color: AppColors.lightGray))),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(
              product: products[index],
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/product-details',
                  arguments: products[index],
                );
              },
            );
          },
        );
      },
    );
  }
}
