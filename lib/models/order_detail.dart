import 'package:medical_storage/models/payment_method.dart';

import 'base_entity.dart';
import 'order.dart';
import 'medicine.dart';
import 'order_status.dart';

class OrderDetail extends BaseEntity {
  final Order order;
  final Medicine medicine;
  final int quantity;
  final double unitPrice;

  OrderDetail({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.order,
    required this.medicine,
    required this.quantity,
    required this.unitPrice,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      isDeleted: json['isDeleted'] ?? false,
      order: json['order'] != null
          ? Order.fromJson(Map<String, dynamic>.from(json['order']))
          : Order(
          id: json['orderId']?.toString(),
          patientId: json['patientId']?.toString() ?? '',
          orderCode: '',
          totalPrice: 0.0,
          paymentMethod: PaymentMethod.CASH,
          status: OrderStatus.PENDING
      ),
      medicine: json['medicine'] != null
          ? Medicine.fromJson(Map<String, dynamic>.from(json['medicine']))
          : Medicine(
        id: json['medicineId']?.toString() ?? '',
        name: json['medicineName'] ?? '', code: '', brandId: '',
        // Thêm các giá trị mặc định khác nếu cần
      ),
      quantity: (json['quantity'] is String
          ? int.parse(json['quantity'])
          : json['quantity']) ?? 0,
      unitPrice: (json['unitPrice'] is int
          ? (json['unitPrice'] as int).toDouble()
          : json['unitPrice'] ?? 0.0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'order': order.toJson(),
      'medicine': medicine.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
    });
    return data;
  }

  OrderDetail copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    Order? order,
    Medicine? medicine,
    int? quantity,
    double? unitPrice,
  }) {
    return OrderDetail(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}