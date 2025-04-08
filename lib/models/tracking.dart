import 'package:medical_storage/models/tracking_status.dart';

import 'base_entity.dart';
import 'order.dart';

class Tracking extends BaseEntity {
  final Order order;
  final String location;
  final String? message;
  final TrackingStatus status;

  Tracking({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.order,
    required this.location,
    this.message,
    required this.status,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      order: Order.fromJson(json['order']),
      location: json['location'],
      message: json['message'],
      status: TrackingStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'order': order.toJson(),
      'location': location,
      'message': message,
      'status': status.toString().split('.').last.toUpperCase(),
    });
    return data;
  }

  Tracking copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    Order? order,
    String? location,
    String? message,
    TrackingStatus? status,
  }) {
    return Tracking(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      location: location ?? this.location,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }
}