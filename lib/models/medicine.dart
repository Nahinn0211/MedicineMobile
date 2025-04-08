import 'package:medical_storage/models/medicine_media.dart';

import 'attribute.dart';
import 'base_entity.dart';
import 'brand.dart';

class Medicine extends BaseEntity {
  final String code;
  final String name;
  final String brandId;
  final Brand? brand;
  final String? origin;
  final String? manufacturer;
  final String? description;
  final List<Attribute> attributes;
  final List<MedicineMedia> media;

  Medicine( {
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.code,
    required this.name,
    this.brand,
    required this.brandId,
    this.origin,
    this.manufacturer,
    this.description,
    this.attributes = const [],
    this.media = const [],
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id']?.toString(),
      brandId: json['brandId']!.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      code: json['code'],
      name: json['name'],
      origin: json['origin'],
      manufacturer: json['manufacturer'],
      description: json['description'],
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => Attribute.fromJson(attr))
          .toList() ??
          [],
      media: (json['media'] as List<dynamic>?)
          ?.map((attr) => MedicineMedia.fromJson(attr))
          .toList() ??
          [],
    );
  }
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'code': code,
      'name': name,
      'brandId': brandId,
      'brand': brand?.toJson(),
      'origin': origin,
      'manufacturer': manufacturer,
      'description': description,
    });
    return data;
  }

  Medicine copyWith({
    String? id,
    String? brandId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? code,
    String? name,
    Brand? brand,
    String? origin,
    String? manufacturer,
    String? description,
    List<Attribute>? attributes,
    List<MedicineMedia>? media,
  }) {
    return Medicine(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      code: code ?? this.code,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      origin: origin ?? this.origin,
      manufacturer: manufacturer ?? this.manufacturer,
      description: description ?? this.description,
      attributes: attributes ?? this.attributes,
      media: media ?? this.media,
    );
  }
}


