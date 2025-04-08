import 'package:medical_storage/models/base_entity.dart';

class Brand extends BaseEntity {
  final String name;
  final String? image;

  Brand({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.name,
    this.image,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Brand.fromJson(Map<String, dynamic> json) {

    return Brand(
      id: json['id']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      isDeleted: json['isDeleted'] is bool ? json['isDeleted'] : false,
      name: json['name']?.toString() ?? 'Chưa xác định',
      image: json['image']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'name': name,
      'image': image,
    });
    return data;
  }

  Brand copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? name,
    String? image,
  }) {
    return Brand(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }
}