import 'package:medical_storage/models/payment_status.dart';

import 'base_entity.dart';
import 'user.dart';

class Salary extends BaseEntity {
  final User user;
  final String bankCode;
  final String bankName;
  final double price;
  final PaymentStatus status;

  Salary({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.user,
    required this.bankCode,
    required this.bankName,
    required this.price,
    required this.status,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      user: User.fromJson(json['user']),
      bankCode: json['bankCode'],
      bankName: json['bankName'],
      price: json['price'].toDouble(),
      status: PaymentStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'user': user.toJson(),
      'bankCode': bankCode,
      'bankName': bankName,
      'price': price,
      'status': status.toString().split('.').last.toUpperCase(),
    });
    return data;
  }

  Salary copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    User? user,
    String? bankCode,
    String? bankName,
    double? price,
    PaymentStatus? status,
  }) {
    return Salary(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      user: user ?? this.user,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }
}