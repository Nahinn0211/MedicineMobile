import 'package:medical_storage/models/booking_status.dart';
import 'package:medical_storage/models/payment_method.dart';

import 'base_entity.dart';
import 'service.dart';
import 'patient_profile.dart';

class ServiceBooking extends BaseEntity {
  final Service service;
  final PatientProfile patient;
  final double totalPrice;
  final PaymentMethod paymentMethod;
  final BookingStatus status;

  ServiceBooking({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    required this.service,
    required this.patient,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    createdBy: createdBy,
    updatedBy: updatedBy,
    isDeleted: isDeleted,
  );

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      isDeleted: json['isDeleted'],
      service: Service.fromJson(json['service']),
      patient: PatientProfile.fromJson(json['patient']),
      totalPrice: json['totalPrice'].toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == json['paymentMethod'],
      ),
      status: BookingStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toUpperCase() == json['status'],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'service': service.toJson(),
      'patient': patient.toJson(),
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod.toString().split('.').last.toUpperCase(),
      'status': status.toString().split('.').last.toUpperCase(),
    });
    return data;
  }

  ServiceBooking copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    Service? service,
    PatientProfile? patient,
    double? totalPrice,
    PaymentMethod? paymentMethod,
    BookingStatus? status,
  }) {
    return ServiceBooking(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      service: service ?? this.service,
      patient: patient ?? this.patient,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
    );
  }
}