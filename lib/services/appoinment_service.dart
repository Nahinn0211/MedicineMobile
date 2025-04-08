import 'dart:convert';

import 'base_service.dart';
import 'package:medical_storage/models/appointment.dart';
import 'package:http/http.dart' as http;

class AppointmentService extends BaseService<Appointment> {
  AppointmentService() : super(
      endpoint: 'appointments',
      fromJson: Appointment.fromJson
  );

  Future<List<Appointment>> getAppointmentsByPatient(String patientId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/appointments/patient/$patientId')
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Appointment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load appointments for patient $patientId');
    }
  }

  Future<List<Appointment>> getAppointmentsByDoctor(String doctorId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/appointments/doctor/$doctorId')
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Appointment.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load appointments for doctor $doctorId');
    }
  }
}