import 'package:medical_storage/models/media_type.dart';

import 'base_entity.dart';
import 'medicine.dart';

class MedicineMedia extends BaseEntity {
  final Medicine medicine;
  final MediaType mediaType;
  final String mediaUrl;
  final bool mainImage;

  MedicineMedia({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.medicine,
    required this.mediaType,
    required this.mediaUrl,
    required this.mainImage,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory MedicineMedia.fromJson(Map<String, dynamic> json) {
    // Kiểm tra và xử lý trường hợp medicine có thể là Map hoặc null
    dynamic medicineData = json['medicine'];
    Medicine? medicine;

    if (medicineData is Map<String, dynamic>) {
      medicine = Medicine.fromJson(medicineData);
    } else if (medicineData is String) {
      // Nếu là ID của medicine
      medicine = Medicine(id: medicineData, code: '', name: '', brandId: '');
    }

    // Xử lý mediaType an toàn
    MediaType mediaTypeValue = MediaType.image; // Giá trị mặc định
    try {
      if (json['mediaType'] != null) {
        mediaTypeValue = MediaType.values.firstWhere(
              (e) => e.toString().split('.').last.toUpperCase() ==
              json['mediaType'].toString().toUpperCase(),
          orElse: () => MediaType.image,
        );
      }
    } catch (e) {
      print('Lỗi parse mediaType: $e');
    }

    return MedicineMedia(
      id: json['id']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      medicine: medicine ?? Medicine(code: '', name: '', brandId: ''), // Fallback giá trị
      mediaType: mediaTypeValue,
      mediaUrl: json['mediaUrl'] ?? '',
      mainImage: json['mainImage'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'medicine': medicine.toJson(),
      'mediaType': mediaType.toString().split('.').last.toUpperCase(),
      'mediaUrl': mediaUrl,
      'mainImage': mainImage,
    });
    return data;
  }

  MedicineMedia copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    Medicine? medicine,
    MediaType? mediaType,
    String? mediaUrl,
    bool? mainImage,
  }) {
    return MedicineMedia(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      medicine: medicine ?? this.medicine,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mainImage: mainImage ?? this.mainImage,
    );
  }
}