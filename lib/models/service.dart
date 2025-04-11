import 'package:medical_storage/models/doctor_profile.dart';
import 'base_entity.dart';

class Service extends BaseEntity {
  final String name;
  final String? image;
  final double price;
  final String? description;
  final List<DoctorProfile>? doctors;

  Service({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.name,
    required this.price,
    this.image,
    this.description,
    this.doctors,
  }
      ) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Service.fromJson(Map<String, dynamic> json) {
    // Handle the current API response format (single doctorProfile)
    List<DoctorProfile> doctorsList = [];
    if (json['doctorProfile'] != null) {
      doctorsList.add(DoctorProfile.fromJson(json['doctorProfile']));
    }

    // Also handle if the API returns doctors as a list in the future
    if (json['doctors'] != null && json['doctors'] is List) {
      doctorsList = (json['doctors'] as List)
          .map((doctor) => DoctorProfile.fromJson(doctor))
          .toList();
    }

    return Service(
      id: json['id'] != null ? json['id'].toString() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      isDeleted: json['isDeleted'],
      name: json['name'],
      image: json['image'],
      price: json['price'] is int ? (json['price'] as int).toDouble() : json['price'],
      description: json['description'],
      doctors: doctorsList.isEmpty ? null : doctorsList,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'name': name,
      'price': price,
      'description': description,
      'image': image,
    });

    if (doctors != null && doctors!.isNotEmpty) {
      // For backward compatibility with current API
      data['doctorProfile'] = doctors!.first.toJson();

      // For future API version that might support multiple doctors
      data['doctors'] = doctors!.map((doctor) => doctor.toJson()).toList();
    }

    return data;
  }

  Service copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? name,
    String? image,
    double? price,
    String? description,
    List<DoctorProfile>? doctors,
  }) {
    return Service(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      description: description ?? this.description,
      doctors: doctors ?? this.doctors,
    );
  }
}