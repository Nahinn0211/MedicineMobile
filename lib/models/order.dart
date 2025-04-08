import 'package:medical_storage/models/order_status.dart';
import 'package:medical_storage/models/payment_method.dart';

import 'base_entity.dart';
import 'patient_profile.dart';

class Order extends BaseEntity {
  final String patientId;
  final double totalPrice;
  final String orderCode;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final String? voucherCode;
  final double? discountAmount;
  final String? note;


  Order( {
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.patientId,
    required this.orderCode,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    this.voucherCode,
    this.discountAmount,
    this.note,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
  );

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(), // Chuyển sang string
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy']?.toString(), // Chuyển sang string
      orderCode: json['orderCode']?.toString() ?? '', // Đảm bảo luôn là string
      updatedBy: json['updatedBy']?.toString(), // Chuyển sang string
      patientId: json['patientId']?.toString() ?? '', // Chuyển sang string
      totalPrice: (json['totalPrice'] is int
          ? (json['totalPrice'] as int).toDouble()
          : json['totalPrice'] ?? 0.0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() ==
            (json['paymentMethod']?.toString().toUpperCase() ?? ''),
        orElse: () => PaymentMethod.CASH, // Giá trị mặc định nếu không tìm thấy
      ),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() ==
            (json['status']?.toString().toUpperCase() ?? ''),
        orElse: () => OrderStatus.PENDING, // Giá trị mặc định nếu không tìm thấy
      ),
      voucherCode: json['voucherCode']?.toString(),
      discountAmount: (json['discountAmount'] is int
          ? (json['discountAmount'] as int).toDouble()
          : json['discountAmount'] ?? 0.0).toDouble(),
      note: json['note']?.toString(),
    );
  }



  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'patientId': patientId,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod.toString().split('.').last.toUpperCase(),
      'status': status.toString().split('.').last.toUpperCase(),
      'voucherCode': voucherCode,
      'discountAmount': discountAmount,
      'note': note,
    });
    return data;
  }

  Order copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? orderCode,
    PatientProfile? patient,
    double? totalPrice,
    PaymentMethod? paymentMethod,
    OrderStatus? status,
    String? voucherCode,
    double? discountAmount,
    String? note,
  }) {
    return Order(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      patientId: patientId ?? this.patientId,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      voucherCode: voucherCode ?? this.voucherCode,
      discountAmount: discountAmount ?? this.discountAmount,
      note: note ?? this.note, orderCode: orderCode ?? this.orderCode,
    );
  }
}