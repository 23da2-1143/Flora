import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../utils/dummy_data.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ─── USER PROFILE ───────────────────────────────────────────────

  static Stream<Map<String, dynamic>?> getUserProfile() {
    final uid = _uid;
    if (uid == null) {
      return Stream.fromIterable(<Map<String, dynamic>?>[null]);
    }
    return _db.collection('users').doc(uid).snapshots().map(
      (doc) => doc.data(),
    );
  }

  static Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? photoUrl,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    
    // Update Firestore user document with a timeout safety block
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true))
        .timeout(const Duration(seconds: 8));

    // Double-sync changes directly to the authenticated Firebase User profile
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (name != null) {
        await user.updateDisplayName(name.trim())
            .timeout(const Duration(seconds: 4))
            .catchError((_) => null);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl.trim())
            .timeout(const Duration(seconds: 4))
            .catchError((_) => null);
      }
    }
  }

  // ─── WISHLIST ────────────────────────────────────────────────────

  static Stream<List<String>> getWishlistIds() {
    final uid = _uid;
    if (uid == null) {
      return Stream.fromIterable(<List<String>>[<String>[]]);
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  static Future<void> addToWishlist(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .set({'addedAt': FieldValue.serverTimestamp()});
  }

  static Future<void> removeFromWishlist(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  // ─── ORDERS ──────────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> getOrders() {
    final uid = _uid;
    if (uid == null) {
      return Stream.fromIterable(<List<Map<String, dynamic>>>[<Map<String, dynamic>>[]]);
    }
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
          list.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // descending
          });
          return list;
        });
  }

  static Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required Map<String, dynamic> deliveryDetails,
    required String paymentMethod,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('orders').add({
      'userId': uid,
      'items': items,
      'totalAmount': total,
      'deliveryDetails': deliveryDetails,
      'paymentStatus': paymentMethod == 'Card' ? 'Paid' : 'Pending',
      'orderStatus': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── ADDRESSES ───────────────────────────────────────────────────

  static Stream<List<Map<String, dynamic>>> getAddresses() {
    final uid = _uid;
    if (uid == null) {
      return Stream.fromIterable(<List<Map<String, dynamic>>>[<Map<String, dynamic>>[]]);
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  static Future<void> addAddress({
    required String label,
    required String address,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .add({'label': label, 'address': address, 'createdAt': FieldValue.serverTimestamp()});
  }

  static Future<void> deleteAddress(String addressId) async {
    final uid = _uid;
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  // ─── PRODUCTS ────────────────────────────────────────────────────

  static Product _productFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviews: (data['reviews'] ?? 0).toInt(),
      colors: List<String>.from(data['colors'] ?? []),
      sizes: List<String>.from(data['sizes'] ?? []),
      stock: (data['stock'] ?? 10).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Stream<List<Product>> getProducts() async* {
    // Always emit local products first so the UI is never empty
    yield DummyData.products;

    // Then try to listen to Firestore for cloud data
    try {
      await for (final snap in _db.collection('products').snapshots()) {
        if (snap.docs.isNotEmpty) {
          yield snap.docs.map((doc) => _productFromDoc(doc)).toList();
        } else {
          yield DummyData.products;
        }
      }
    } catch (e) {
      // Firebase not configured or permission denied — keep using dummy data
      debugPrint('Firestore products error: $e');
      yield DummyData.products;
    }
  }

  static Future<void> seedProductsIfNeeded() async {
    try {
      final snap = await _db.collection('products').get();
      if (snap.docs.length != 5) {
        final batch = _db.batch();
        // Delete all old products in the collection
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        // Add the 5 clean dress products
        for (final product in DummyData.products) {
          final docRef = _db.collection('products').doc(product.id);
          batch.set(docRef, {
            'productId': product.id,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'category': product.category,
            'imageUrl': product.imageUrl,
            'images': product.images,
            'rating': product.rating,
            'reviews': product.reviews,
            'colors': product.colors,
            'sizes': product.sizes,
            'stock': product.stock,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        debugPrint('Seeded exactly 5 dress products successfully.');
      }
    } catch (e) {
      // Avoid crash on initialization failures
      debugPrint('Error seeding products: $e');
    }
  }

  static Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email == 'mhdmanfahath119@gmail.com';
  }

  static Future<void> addProduct(Product product) async {
    if (!await _isAdmin()) {
      throw Exception('Permission denied: only admin can add products.');
    }
    await _db.collection('products').doc(product.id).set({
      'productId': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'images': [product.imageUrl],
      'rating': product.rating,
      'reviews': product.reviews,
      'colors': product.colors,
      'sizes': product.sizes,
      'stock': product.stock,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateProduct(Product product) async {
    if (!await _isAdmin()) {
      throw Exception('Permission denied: only admin can update products.');
    }
    await _db.collection('products').doc(product.id).update({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'images': [product.imageUrl],
      'colors': product.colors,
      'sizes': product.sizes,
      'stock': product.stock,
    });
  }

  static Future<void> deleteProduct(String productId) async {
    if (!await _isAdmin()) {
      throw Exception('Permission denied: only admin can delete products.');
    }
    await _db.collection('products').doc(productId).delete();
  }

  // ─── FILE UPLOAD ─────────────────────────────────────────────────

  static Future<String> uploadProfileImageBytes(Uint8List bytes) async {
    final uid = _uid;
    if (uid == null) throw Exception("User not logged in");
    
    final ref = FirebaseStorage.instance.ref().child('users').child(uid).child('profile.jpg');
    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    
    // Safety timeout of 8 seconds prevents infinite network retries if Storage is not set up
    final snapshot = await uploadTask.timeout(const Duration(seconds: 8));
    final downloadUrl = await snapshot.ref.getDownloadURL()
        .timeout(const Duration(seconds: 4));
    return downloadUrl;
  }
}

