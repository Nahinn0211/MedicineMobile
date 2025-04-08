import 'package:flutter/foundation.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/models/voucher.dart';
import 'package:medical_storage/models/attribute.dart';
import 'package:http/http.dart' as http;
import 'package:medical_storage/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/medicine_media.dart';

class CartItem {
  final Medicine medicine;
  final Attribute attribute;
  final MedicineMedia? media;
  final int quantity;
  final String? userId;
  bool isSelected;

  CartItem({
    required this.medicine,
    required this.attribute,
    this.media,
    this.isSelected = false,
    this.quantity = 1,
    required this.userId,
  });

  double get totalPrice => attribute.priceOut * quantity;

  CartItem copyWith({
    int? quantity,
    MedicineMedia? media,
    Attribute? attribute,
    bool? isSelected,
    String? userId,
  }) {
    return CartItem(
      medicine: medicine,
      attribute: attribute ?? this.attribute,
      media: media ?? this.media,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        medicine.id == other.medicine.id &&
        attribute.id == other.attribute.id;
  }

  @override
  int get hashCode => medicine.id.hashCode ^ attribute.id.hashCode;
}

class CartService extends ChangeNotifier {
  List<CartItem> _items = [];
  Voucher? _appliedVoucher;
  late String? user_Id = '';


  CartService() {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    user_Id =userId;
    await loadCartFromLocal();
  }

  List<CartItem> get items => List.unmodifiable(_items);
  Voucher? get appliedVoucher => _appliedVoucher;

  double get subtotal {
    return _items.fold(0, (total, item) => total + item.totalPrice);
  }

  double get total {
    double subtotal = this.subtotal;
    if (_appliedVoucher != null && _isVoucherValid(_appliedVoucher!)) {
      return subtotal * (1 - (_appliedVoucher!.voucherPercentage / 100));
    }
    return subtotal;
  }

  Future<String> fetchMedicineImage(String medicineId) async {
    final url = 'https://192.168.1.246/api/medicines/$medicineId'; // Update URL according to your API
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['image']; // Assuming API returns an 'image' key
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
    return ''; // Return empty string if image can't be retrieved
  }

  void addToCart(Medicine medicine, Attribute attribute, {MedicineMedia? media, int quantity = 1}) {
    // Check if the product already exists in the cart
    int existingIndex = -1;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].medicine.id == medicine.id &&
          _items[i].attribute.id == attribute.id) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      // If it exists, update the quantity
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
        media: media ?? _items[existingIndex].media,
      );
    } else {
      // Add new product to the cart
      _items.add(CartItem(
        medicine: medicine,
        attribute: attribute,
        media: media,
        quantity: quantity,
        userId: user_Id,
      ));
    }

    notifyListeners();
    saveCartToLocal();
  }

  void removeFromCart(CartItem item) {
    _items.remove(item);
    notifyListeners();
    saveCartToLocal();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(item);
      return;
    }

    final index = _items.indexOf(item);
    if (index != -1) {
      _items[index] = item.copyWith(quantity: newQuantity);
      notifyListeners();
      saveCartToLocal();
    }
  }

  bool applyVoucher(Voucher voucher) {
    if (_isVoucherValid(voucher)) {
      _appliedVoucher = voucher;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeVoucher() {
    _appliedVoucher = null;
    notifyListeners();
  }

  bool _isVoucherValid(Voucher voucher) {
    final now = DateTime.now();
    if (voucher.isDeleted == true) return false;
    if (now.isBefore(voucher.startDate)) return false;
    if (voucher.endDate != null && now.isAfter(voucher.endDate!)) return false;
    if (voucher.stock <= 0) return false;
    return true;
  }

  Future<void> saveCartToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = _items.map((item) => {
      'medicineId': item.medicine.id,
      'attributeId': item.attribute.id,
      'quantity': item.quantity,
      'isSelected': item.isSelected,
      // Add other fields if needed
    }).toList();
    await prefs.setString('cart_items', json.encode(cartJson));
  }

  Future<void> loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJsonString = prefs.getString('cart_items');

    if (cartJsonString != null) {
      final List<dynamic> cartJson = json.decode(cartJsonString);
      // Clear the current cart before loading
      _items.clear();

      // Need to add logic to fully restore CartItem information
      // You'll need to query medicine and a information from the database
      for (var itemJson in cartJson) {
        final medicine = await _fetchMedicineById(itemJson['medicineId']);
        final attribute = await _fetchAttributeById(itemJson['attributeId']);

        if (medicine != null && attribute != null) {
          final cartItem = CartItem(
            medicine: medicine,
            attribute: attribute,
            quantity: itemJson['quantity'],
            isSelected: itemJson['isSelected'] ?? false,
            userId: user_Id,
          );
          _items.add(cartItem);
        }
      }
      notifyListeners();
    }
  }

  // Helper method to get Medicine by ID
  Future<Medicine?> _fetchMedicineById(String medicineId) async {
    // Implement logic to get Medicine from API or local database
    try {
      final response = await http.get(
          Uri.parse('http://10.0.0.90/api/medicines/$medicineId')
      );
      if (response.statusCode == 200) {
        return Medicine.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error fetching medicine info: $e');
    }
    return null;
  }

  // Helper method to get Attribute by ID
  Future<Attribute?> _fetchAttributeById(String attributeId) async {
    try {
      final response = await http.get(
          Uri.parse('http://10.0.0.90/api/attributes/$attributeId')
      );
      if (response.statusCode == 200) {
        return Attribute.fromJson(json.decode(response.body));
      }
    } catch (e) {
      print('Error fetching attribute info: $e');
    }
    return null;
  }

  void clearCart() {
    _items.clear();
    _appliedVoucher = null;
    notifyListeners();
    saveCartToLocal();
  }

  bool get isAllSelected {
    return _items.isNotEmpty && _items.every((item) => item.isSelected);
  }

  void toggleSelectAll(bool isSelected) {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isSelected: isSelected);
    }
    notifyListeners();
    saveCartToLocal();
  }

  void toggleItemSelection(CartItem item, bool isSelected) {
    final index = _items.indexOf(item);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isSelected: isSelected);
      notifyListeners();
      saveCartToLocal();
    }
  }
}