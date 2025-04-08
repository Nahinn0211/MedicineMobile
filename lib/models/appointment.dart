

import 'package:medical_storage/models/base_entity.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/models/patient_profile.dart';

class Appointment extends BaseEntity {
  final PatientProfile patient;
  final DoctorProfile doctor;
  final DateTime appointmentDate;
  final String appointmentTime;

  Appointment({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,

    String? updatedBy,
    bool? isDeleted,
    required this.patient,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      patient: PatientProfile.fromJson(json['patient']),
      doctor: DoctorProfile.fromJson(json['doctor']),
      appointmentDate: DateTime.parse(json['appointmentDate']),
      appointmentTime: json['appointmentTime'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'patient': patient.toJson(),
      'doctor': doctor.toJson(),
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
    });
    return data;
  }

  Appointment copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    PatientProfile? patient,
    DoctorProfile? doctor,
    DateTime? appointmentDate,
    String? appointmentTime,
  }) {
    return Appointment(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      patient: patient ?? this.patient,
      doctor: doctor ?? this.doctor,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
    );
  }
}