import 'base_entity.dart';

class Voucher extends BaseEntity {
  final String code;
  final double voucherPercentage;
  final int stock;
  final DateTime startDate;
  final DateTime? endDate;

  Voucher({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.code,
    required this.voucherPercentage,
    required this.stock,
    required this.startDate,
    this.endDate,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'].toString() ,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'].toString(),
      updatedBy: json['updatedBy'].toString(),
      isDeleted: json['isDeleted'],
      code: json['code'],
      voucherPercentage: json['voucherPercentage'].toDouble(),
      stock: json['stock'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'code': code,
      'voucherPercentage': voucherPercentage,
      'stock': stock,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    });
    return data;
  }

  Voucher copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? code,
    double? voucherPercentage,
    int? stock,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Voucher(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      code: code ?? this.code,
      voucherPercentage: voucherPercentage ?? this.voucherPercentage,
      stock: stock ?? this.stock,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}