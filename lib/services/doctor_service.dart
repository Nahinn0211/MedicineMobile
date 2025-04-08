import 'dart:convert';

import 'package:medical_storage/models/booking_service.dart';
import 'package:medical_storage/models/salary.dart';
import 'package:medical_storage/models/user.dart';

import 'base_service.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:http/http.dart' as http;

class DoctorService extends BaseService<DoctorProfile> {
  DoctorService() : super(
      endpoint: 'doctor-profiles',
      fromJson: DoctorProfile.fromJson
  );

  Future<List<DoctorProfile>> getDoctorsBySpecialization(String specialization) async {
    final response = await http.get(
        Uri.parse('$baseUrl/doctor-profiles/search/specialization/$specialization')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8 riêng
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => DoctorProfile.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải bác sĩ theo chuyên khoa: $specialization');
    }
  }

  Future<List<DoctorProfile>> getAllDoctors() async {
    try {
      // Lấy danh sách tất cả bác sĩ với giải mã UTF-8 riêng
      final doctorResponse = await http.get(
          Uri.parse('$baseUrl/doctor-profiles')
      );

      if (doctorResponse.statusCode != 200) {
        throw Exception('Không thể tải danh sách bác sĩ: ${doctorResponse.statusCode}');
      }

      // Giải mã UTF-8 cho danh sách bác sĩ
      final String utf8DoctorBody = utf8.decode(doctorResponse.bodyBytes);
      List<dynamic> doctorData = json.decode(utf8DoctorBody);

      // Lấy danh sách tất cả người dùng với giải mã UTF-8 riêng
      final userResponse = await http.get(
          Uri.parse('$baseUrl/users')
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Không thể tải danh sách người dùng: ${userResponse.statusCode}');
      }

      // Giải mã UTF-8 cho danh sách người dùng
      final String utf8UserBody = utf8.decode(userResponse.bodyBytes);
      List<dynamic> userData = json.decode(utf8UserBody);

      // Chuyển danh sách người dùng thành Map để dễ tìm kiếm
      Map<String, User> userMap = {};
      for (var user in userData) {
        User userObj = User.fromJson(user);
        if (userObj.id != null) {
          userMap[userObj.id!] = userObj;
        }
      }

      // Kết hợp thông tin bác sĩ và người dùng
      List<DoctorProfile> doctors = [];
      for (var doctor in doctorData) {
        String? userId = doctor['userId']?.toString();

        if (userId != null && userMap.containsKey(userId)) {
          doctor['user'] = userMap[userId]!.toJson();
        } else {
          // Nếu không tìm thấy user tương ứng thì tạo user mặc định để tránh lỗi
          doctor['user'] = User(fullName: '', email: '', password: '').toJson();
        }

        // Tạo đối tượng DoctorProfile từ JSON đã được bổ sung thông tin user
        doctors.add(DoctorProfile.fromJson(doctor));
      }
      return doctors;
    } catch (e) {
      print('Lỗi trong getAllDoctors: $e');
      throw Exception('Không thể tải danh sách bác sĩ: $e');
    }
  }

  Future<List<DoctorProfile>> getServicesByDoctor(String doctorId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/doctor-services/doctor/$doctorId')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8 riêng
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => DoctorProfile.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải dịch vụ của bác sĩ: $doctorId');
    }
  }

  Future<List<DoctorProfile>> getServicesByService(String serviceId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/doctor-services/service/$serviceId')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8 riêng
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => DoctorProfile.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải dịch vụ theo ID dịch vụ: $serviceId');
    }
  }
}