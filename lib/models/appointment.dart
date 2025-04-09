import 'package:flutter/material.dart';
import 'package:medical_storage/models/appointment_status.dart';

class Appointment {
  final int id;
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? serviceBooking;
  final Map<String, dynamic>? doctor;
  final Map<String, dynamic>? consultation;
  final String appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Appointment({
    required this.id,
    this.patient,
    this.serviceBooking,
    this.doctor,
    this.consultation,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patient: json['patient'],
      serviceBooking: json['serviceBooking'],
      doctor: json['doctor'],
      consultation: json['consultation'],
      appointmentDate: json['appointmentDate'],
      appointmentTime: json['appointmentTime'],
      status: json['status'],
      notes: json['notes'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  // Getters for convenience
  String get doctorName => doctor?['user']?['fullName'] ?? 'Unknown Doctor';
  String get doctorSpecialty => doctor?['specialization'] ?? 'General';
  String get doctorAvatar => doctor?['user']?['avatar'] ?? '';
  String get serviceName => serviceBooking?['service']?['name'] ?? 'General Consultation';
  double get price => (serviceBooking?['totalPrice'] ?? 0).toDouble();
  bool get hasPrescription => false; // Add logic if the API provides this information
  String get paymentMethod => serviceBooking?['paymentMethod'] ?? 'Unknown';
  String get serviceDescription => serviceBooking?['service']?['description'] ?? '';
  String get consultationLink => consultation?['consultationLink'] ?? '';
  String get consultationStatus => consultation?['status'] ?? 'PENDING';

  AppointmentStatus getAppointmentStatus() {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppointmentStatus.SCHEDULED;
      case 'completed':
        return AppointmentStatus.COMPLETED;
      case 'cancelled':
        return AppointmentStatus.CANCELLED;
      case 'pending':
        return AppointmentStatus.PENDING;
      default:
      // Try to infer status from serviceBooking if available
        if (serviceBooking != null) {
          final bookingStatus = serviceBooking?['status']?.toLowerCase() ?? '';
          if (bookingStatus == 'cancelled') {
            return AppointmentStatus.CANCELLED;
          } else if (bookingStatus == 'completed') {
            return AppointmentStatus.COMPLETED;
          } else if (bookingStatus == 'pending') {
            return AppointmentStatus.PENDING;
          }
        }

        // Default case if we can't determine status
        return AppointmentStatus.SCHEDULED;
    }
  }

  DateTime parseAppointmentDate() {
    try {
      return DateTime.parse(appointmentDate);
    } catch (e) {
      return DateTime.now();
    }
  }

  TimeOfDay parseAppointmentTime() {
    try {
      final components = appointmentTime.split(':');
      return TimeOfDay(
        hour: int.parse(components[0]),
        minute: int.parse(components[1]),
      );
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  bool isUpcoming() {
    final now = DateTime.now();
    final appointmentDateTime = DateTime.parse('$appointmentDate $appointmentTime');
    return appointmentDateTime.isAfter(now) &&
        status.toLowerCase() != 'cancelled' &&
        status.toLowerCase() != 'completed';
  }

  bool isCompleted() {
    return status.toLowerCase() == 'completed' ||
        (serviceBooking != null && serviceBooking?['status']?.toLowerCase() == 'completed');
  }

  bool isCancelled() {
    return status.toLowerCase() == 'cancelled' ||
        (serviceBooking != null && serviceBooking?['status']?.toLowerCase() == 'cancelled');
  }
}