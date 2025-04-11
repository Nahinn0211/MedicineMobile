import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/appointment.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookingService {
  final String baseUrl = 'http://192.168.1.250:8080/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Lấy danh sách những khung giờ đã đặt của bác sĩ trong ngày
  Future<List<String>> getDoctorBookedSlots(String doctorId, DateTime date) async {
    try {
      final token = await getToken();

      // Định dạng ngày thành chuỗi ISO
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final uri = Uri.parse('$baseUrl/appointments/booked-slots')
          .replace(queryParameters: {
        'doctorId': doctorId,
        'date': dateStr,
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results.map((slot) => slot.toString()).toList();
      } else {
        throw Exception('Server trả về lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy lịch đã đặt: $e');
    }
  }

  // Kiểm tra xem bác sĩ có khả dụng vào khung giờ cụ thể không
  Future<bool> checkDoctorAvailability(String doctorId, String date, String timeSlot) async {
    try {
      final token = await getToken();

      final uri = Uri.parse('$baseUrl/appointments/check-availability')
          .replace(queryParameters: {
        'doctorId': doctorId,
        'date': date,
        'timeSlot': timeSlot,
      });

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Backend trả về Boolean trực tiếp, không phải JSON
        if (response.body.toLowerCase() == 'true') {
          return true;
        } else if (response.body.toLowerCase() == 'false') {
          return false;
        } else {
          // Thử parse JSON nếu không phải là Boolean trực tiếp
          try {
            final result = json.decode(response.body);
            return result as bool;
          } catch (e) {
            throw Exception('Không thể phân tích kết quả: ${response.body}');
          }
        }
      } else {
        throw Exception('Server trả về lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra khả dụng: $e');
    }
  }

  // Tạo lịch đặt mới
  Future<Appointment> createBooking({
    required String serviceId,
    required String doctorId,
    required String patientId,
    required double totalPrice,
    required String paymentMethod,
    required String appointmentDate,
    required String appointmentTime,
  }) async {
    try {
      final token = await getToken();

      // Tạo DTO phù hợp với backend
      final Map<String, dynamic> bookingData = {
        'serviceId': serviceId,
        'doctorId': doctorId,
        'patientId': patientId,
        'totalPrice': totalPrice,
        'paymentMethod': paymentMethod,
        'status': 'PENDING',
        'appointmentDate': appointmentDate,
        'appointmentTime': appointmentTime,
      };

      // Sử dụng endpoint đúng như trong backend
      final response = await http.post(
        Uri.parse('$baseUrl/service-bookings/save'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(bookingData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Appointment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Server trả về lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo đặt lịch: $e');
    }
  }

  // Lấy thông tin số dư tài khoản
  Future<double> getAccountBalance(String userId) async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/patients/$userId/balance'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return (result['accountBalance'] as num).toDouble();
      } else {
        throw Exception('Server trả về lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy số dư tài khoản: $e');
    }
  }

  // Cập nhật số dư tài khoản sau khi thanh toán
  Future<PatientProfile?> updateAccountBalance(String id, String balance) async {
    try {
      final token = await getToken();

      print('$id, $balance'); // Log id và balance như method gốc

      final response = await http.put(
        Uri.parse('$baseUrl/patient-profiles/update/balance/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: json.encode({ 'balance': balance }),
      );

      if (response.statusCode == 200) {
        return PatientProfile.fromJson(json.decode(response.body));
      } else {
        print('Error updating balance: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error updating balance: $error');
      return null;
    }
  }
}