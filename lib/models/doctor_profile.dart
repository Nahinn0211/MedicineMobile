import 'package:medical_storage/models/base_entity.dart';
import 'package:medical_storage/models/user.dart';
import 'package:medical_storage/models/review.dart'; // You'll need to create this model

class DoctorProfile extends BaseEntity {
  final int? userId;  // Changed to int to match JSON structure
  final User user;
  final String? experience;
  final String? specialization;
  final String? workplace;
  final double? accountBalance;
  final String? certifications;
  final String? biography;
  final String? availableFrom;
  final String? availableTo;
  final bool isAvailable;
  final int uniquePatientCount;
  final int totalConsultationCount;
  final double averageRating;
  final List<Review> reviews;

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
    this.certifications,
    this.biography,
    this.availableFrom,
    this.availableTo,
    this.isAvailable = false,
    this.uniquePatientCount = 0,
    this.totalConsultationCount = 0,
    this.averageRating = 0,
    this.reviews = const [],
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
      id: json['id'] != null ? json['id'].toString() : null,
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      isDeleted: json['isDeleted'],
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : User(fullName: '', email: '', password: ''), // Assuming these are required in User
      experience: json['experience'],
      specialization: json['specialization'],
      workplace: json['workplace'],
      accountBalance: json['accountBalance'] != null
          ? (json['accountBalance'] is int
          ? (json['accountBalance'] as int).toDouble()
          : json['accountBalance'])
          : null,
      certifications: json['certifications'],
      biography: json['biography'],
      availableFrom: json['availableFrom'],
      availableTo: json['availableTo'],
      isAvailable: json['isAvailable'] ?? false,
      uniquePatientCount: json['uniquePatientCount'] ?? 0,
      totalConsultationCount: json['totalConsultationCount'] ?? 0,
      averageRating: json['averageRating'] != null
          ? (json['averageRating'] is int
          ? (json['averageRating'] as int).toDouble()
          : json['averageRating'])
          : 0.0,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((review) => Review.fromJson(review)).toList()
          : [],
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
      'certifications': certifications,
      'biography': biography,
      'availableFrom': availableFrom,
      'availableTo': availableTo,
      'isAvailable': isAvailable,
      'uniquePatientCount': uniquePatientCount,
      'totalConsultationCount': totalConsultationCount,
      'averageRating': averageRating,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    });
    return data;
  }

  DoctorProfile copyWith({
    String? id,
    int? userId,
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
    String? certifications,
    String? biography,
    String? availableFrom,
    String? availableTo,
    bool? isAvailable,
    int? uniquePatientCount,
    int? totalConsultationCount,
    double? averageRating,
    List<Review>? reviews,
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
      certifications: certifications ?? this.certifications,
      biography: biography ?? this.biography,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      isAvailable: isAvailable ?? this.isAvailable,
      uniquePatientCount: uniquePatientCount ?? this.uniquePatientCount,
      totalConsultationCount: totalConsultationCount ?? this.totalConsultationCount,
      averageRating: averageRating ?? this.averageRating,
      reviews: reviews ?? this.reviews,
    );
  }
}