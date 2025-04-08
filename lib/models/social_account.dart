import 'package:medical_storage/models/base_entity.dart';
import 'package:medical_storage/models/social_provider.dart';
import 'package:medical_storage/models/user.dart';

class SocialAccount extends BaseEntity {
  final User user;
  final SocialProvider provider;
  final String providerId;
  final String? providerEmail;
  final String? name;
  final String? avatarUrl;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;

  SocialAccount({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.user,
    required this.provider,
    required this.providerId,
    this.providerEmail,
    this.name,
    this.avatarUrl,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      user: User.fromJson(json['user']),
      provider: SocialProvider.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == json['provider'],
      ),
      providerId: json['providerId'],
      providerEmail: json['providerEmail'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenExpiresAt: json['tokenExpiresAt'] != null ? DateTime.parse(json['tokenExpiresAt']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'user': user.toJson(),
      'provider': provider.toString().split('.').last.toUpperCase(),
      'providerId': providerId,
      'providerEmail': providerEmail,
      'name': name,
      'avatarUrl': avatarUrl,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
    });
    return data;
  }

  SocialAccount copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    User? user,
    SocialProvider? provider,
    String? providerId,
    String? providerEmail,
    String? name,
    String? avatarUrl,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return SocialAccount(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      user: user ?? this.user,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      providerEmail: providerEmail ?? this.providerEmail,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
  }
}