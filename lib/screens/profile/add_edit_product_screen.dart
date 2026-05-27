import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _colorsController;

  String _selectedCategory = 'Casual Dresses';
  final List<String> _selectedSizes = [];
  bool _isLoading = false;
  String _liveImageUrl = '';

  // Core selectable categories (excluding 'All', 'New Arrivals', 'Best Sellers')
  final List<String> _formCategories = [
    'Casual Dresses',
    'Party Dresses',
    'Formal Dresses',
  ];

  final List<String> _availableSizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p?.price != null ? p!.price.toString() : '');
    _stockController = TextEditingController(text: p?.stock != null ? p!.stock.toString() : '10');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _colorsController = TextEditingController(text: p?.colors != null ? p!.colors.join(', ') : 'Pink, Beige, Navy');
    
    _liveImageUrl = p?.imageUrl ?? '';
    
    if (p != null) {
      if (_formCategories.contains(p.category)) {
        _selectedCategory = p.category;
      }
      _selectedSizes.addAll(p.sizes);
    } else {
      _selectedSizes.addAll(['S', 'M', 'L']);
    }

    _imageUrlController.addListener(() {
      setState(() {
        _liveImageUrl = _imageUrlController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one size.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final id = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final name = _nameController.text.trim();
      final desc = _descController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());
      final imageUrl = _imageUrlController.text.trim();
      final colors = _colorsController.text
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      final newProduct = Product(
        id: id,
        name: name,
        description: desc,
        price: price,
        imageUrl: imageUrl,
        images: widget.product?.images ?? [imageUrl],
        category: _selectedCategory,
        rating: widget.product?.rating ?? 4.5,
        reviews: widget.product?.reviews ?? 0,
        colors: colors,
        sizes: _selectedSizes,
        stock: stock,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      if (widget.product == null) {
        await FirestoreService.addProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully!'),
              backgroundColor: AppColors.gold,
            ),
          );
        }
      } else {
        await FirestoreService.updateProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: AppColors.gold,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
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
    final isEditMode = widget.product != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Product' : 'Add Product',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 24),
                    const Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray)),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Product Name',
                      prefixIcon: Icons.shopping_bag_outlined,
                      controller: _nameController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Product Description',
                        prefixIcon: const Icon(Icons.description_outlined, color: AppColors.lightGray),
                        fillColor: AppColors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hintText: 'Price (Rs)',
                            prefixIcon: Icons.attach_money,
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Price required';
                              final parsed = double.tryParse(val.trim());
                              if (parsed == null || parsed <= 0) return 'Invalid price';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            hintText: 'Stock Quantity',
                            prefixIcon: Icons.inventory_2_outlined,
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Stock required';
                              final parsed = int.tryParse(val.trim());
                              if (parsed == null || parsed < 0) return 'Invalid stock';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Image URL',
                      prefixIcon: Icons.link,
                      controller: _imageUrlController,
                      keyboardType: TextInputType.url,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Image URL is required' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                          style: GoogleFonts.lato(color: AppColors.darkGray, fontSize: 16),
                          items: _formCategories.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Available Sizes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableSizes.map((size) {
                        final isSelected = _selectedSizes.contains(size);
                        return FilterChip(
                          label: Text(size),
                          selected: isSelected,
                          selectedColor: AppColors.gold.withValues(alpha: 0.25),
                          checkmarkColor: AppColors.gold,
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppColors.gold : AppColors.lightGray.withValues(alpha: 0.3),
                            ),
                          ),
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                _selectedSizes.add(size);
                              } else {
                                _selectedSizes.remove(size);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text('Colors (comma-separated)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkGray)),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'e.g. Pink, Beige, Navy',
                      prefixIcon: Icons.palette_outlined,
                      controller: _colorsController,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Colors are required' : null,
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: isEditMode ? 'Save Changes' : 'Add Product',
                      onPressed: _saveProduct,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.lightGray.withValues(alpha: 0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _liveImageUrl.isEmpty
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 50, color: AppColors.lightGray),
                    SizedBox(height: 8),
                    Text('Live Image Preview', style: TextStyle(color: AppColors.lightGray)),
                  ],
                )
              : Image.network(
                  _liveImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 50, color: Colors.redAccent),
                      SizedBox(height: 8),
                      Text('Failed to load image', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
