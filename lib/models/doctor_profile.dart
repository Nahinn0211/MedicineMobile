import 'package:medical_storage/models/base_entity.dart';
import 'package:medical_storage/models/user.dart';

class DoctorProfile extends BaseEntity {
  final String? userId;
  final User user;
  final String? experience;
  final String? specialization;
  final String? workplace;
  final double? accountBalance;

  DoctorProfile({
    String? id,
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.user,
    this.experience,
    this.specialization,
    this.workplace,
    this.accountBalance,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id']?.toString(), // 👈 ép int -> String
      userId: json['userId']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      isDeleted: json['isDeleted'],
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : User(fullName: '', email: '', password: ''),
      experience: json['experience'],
      specialization: json['specialization'],
      workplace: json['workplace'],
      accountBalance: json['accountBalance'] != null
          ? (json['accountBalance'] is int
          ? (json['accountBalance'] as int).toDouble()
          : (json['accountBalance'] as double?))
          : null,
    );
  }


  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'userId': userId,
      'user': user.toJson(),
      'experience': experience,
      'specialization': specialization,
      'workplace': workplace,
      'accountBalance': accountBalance,
    });
    return data;
  }

  DoctorProfile copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    User? user,
    String? experience,
    String? specialization,
    String? workplace,
    double? accountBalance,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      user: user ?? this.user,
      experience: experience ?? this.experience,
      specialization: specialization ?? this.specialization,
      workplace: workplace ?? this.workplace,
      accountBalance: accountBalance ?? this.accountBalance,
    );
  }
}