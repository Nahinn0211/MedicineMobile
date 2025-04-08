import 'package:medical_storage/models/user_role.dart';
import 'package:medical_storage/models/base_entity.dart';

class Role extends BaseEntity {
  final String name;
  final List<UserRole>? userRoles;

  Role({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.name,
    this.userRoles,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      name: json['name'],
      userRoles: json['userRoles'] != null
          ? List<UserRole>.from(json['userRoles'].map((x) => UserRole.fromJson(x)))
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'name': name,
      'userRoles': userRoles?.map((x) => x.toJson()).toList(),
    });
    return data;
  }

  Role copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? name,
    List<UserRole>? userRoles,
  }) {
    return Role(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      userRoles: userRoles ?? this.userRoles,
    );
  }
}