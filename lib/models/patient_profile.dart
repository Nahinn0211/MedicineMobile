import 'package:medical_storage/models/blood_type.dart';

import 'base_entity.dart';
import 'user.dart';

class PatientProfile extends BaseEntity {
  final User user;
  final BloodType? bloodType;
  final String? medicalHistory;
  final String? allergies;
  final double? accountBalance;
  final int? completedAppointmentsCount;
  final int? completedConsultationsCount;
  final bool? hasMedicalHistory;
  final bool? hasAllergies;

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
    this.completedAppointmentsCount,
    this.completedConsultationsCount,
    this.hasMedicalHistory,
    this.hasAllergies,
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
      id: json['id']?.toString(), // Chuyển id sang string
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      isDeleted: json['isDeleted'] is bool ? json['isDeleted'] : null,
      user: User.fromJson(json['user']),
      bloodType: BloodType.fromString(json['bloodType']),
      medicalHistory: json['medicalHistory']?.toString(),
      allergies: json['allergies']?.toString(),
      accountBalance: json['accountBalance'] != null
          ? double.tryParse(json['accountBalance'].toString())
          : null,
      completedAppointmentsCount: json['completedAppointmentsCount'] is int
          ? json['completedAppointmentsCount']
          : null,
      completedConsultationsCount: json['completedConsultationsCount'] is int
          ? json['completedConsultationsCount']
          : null,
      hasMedicalHistory: json['hasMedicalHistory'] is bool
          ? json['hasMedicalHistory']
          : null,
      hasAllergies: json['hasAllergies'] is bool
          ? json['hasAllergies']
          : null,
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
      'completedAppointmentsCount': completedAppointmentsCount,
      'completedConsultationsCount': completedConsultationsCount,
      'hasMedicalHistory': hasMedicalHistory,
      'hasAllergies': hasAllergies,
    });
    return data;
  }

  // Phần copyWith giữ nguyên, chỉ bổ sung các trường mới
  PatientProfile copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    User? user,
    BloodType? bloodType,
    String? medicalHistory,
    String? allergies,
    double? accountBalance,
    int? completedAppointmentsCount,
    int? completedConsultationsCount,
    bool? hasMedicalHistory,
    bool? hasAllergies,
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
      completedAppointmentsCount: completedAppointmentsCount ?? this.completedAppointmentsCount,
      completedConsultationsCount: completedConsultationsCount ?? this.completedConsultationsCount,
      hasMedicalHistory: hasMedicalHistory ?? this.hasMedicalHistory,
      hasAllergies: hasAllergies ?? this.hasAllergies,
    );
  }
}