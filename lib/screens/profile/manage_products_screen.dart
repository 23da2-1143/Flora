import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Product',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: AppColors.darkGray),
        ),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightGray)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await FirestoreService.deleteProduct(product.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${product.name}" deleted successfully.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete product: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Manage Products',
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilters(),
          Expanded(child: _buildProductsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-edit-product');
        },
        backgroundColor: AppColors.gold,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.white, size: 28),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search, color: AppColors.lightGray),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.lightGray),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          fillColor: AppColors.background,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim().toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      color: AppColors.white,
      height: 48,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DummyData.categories.length,
        itemBuilder: (context, index) {
          final cat = DummyData.categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected ? AppColors.gold : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: GoogleFonts.lato(
                        color: isSelected ? AppColors.white : AppColors.darkGray,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
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

  Widget _buildProductsList() {
    return StreamBuilder<List<Product>>(
      stream: FirestoreService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allProducts = snapshot.data ?? [];
        final filteredProducts = allProducts.where((p) {
          final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
          final matchesSearch = p.name.toLowerCase().contains(_searchQuery) ||
              p.description.toLowerCase().contains(_searchQuery);
          return matchesCategory && matchesSearch;
        }).toList();

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Text(
              'No products found matching filters.',
              style: TextStyle(color: AppColors.lightGray, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return Card(
              color: AppColors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: AppColors.lightGray.withValues(alpha: 0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.imageUrl,
                        width: 70,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 75,
                          color: AppColors.beige,
                          child: const Icon(Icons.image_not_supported, color: AppColors.lightGray),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category,
                            style: const TextStyle(
                              color: AppColors.lightGray,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'Rs ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: product.stock > 0
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  product.stock > 0 ? 'Stock: ${product.stock}' : 'Out of Stock',
                                  style: TextStyle(
                                    color: product.stock > 0 ? Colors.green : Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/add-edit-product',
                              arguments: product,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, product),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
