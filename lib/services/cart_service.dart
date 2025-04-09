import 'package:flutter/foundation.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/models/voucher.dart';
import 'package:medical_storage/models/attribute.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'base_service.dart';

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

  // Chuyển đổi CartItem sang JSON
  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicine.id,
      'attributeId': attribute.id,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  // Tạo CartItem từ JSON
  static CartItem fromJson(Map<String, dynamic> json,
      {required Medicine medicine,
        required Attribute attribute,
        String? userId}) {
    return CartItem(
      medicine: medicine,
      attribute: attribute,
      quantity: json['quantity'] ?? 1,
      isSelected: json['isSelected'] ?? false,
      userId: userId,
    );
  }
}

class CartService extends ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get itemsMap => _items;
  Voucher? _appliedVoucher;
  late String? user_Id = '';
  final BaseService<Medicine> _medicineService;
  final BaseService<Attribute> _attributeService;

  CartService({
    BaseService<Medicine>? medicineService,
    BaseService<Attribute>? attributeService,
  })  : _medicineService = medicineService ?? BaseService<Medicine>(endpoint: 'medicines', fromJson: Medicine.fromJson),
        _attributeService = attributeService ?? BaseService<Attribute>(endpoint: 'attributes', fromJson: Attribute.fromJson) {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final prefs = await SharedPreferences.getInstance();
    user_Id = prefs.getString('userId');
    await loadCartFromLocal();
  }

  List<CartItem> get items => _items.values.toList();
  Voucher? get appliedVoucher => _appliedVoucher;

  double get subtotal => _items.values.fold(0, (sum, item) => sum + item.totalPrice);

  double get total {
    double subtotal = this.subtotal;
    if (_appliedVoucher != null && _isVoucherValid(_appliedVoucher!)) {
      return subtotal * (1 - (_appliedVoucher!.voucherPercentage / 100));
    }
    return subtotal;
  }

  Future<String> fetchMedicineImage(String medicineId) async {
     const String baseUrl = 'http://192.168.1.249:8080/api';
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines/$medicineId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['image'] ?? '';
      } else {
        print('Failed to load image. Status code: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print("Error fetching medicine image: $e");
      return '';
    }
  }

  void addToCart(Medicine medicine, Attribute attribute, {MedicineMedia? media, int quantity = 1}) {
    final key = '${medicine.id}_$user_Id';
    if (_items.containsKey(key)) {
      final existing = _items[key]!;
      _items[key] = existing.copyWith(
        quantity: existing.quantity + quantity,
        media: media ?? existing.media,
      );
    } else {
      _items[key] = CartItem(
        medicine: medicine,
        attribute: attribute,
        media: media,
        quantity: quantity,
        userId: user_Id,
      );
    }

    notifyListeners();
    saveCartToLocal();
  }

  void removeFromCart(String key) {
    _items.remove(key);
    notifyListeners();
    saveCartToLocal();
  }

  void updateQuantity(String key, int newQuantity) {
    if (_items.containsKey(key)) {
      if (newQuantity <= 0) {
        removeFromCart(key);
      } else {
        _items[key] = _items[key]!.copyWith(quantity: newQuantity);
        notifyListeners();
        saveCartToLocal();
      }
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
    final cartMapJson = _items.map((key, item) => MapEntry(key, item.toJson()));
    await prefs.setString('cart_items', json.encode(cartMapJson));
  }

  Future<void> loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cart_items');

    if (jsonString != null) {
      final Map<String, dynamic> cartJsonMap = json.decode(jsonString);
      _items.clear();

      for (var entry in cartJsonMap.entries) {
        final key = entry.key;
        final itemJson = entry.value;

        try {
          final medicine = await _medicineService.getById(itemJson['medicineId']);
          final attribute = await _attributeService.getById(itemJson['attributeId']);

          final cartItem = CartItem.fromJson(
            itemJson,
            medicine: medicine,
            attribute: attribute,
            userId: user_Id,
          );

          _items[key] = cartItem;
        } catch (e) {
          print('Lỗi khi load cart item: $e');
        }
      }
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    _appliedVoucher = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');
  }

  // Lựa chọn
  bool get isAllSelected => _items.values.isNotEmpty && _items.values.every((item) => item.isSelected);

  void toggleSelectAll(bool isSelected) {
    _items.updateAll((key, item) => item.copyWith(isSelected: isSelected));
    notifyListeners();
    saveCartToLocal();
  }

  void toggleItemSelection(String key, bool isSelected) {
    if (_items.containsKey(key)) {
      _items[key] = _items[key]!.copyWith(isSelected: isSelected);
      notifyListeners();
      saveCartToLocal();
    }
  }
}
