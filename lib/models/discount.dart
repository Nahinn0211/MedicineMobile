import 'base_entity.dart';
import 'medicine.dart';

class Discount extends BaseEntity {
  final String code;
  final String name;
  final Medicine? medicine;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime? endDate;

  Discount({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.code,
    required this.name,
    this.medicine,
    required this.discountPercentage,
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

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'].toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      code: json['code']?.toString() ?? '', // Chuyển đổi code sang string, cung cấp giá trị mặc định nếu null
      name: json['name']?.toString() ?? '', // Chuyển đổi name sang string, cung cấp giá trị mặc định nếu null
      medicine: json['medicine'] != null ? Medicine.fromJson(json['medicine']) : null,
      // Xử lý discountPercentage một cách an toàn
      discountPercentage: (json['discountPercentage'] is int || json['discountPercentage'] is double)
          ? (json['discountPercentage'] as num).toDouble()
          : double.tryParse(json['discountPercentage']?.toString() ?? '0') ?? 0.0,
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'code': code,
      'name': name,
      'medicine': medicine?.toJson(),
      'discountPercentage': discountPercentage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    });
    return data;
  }

  Discount copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? code,
    String? name,
    Medicine? medicine,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Discount(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      code: code ?? this.code,
      name: name ?? this.name,
      medicine: medicine ?? this.medicine,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}