class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images;
  final String category;
  final double rating;
  final int reviews;
  final List<String> colors;
  final List<String> sizes;
  final int stock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.images,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.colors,
    required this.sizes,
    this.stock = 10,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
