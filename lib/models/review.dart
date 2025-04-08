import 'base_entity.dart';
import 'user.dart';
import 'doctor_profile.dart';
import 'medicine.dart';
import 'service.dart';

class Review extends BaseEntity {
  final User user;
  final int rating;
  final String? comment;
  final DoctorProfile? doctor;
  final Medicine? medicine;
  final Service? service;

  Review({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.user,
    required this.rating,
    this.comment,
    this.doctor,
    this.medicine,
    this.service,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      user: User.fromJson(json['user']),
      rating: json['rating'],
      comment: json['comment'],
      doctor: json['doctor'] != null ? DoctorProfile.fromJson(json['doctor']) : null,
      medicine: json['medicine'] != null ? Medicine.fromJson(json['medicine']) : null,
      service: json['service'] != null ? Service.fromJson(json['service']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'user': user.toJson(),
      'rating': rating,
      'comment': comment,
      'doctor': doctor?.toJson(),
      'medicine': medicine?.toJson(),
      'service': service?.toJson(),
    });
    return data;
  }

  Review copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    User? user,
    int? rating,
    String? comment,
    DoctorProfile? doctor,
    Medicine? medicine,
    Service? service,
  }) {
    return Review(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      user: user ?? this.user,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      doctor: doctor ?? this.doctor,
      medicine: medicine ?? this.medicine,
      service: service ?? this.service,
    );
  }
}