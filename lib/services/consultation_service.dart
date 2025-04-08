import 'dart:convert';

import 'base_service.dart';
import 'package:medical_storage/models/consultation.dart';
import 'package:medical_storage/models/consultation_status.dart';
import 'package:http/http.dart' as http;

class ConsultationService extends BaseService<Consultation> {
  ConsultationService() : super(
      endpoint: 'consultations',
      fromJson: Consultation.fromJson
  );

  Future<List<Consultation>> getConsultationsByPatient(String patientId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/consultations/patient/$patientId')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Consultation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load consultations for patient $patientId');
    }
  }

  Future<List<Consultation>> getConsultationsByDoctor(String doctorId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/consultations/doctor/$doctorId')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Consultation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load consultations for doctor $doctorId');
    }
  }

  Future<List<Consultation>> getConsultationsByStatus(ConsultationStatus status) async {
    final response = await http.get(
        Uri.parse('$baseUrl/consultations/status/${status.toString().split('.').last.toUpperCase()}')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Consultation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load consultations with status $status');
    }
  }
}