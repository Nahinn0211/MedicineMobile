import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/appointment.dart';
import 'base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AppointmentService extends BaseService<Appointment> {
  AppointmentService() : super(
      endpoint: 'appointments',
      fromJson: Appointment.fromJson
  );

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Appointment>> getAppointmentsByPatient(String patientId) async {
    try {
      // Thêm header Authorization nếu cần
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/appointments/patient/$patientId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Xử lý response
        final String decodedBody = utf8.decode(response.bodyBytes);

        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is List) {
          final appointments = <Appointment>[];

          for (var i = 0; i < parsedJson.length; i++) {
            try {
              final item = parsedJson[i];
              if (item is Map<String, dynamic>) {
                final appointment = Appointment.fromJson(item);
                appointments.add(appointment);
              }
            } catch (e) {
              print('Error parsing appointment at index $i: $e');
              // Tiếp tục với item tiếp theo thay vì dừng toàn bộ quá trình
            }
          }

          return appointments;
        } else {
          throw Exception('Expected List but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load appointments: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getAppointmentsByPatient: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error loading appointments: $e');
      }
    }
  }

  Future<bool> cancelAppointment(String? serviceBookingId) async {
    // Validate input
    if (serviceBookingId == null || serviceBookingId.isEmpty) {
      throw Exception('Invalid booking ID');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service-bookings/cancel/$serviceBookingId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      // Log response code for debugging
      print('Cancel response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found: $serviceBookingId');
      } else if (response.statusCode == 403) {
        throw Exception('Not allowed to cancel this booking');
      } else {
        // Include response body in error for better debugging
        String responseBody = utf8.decode(response.bodyBytes);
        throw Exception('Server error (${response.statusCode}): $responseBody');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else if (e is Exception) {
        rethrow; // Rethrow already formatted exceptions
      } else {
        throw Exception('Error canceling appointment: $e');
      }
    }
  }

  // Helper function to get minimum of two integers
  int min(int a, int b) => a < b ? a : b;
}