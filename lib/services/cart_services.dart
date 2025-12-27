import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_state.dart';

class CartService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Add item to user's cart
  static Future<void> addItem({
    required String productId,
    required String name,
    required double price,
    required int quantity,
    required String image,
    required String category,
  }) async {
    if (!AuthState.isLoggedIn) {
      throw Exception("NOT_LOGGED_IN");
    }

    final uid = AuthState.uid!;
    final docRef =
        _db.collection('users').doc(uid).collection('cart').doc(productId);

    // Use a transaction to increment quantity if item exists, otherwise create
    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (snapshot.exists) {
        tx.update(docRef, {
          'quantity': FieldValue.increment(quantity),
          'price': price,
          'name': name,
          'image': image,
          'category': category,
        });
      } else {
        tx.set(docRef, {
          'productId': productId,
          'name': name,
          'price': price,
          'quantity': quantity,
          'image': image,
          'category': category,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Get cart items
  static Stream<QuerySnapshot> getCart() {
    final uid = AuthState.uid!;
    return _db.collection('users').doc(uid).collection('cart').snapshots();
  }

  /// Clear cart
  static Future<void> clearCart() async {
    final uid = AuthState.uid!;
    final cartDocs =
        await _db.collection('users').doc(uid).collection('cart').get();

    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }
  }

  /// Remove single item (by document id / productId)
  static Future<void> removeItem(String productId) async {
    final uid = AuthState.uid!;
    await _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  /// Update quantity for an item
  static Future<void> updateItemQuantity(String productId, int quantity) async {
    final uid = AuthState.uid!;
    final docRef =
        _db.collection('users').doc(uid).collection('cart').doc(productId);
    await docRef.update({'quantity': quantity});
  }

  /// Create an order from current cart and clear it
  /// Returns the new order id
  static Future<String> createOrder({
    required bool shipping,
    required String date,
    required String time,
    Map<String, dynamic>? address,
  }) async {
    if (!AuthState.isLoggedIn) {
      throw Exception('NOT_LOGGED_IN');
    }

    final uid = AuthState.uid!;
    final cartSnap =
        await _db.collection('users').doc(uid).collection('cart').get();

    if (cartSnap.docs.isEmpty) {
      throw Exception('CART_EMPTY');
    }

    double itemTotal = 0;
    final List<Map<String, dynamic>> items = [];

    for (var doc in cartSnap.docs) {
      final d = doc.data();
      final qty = (d['quantity'] as num).toInt();
      final price = (d['price'] as num).toDouble();
      itemTotal += price * qty;
      items.add({
        'productId': d['productId'] ?? doc.id,
        'name': d['name'],
        'price': price,
        'quantity': qty,
        'image': d['image'],
        'category': d['category'],
      });
    }

    const double deliveryFee = 1.2;
    final double total = itemTotal + deliveryFee;

    final orderData = {
      'items': items,
      'itemTotal': itemTotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'shipping': shipping,
      'address': address ?? {},
      'date': date,
      'time': time,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Add to user's orders subcollection
    final orderRef = await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .add(orderData);

    // Also add to global orders collection for admin visibility
    await _db.collection('orders').doc(orderRef.id).set({
      'userId': uid,
      'orderId': orderRef.id,
      ...orderData,
    });

    // Clear cart
    for (var doc in cartSnap.docs) {
      await doc.reference.delete();
    }

    return orderRef.id;
  }
}
