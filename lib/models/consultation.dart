import 'package:medical_storage/models/base_entity.dart';
import 'package:medical_storage/models/consultation_status.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/models/patient_profile.dart';

class Consultation extends BaseEntity {
  final PatientProfile patient;
  final DoctorProfile doctor;
  final String? consultationLink;
  final ConsultationStatus status;

  Consultation({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.patient,
    required this.doctor,
    this.consultationLink,
    required this.status,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      patient: PatientProfile.fromJson(json['patient']),
      doctor: DoctorProfile.fromJson(json['doctor']),
      consultationLink: json['consultationLink'],
      status: ConsultationStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'patient': patient.toJson(),
      'doctor': doctor.toJson(),
      'consultationLink': consultationLink,
      'status': status.toString().split('.').last.toUpperCase(),
    });
    return data;
  }

  Consultation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    PatientProfile? patient,
    DoctorProfile? doctor,
    String? consultationLink,
    ConsultationStatus? status,
  }) {
    return Consultation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      patient: patient ?? this.patient,
      doctor: doctor ?? this.doctor,
      consultationLink: consultationLink ?? this.consultationLink,
      status: status ?? this.status,
    );
  }
}