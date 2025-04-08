import 'package:medical_storage/models/base_entity.dart';
import 'package:medical_storage/models/social_account.dart';
import 'package:medical_storage/models/user_role.dart';

class User extends BaseEntity {
  final String fullName;
  final String? phone;
  final String? avatar;
  final String? address;
  final String email;
  final DateTime? lastLogin;
  final int countLock;
  final String password;
  final bool enabled;
  final bool locked;
  final List<UserRole>? userRoles;
  final List<SocialAccount>? socialAccounts;

  User({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.fullName,
    this.phone,
    this.avatar,
    this.address,
    required this.email,
    this.lastLogin,
    this.countLock = 0,
    required this.password,
    this.enabled = true,
    this.locked = false,
    this.userRoles,
    this.socialAccounts,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      isDeleted: json['isDeleted'],
      fullName: json['fullName'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      address: json['address'],
      email: json['email'] ?? '',
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      countLock: json['countLock'] ?? 0,
      password: json['password'] ?? '',
      enabled: json['enabled'] ?? true,
      locked: json['locked'] ?? false,
      userRoles: json['userRoles'] != null
          ? List<UserRole>.from(json['userRoles'].map((x) => UserRole.fromJson(x)))
          : null,
      socialAccounts: json['socialAccounts'] != null
          ? List<SocialAccount>.from(json['socialAccounts'].map((x) => SocialAccount.fromJson(x)))
          : null,
    );
  }


  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'address': address,
      'email': email,
      'lastLogin': lastLogin?.toIso8601String(),
      'countLock': countLock,
      'password': password,
      'enabled': enabled,
      'locked': locked,
      'userRoles': userRoles?.map((x) => x.toJson()).toList(),
      'socialAccounts': socialAccounts?.map((x) => x.toJson()).toList(),
    });
    return data;
  }

  User copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? fullName,
    String? phone,
    String? avatar,
    String? address,
    String? email,
    DateTime? lastLogin,
    int? countLock,
    String? password,
    bool? enabled,
    bool? locked,
    List<UserRole>? userRoles,
    List<SocialAccount>? socialAccounts,
  }) {
    return User(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      address: address ?? this.address,
      email: email ?? this.email,
      lastLogin: lastLogin ?? this.lastLogin,
      countLock: countLock ?? this.countLock,
      password: password ?? this.password,
      enabled: enabled ?? this.enabled,
      locked: locked ?? this.locked,
      userRoles: userRoles ?? this.userRoles,
      socialAccounts: socialAccounts ?? this.socialAccounts,
    );
  }
}