import 'package:medical_storage/models/medicine_media.dart';

import 'attribute.dart';
import 'base_entity.dart';
import 'brand.dart';
import 'category.dart';

class Medicine extends BaseEntity {
  final String code;
  final String name;
  final String brandId; // Đảm bảo luôn có giá trị
  final String? description;
  final String? usageInstruction;
  final String? dosageInstruction;
  final bool? isPrescriptionRequired;
  final int? totalStock;
  final double? minPrice;
  final double? maxPrice;
  final String? origin;
  final BrandBasic? brand;
  final List<Attribute> attributes;
  final List<Category> categories;
  final List<MedicineMedia> medias;

  Medicine({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.code,
    required this.name,
    required this.brandId, // Thêm required
    this.description,
    this.usageInstruction,
    this.dosageInstruction,
    this.isPrescriptionRequired,
    this.totalStock,
    this.minPrice,
    this.maxPrice,
    this.origin,
    this.brand,
    this.attributes = const [],
    this.categories = const [],
    this.medias = const [],
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
      id: json['id'] != null ? json['id'].toString() : null,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      brandId: json['brand'] != null ? json['brand']['id'].toString() : '',
      description: json['description'],
      usageInstruction: json['usageInstruction'],
      dosageInstruction: json['dosageInstruction'],
      isPrescriptionRequired: json['isPrescriptionRequired'],
      totalStock: json['totalStock'] != null
          ? int.tryParse(json['totalStock'].toString())
          : null,
      minPrice: json['minPrice'] != null
          ? double.tryParse(json['minPrice'].toString())
          : null,
      maxPrice: json['maxPrice'] != null
          ? double.tryParse(json['maxPrice'].toString())
          : null,
      origin: json['origin'],
      brand: json['brand'] != null
          ? BrandBasic(
          id: json['brand']['id'].toString(),
          name: json['brand']['name']
      )
          : null,
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => Attribute.fromJson(attr))
          .toList() ?? [],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((cat) => Category.fromJson(cat))
          .toList() ?? [],
      medias: (json['medias'] as List<dynamic>?)
          ?.map((media) => MedicineMedia.fromJson(media))
          .toList() ?? [],
    );
  }
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'code': code,
      'name': name,
      'brandId': brandId,
      'description': description,
      'usageInstruction': usageInstruction,
      'dosageInstruction': dosageInstruction,
      'isPrescriptionRequired': isPrescriptionRequired,
      'totalStock': totalStock,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'origin': origin,
      'brand': brand?.toJson(),
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'medias': medias.map((media) => media.toJson()).toList(),
    });
    return data;
  }

  Medicine copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? code,
    String? name,
    String? brandId,
    String? description,
    String? usageInstruction,
    String? dosageInstruction,
    bool? isPrescriptionRequired,
    int? totalStock,
    double? minPrice,
    double? maxPrice,
    String? origin,
    BrandBasic? brand,
    List<Attribute>? attributes,
    List<Category>? categories,
    List<MedicineMedia>? medias,
  }) {
    return Medicine(
      id: id ?? (this.id != null ? this.id.toString() : null),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      code: code ?? this.code,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId.toString(),
      description: description ?? this.description,
      usageInstruction: usageInstruction ?? this.usageInstruction,
      dosageInstruction: dosageInstruction ?? this.dosageInstruction,
      isPrescriptionRequired: isPrescriptionRequired ?? this.isPrescriptionRequired,
      totalStock: totalStock ?? this.totalStock,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      origin: origin ?? this.origin,
      brand: brand ?? this.brand,
      attributes: attributes ?? this.attributes,
      categories: categories ?? this.categories,
      medias: medias ?? this.medias,
    );
  }
}

// Tạo class BrandBasic tương ứng với BrandBasicDTO
class BrandBasic {
  final String? id;
  final String? name;

  BrandBasic({this.id, this.name});

  factory BrandBasic.fromJson(Map<String, dynamic> json) {
    return BrandBasic(
      id: json['id']?.toString(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}