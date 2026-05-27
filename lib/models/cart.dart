import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String selectedSize;
  final String selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedSize,
    required this.selectedColor,
  });
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final _db = FirebaseFirestore.instance;
  String? _userId;

  List<CartItem> get items => _items;

  double get totalPrice {
    return _items.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }

  CartProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _loadCartFromFirestore();
      } else {
        _userId = null;
        _items.clear();
        notifyListeners();
      }
    });
  }

  Future<void> _loadCartFromFirestore() async {
    if (_userId == null) return;
    try {
      final doc = await _db.collection('carts').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final list = data['items'] as List<dynamic>? ?? [];
        _items.clear();
        for (final itemVal in list) {
          final item = itemVal as Map<String, dynamic>;
          final pData = item['product'] as Map<String, dynamic>;
          final product = Product(
            id: pData['id'] ?? '',
            name: pData['name'] ?? '',
            description: pData['description'] ?? '',
            price: (pData['price'] ?? 0.0).toDouble(),
            imageUrl: pData['imageUrl'] ?? '',
            images: List<String>.from(pData['images'] ?? []),
            category: pData['category'] ?? '',
            rating: (pData['rating'] ?? 4.5).toDouble(),
            reviews: (pData['reviews'] ?? 0).toInt(),
            colors: List<String>.from(pData['colors'] ?? []),
            sizes: List<String>.from(pData['sizes'] ?? []),
            stock: (pData['stock'] ?? 10).toInt(),
          );

          _items.add(
            CartItem(
              product: product,
              quantity: item['quantity'] ?? 1,
              selectedSize: item['selectedSize'] ?? 'S',
              selectedColor: item['selectedColor'] ?? 'Pink',
            ),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart from Firestore: $e');
    }
  }

  Future<void> _syncCartToFirestore() async {
    if (_userId == null) return;
    try {
      final list = _items.map((item) => {
        'product': {
          'id': item.product.id,
          'name': item.product.name,
          'description': item.product.description,
          'price': item.product.price,
          'imageUrl': item.product.imageUrl,
          'images': item.product.images,
          'category': item.product.category,
          'rating': item.product.rating,
          'reviews': item.product.reviews,
          'colors': item.product.colors,
          'sizes': item.product.sizes,
          'stock': item.product.stock,
        },
        'quantity': item.quantity,
        'selectedSize': item.selectedSize,
        'selectedColor': item.selectedColor,
      }).toList();

      await _db.collection('carts').doc(_userId).set({
        'items': list,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error syncing cart to Firestore: $e');
    }
  }

  void addItem(Product product, String size, String color) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size && item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          product: product,
          selectedSize: size,
          selectedColor: color,
        ),
      );
    }
    notifyListeners();
    _syncCartToFirestore();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
    _syncCartToFirestore();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity > 0) {
      item.quantity = newQuantity;
      notifyListeners();
      _syncCartToFirestore();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _syncCartToFirestore();
  }
}
