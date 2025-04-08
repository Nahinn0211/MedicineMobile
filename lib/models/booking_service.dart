import 'base_entity.dart';
import 'service.dart';
import 'doctor_profile.dart';

class DoctorService extends BaseEntity {
  final Service service;
  final DoctorProfile doctor;

  DoctorService({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.service,
    required this.doctor,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory DoctorService.fromJson(Map<String, dynamic> json) {
    return DoctorService(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      service: Service.fromJson(json['service']),
      doctor: DoctorProfile.fromJson(json['doctor']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'service': service.toJson(),
      'doctor': doctor.toJson(),
    });
    return data;
  }

  DoctorService copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    Service? service,
    DoctorProfile? doctor,
  }) {
    return DoctorService(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      service: service ?? this.service,
      doctor: doctor ?? this.doctor,
    );
  }
}