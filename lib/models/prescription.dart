import 'base_entity.dart';
import 'doctor_profile.dart';
import 'patient_profile.dart';
import 'medicine.dart';

class Prescription extends BaseEntity {
  final Medicine medicine;
  final String dosage;

  Prescription({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.medicine,
    required this.dosage,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] != null ? json['id'].toString() : '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      medicine: Medicine.fromJson(json['medicine']),
      dosage: json['dosage'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'medicine': medicine.toJson(),
      'dosage': dosage,
    });
    return data;
  }

  Prescription copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    Medicine? medicine,
    String? dosage,
  }) {
    return Prescription(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      medicine: medicine ?? this.medicine,
      dosage: dosage ?? this.dosage,
    );
  }
}