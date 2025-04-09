import 'package:medical_storage/models/base_entity.dart';

class Attribute extends BaseEntity {
  final String name;
  final double priceIn;
  final double priceOut;
  final int stock;
  final DateTime? expiryDate;

  Attribute({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.name,
    required this.priceIn,
    required this.priceOut,
    required this.stock,
    this.expiryDate,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'] != null ? json['id'].toString() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      name: json['name'],
      priceIn: json['priceIn'].toDouble(),
      priceOut: json['priceOut'].toDouble(),
      stock: json['stock'],
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'name': name,
      'priceIn': priceIn,
      'priceOut': priceOut,
      'stock': stock,
      'expiryDate': expiryDate?.toIso8601String(),
    });
    return data;
  }

  Attribute copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? name,
    double? priceIn,
    double? priceOut,
    int? stock,
    DateTime? expiryDate,
  }) {
    return Attribute(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      priceIn: priceIn ?? this.priceIn,
      priceOut: priceOut ?? this.priceOut,
      stock: stock ?? this.stock,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}