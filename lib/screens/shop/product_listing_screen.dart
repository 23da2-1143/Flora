import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/product_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String? _selectedSize;
  String? _selectedCategory;
  String? _selectedColor;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop Collection',
          style: GoogleFonts.playfairDisplay(
            color: AppColors.darkGray,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(context),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: FirestoreService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProducts = snapshot.data ?? [];
                final filteredProducts = allProducts.where((p) {
                  if (_selectedSize != null && !p.sizes.contains(_selectedSize)) return false;
                  if (_selectedCategory != null && p.category != _selectedCategory) return false;
                  if (_selectedColor != null && !p.colors.contains(_selectedColor)) return false;
                  return true;
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products match your filters.', style: TextStyle(color: AppColors.lightGray)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: filteredProducts[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product-details',
                          arguments: filteredProducts[index],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterChip('Size', _selectedSize, ['S', 'M', 'L', 'XL'], (val) => setState(() => _selectedSize = val)),
          _buildFilterChip('Category', _selectedCategory, DummyData.categories, (val) => setState(() => _selectedCategory = val)),
          _buildFilterChip('Color', _selectedColor, ['Pink', 'Beige', 'Navy', 'Black', 'Gold', 'Emerald', 'White/Floral', 'Blue/Floral', 'Burgundy', 'Forest Green', 'Rust'], (val) => setState(() => _selectedColor = val)),
          _buildFilterChip('Price', null, ['Under \$100', '\$100 - \$200', 'Over \$200'], (val) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Price filter coming soon!')));
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? selectedValue, List<String> options, Function(String?) onSelected) {
    final isSelected = selectedValue != null;
    return Material(
      color: isSelected ? AppColors.gold : AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showFilterOptions(context, label, options, selectedValue, onSelected),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: AppColors.lightGray.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(
                isSelected ? selectedValue : label,
                style: TextStyle(fontSize: 12, color: isSelected ? AppColors.white : AppColors.darkGray),
              ),
              Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? AppColors.white : AppColors.lightGray),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, String filterName, List<String> options, String? currentSelection, Function(String?) onSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select $filterName',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      if (currentSelection != null)
                        TextButton(
                          onPressed: () {
                            onSelected(null);
                            Navigator.pop(context);
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return ListTile(
                          title: Text(option),
                          trailing: currentSelection == option
                              ? const Icon(Icons.check, color: AppColors.gold)
                              : null,
                          onTap: () {
                            onSelected(option);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
