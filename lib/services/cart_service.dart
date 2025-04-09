import 'package:flutter/foundation.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/models/voucher.dart';
import 'package:medical_storage/models/attribute.dart';
import 'package:http/http.dart' as http;
import 'package:medical_storage/services/auth_service.dart';
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
  List<CartItem> _items = [];
  Voucher? _appliedVoucher;
  late String? user_Id = '';
  final BaseService<Medicine> _medicineService;
  final BaseService<Attribute> _attributeService;

  CartService({
    BaseService<Medicine>? medicineService,
    BaseService<Attribute>? attributeService
  }) :
        _medicineService = medicineService ?? BaseService<Medicine>(
            endpoint: 'medicines',
            fromJson: Medicine.fromJson
        ),
        _attributeService = attributeService ?? BaseService<Attribute>(
            endpoint: 'attributes',
            fromJson: Attribute.fromJson
        ) {
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    user_Id = userId;
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
    // Kiểm tra sản phẩm đã tồn tại trong giỏ hàng chưa
    int existingIndex = _items.indexWhere(
            (item) =>
        item.medicine.id == medicine.id &&
            item.attribute.id == attribute.id
    );

    if (existingIndex != -1) {
      // Nếu sản phẩm đã tồn tại, cập nhật số lượng
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
        media: media ?? _items[existingIndex].media,
      );
    } else {
      // Thêm sản phẩm mới vào giỏ hàng
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
    final cartJson = _items.map((item) => item.toJson()).toList();
    await prefs.setString('cart_items', json.encode(cartJson));
  }

  Future<void> loadCartFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJsonString = prefs.getString('cart_items');

    if (cartJsonString != null) {
      final List<dynamic> cartJson = json.decode(cartJsonString);
      // Xóa giỏ hàng hiện tại trước khi tải
      _items.clear();

      // Tải lại thông tin chi tiết cho từng mục
      for (var itemJson in cartJson) {
        try {
          final medicine = await _medicineService.getById(itemJson['medicineId']);
          final attribute = await _attributeService.getById(itemJson['attributeId']);

          final cartItem = CartItem.fromJson(
              itemJson,
              medicine: medicine,
              attribute: attribute,
              userId: user_Id
          );
          _items.add(cartItem);
        } catch (e) {
          print('Lỗi tải chi tiết mục giỏ hàng: $e');
        }
      }
      notifyListeners();
    }
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