import 'base_entity.dart';
import 'user.dart';

class PatientProfile extends BaseEntity {
  final User user;
  final String? bloodType;
  final String? medicalHistory;
  final String? allergies;
  final double? accountBalance;

  PatientProfile({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.user,
    this.bloodType,
    this.medicalHistory,
    this.allergies,
    this.accountBalance,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      user: User.fromJson(json['user']),
      bloodType: json['bloodType'],
      medicalHistory: json['medicalHistory'],
      allergies: json['allergies'],
      accountBalance: json['accountBalance'] != null ? json['accountBalance'].toDouble() : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'user': user.toJson(),
      'bloodType': bloodType,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'accountBalance': accountBalance,
    });
    return data;
  }

  PatientProfile copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    User? user,
    String? bloodType,
    String? medicalHistory,
    String? allergies,
    double? accountBalance,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      user: user ?? this.user,
      bloodType: bloodType ?? this.bloodType,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      accountBalance: accountBalance ?? this.accountBalance,
    );
  }
}