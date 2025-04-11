import 'package:flutter/material.dart';
import 'package:medical_storage/models/appointment_status.dart';
import 'package:medical_storage/models/consultation.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/models/prescription.dart';
import 'package:medical_storage/models/service_booking.dart';

class Appointment {
  final String id;
  final PatientProfile? patient;
  final ServiceBooking? serviceBooking;
  final DoctorProfile? doctor;
  final Consultation? consultation;
  final List<Prescription> prescriptions;
  final String appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  Appointment({
    required this.id,
    this.patient,
    this.serviceBooking,
    this.doctor,
    this.consultation,
    required this.prescriptions,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      // Xử lý status dưới dạng enum
      AppointmentStatus statusEnum;
      if (json['status'] != null) {
        final statusString = json['status'].toString().toUpperCase();
        statusEnum = AppointmentStatus.values.firstWhere(
                (e) => e.toString().split('.').last == statusString,
            orElse: () => AppointmentStatus.SCHEDULED // Giá trị mặc định
        );
      } else {
        statusEnum = AppointmentStatus.SCHEDULED;
      }

      return Appointment(
        id: json['id']?.toString() ?? '',

        patient: json['patient'] != null && json['patient'] is Map<String, dynamic>
            ? PatientProfile.fromJson(json['patient'] as Map<String, dynamic>)
            : null,

        doctor: json['doctor'] != null && json['doctor'] is Map<String, dynamic>
            ? DoctorProfile.fromJson(json['doctor'] as Map<String, dynamic>)
            : null,

        serviceBooking: json['serviceBooking'] != null && json['serviceBooking'] is Map<String, dynamic>
            ? ServiceBooking.fromJson(json['serviceBooking'] as Map<String, dynamic>)
            : null,

        consultation: json['consultation'] != null
            ? (() {
          try {
            return Consultation.fromJson(json['consultation']);
          } catch (e) {
            print('Lỗi khi tạo Consultation: $e');
            print('JSON gây lỗi: ${json['consultation']}');
            return null;
          }
        })()
            : null,

        appointmentDate: json['appointmentDate']?.toString() ?? '',
        appointmentTime: json['appointmentTime']?.toString() ?? '',

        // Sử dụng enum thay vì string
        status: statusEnum,

        notes: json['notes']?.toString(),

        // Handle prescription list with null safety
        prescriptions: (json['prescriptions'] as List<dynamic>?)
            ?.map((pres) => Prescription.fromJson(pres as Map<String, dynamic>))
            .toList() ?? [],

        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
      );
    } catch (e, stack) {
      print('Error in Appointment.fromJson: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Convert appointment to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'status': status,
      'notes': notes,
      // Only include non-null nested objects
      if (patient != null) 'patientId': patient?.id,
      if (doctor != null) 'doctorId': doctor?.id,
      if (serviceBooking != null) 'serviceBookingId': serviceBooking?.id,
      if (consultation != null) 'consultationId': consultation?.id,
    };
  }

  bool isUpcoming() {
    try {
      final now = DateTime.now();
      final appointmentDateTime = _combineDateAndTime();
      return appointmentDateTime.isAfter(now) &&
          status == AppointmentStatus.SCHEDULED;
    } catch (e) {
      print('Error checking if appointment is upcoming: $e');
      return false;
    }
  }

  AppointmentStatus getDisplayStatus() {
    // Nếu trạng thái đã là COMPLETED hoặc CANCELLED, giữ nguyên
    if (status == AppointmentStatus.COMPLETED ||
        status == AppointmentStatus.CANCELLED) {
      return status;
    }

    // Kiểm tra nếu cuộc hẹn SCHEDULED đã qua
    final now = DateTime.now();
    final appointmentDateTime = _combineDateAndTime();

    if (status == AppointmentStatus.SCHEDULED &&
        appointmentDateTime.isBefore(now)) {
      // Cuộc hẹn đã qua nhưng chưa được cập nhật trạng thái
      // Có thể hiển thị trong một tab riêng "Đã quá hạn" hoặc xử lý khác
      return AppointmentStatus.PENDING; // Hoặc tạo enum mới OVERDUE
    }

    return status;
  }

  DateTime parseAppointmentDate() {
    try {
      return DateTime.parse(appointmentDate);
    } catch (e) {
      // Log error for debugging purposes
      print('Error parsing appointment date: $e');
      return DateTime.now();
    }
  }

  TimeOfDay parseAppointmentTime() {
    try {
      final components = appointmentTime.split(':');
      if (components.length >= 2) {
        return TimeOfDay(
          hour: int.parse(components[0]),
          minute: int.parse(components[1]),
        );
      }
      throw FormatException('Invalid time format');
    } catch (e) {
      // Log error for debugging purposes
      print('Error parsing appointment time: $e');
      return TimeOfDay.now();
    }
  }

  // Helper method to combine date and time
  DateTime _combineDateAndTime() {
    try {
      final date = parseAppointmentDate();
      final time = parseAppointmentTime();
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    } catch (e) {
      print('Error combining date and time: $e');
      return DateTime.now();
    }
  }
}