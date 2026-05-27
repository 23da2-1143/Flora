import '../models/product.dart';

class DummyData {
  static const List<String> categories = [
    'All',
    'Casual Dresses',
    'Party Dresses',
    'Formal Dresses',
    'New Arrivals',
    'Best Sellers',
  ];

  static List<Product> products = [
    Product(
      id: '1',
      name: 'Eleanor Chiffon Maxi Dress',
      description: 'A beautiful flowing chiffon maxi dress with a delicate sweetheart neckline. Perfect for formal evenings or as a stunning bridesmaid dress. Features delicate ruching and a concealed back zip.',
      price: 129.99,
      imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      images: [
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      ],
      category: 'Formal Dresses',
      rating: 4.8,
      reviews: 124,
      colors: ['Pink', 'Beige', 'Navy'],
      sizes: ['S', 'M', 'L'],
    ),
    Product(
      id: '2',
      name: 'Stella Silk Slip Dress',
      description: 'Embrace 90s minimalism with this pure silk slip dress. Bias cut to skim your curves with adjustable spaghetti straps. The ultimate versatile piece for evening wear.',
      price: 89.50,
      imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      images: [
        'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      ],
      category: 'Party Dresses',
      rating: 4.5,
      reviews: 89,
      colors: ['Gold', 'Black', 'Emerald'],
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
    ),
    Product(
      id: '3',
      name: 'Chloe Floral Sundress',
      description: 'Breezy cotton sundress featuring a delicate floral print. Fitted bodice with a smocked back for comfort and a tiered midi skirt.',
      price: 65.00,
      imageUrl: 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      images: [
        'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      ],
      category: 'Casual Dresses',
      rating: 4.2,
      reviews: 56,
      colors: ['White/Floral', 'Blue/Floral'],
      sizes: ['S', 'M', 'L'],
    ),
    Product(
      id: '4',
      name: 'Amelia Evening Gown',
      description: 'Make a statement in this floor-sweeping evening gown. Features elegant draping, a thigh-high slit, and exquisite beadwork along the bodice.',
      price: 195.00,
      imageUrl: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      images: [
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      ],
      category: 'Formal Dresses',
      rating: 4.9,
      reviews: 210,
      colors: ['Navy', 'Burgundy'],
      sizes: ['S', 'M', 'L', 'XL'],
    ),
    Product(
      id: '5',
      name: 'Isabella Wrap Midi',
      description: 'Flattering wrap silhouette in a comfortable crepe fabric. A versatile piece that easily transitions from office to evening drinks.',
      price: 78.00,
      imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      images: [
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=compress&cs=tinysrgb&w=400&h=600&fit=crop',
      ],
      category: 'Casual Dresses',
      rating: 4.6,
      reviews: 145,
      colors: ['Black', 'Forest Green', 'Rust'],
      sizes: ['M', 'L', 'XL'],
    ),
  ];

  static List<Product> get featuredProducts {
    return products.take(3).toList();
  }
}
