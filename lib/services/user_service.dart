import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/patient_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  final String baseUrl = 'http://192.168.1.103:8080/api';

  /// Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Lấy userId từ SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Lấy thông tin người dùng từ API
  Future<User?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));

        if (userData != null && userData['id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userData['id'].toString());
          return User.fromJson(userData);
        } else {
          print('⚠️ Không tìm thấy ID trong dữ liệu người dùng');
          return null;
        }
      } else {
        print('❌ Lỗi API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  Future<PatientProfile?> getDataUser(id) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/patient-profiles/by-user/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        return PatientProfile.fromJson(userData);
      } else {
        print('❌ Lỗi API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  /// Cập nhật thông tin người dùng
  Future<User?> updateUserProfile(User user) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      // Chuẩn bị dữ liệu user (loại bỏ các trường không cần thiết)
      Map<String, dynamic> userJson = user.toJson();
      print(userJson);
      // Loại bỏ các trường không cần thiết khi gửi lên server
      userJson.remove('createdBy');
      userJson.remove('updatedBy');
      userJson.remove('isDeleted');
      userJson.remove('lastLogin');
      userJson.remove('userRoles');
      userJson.remove('socialAccounts');
      userJson.remove('password'); // Loại bỏ password nếu không cần cập nhật

      // Chuyển đổi dữ liệu thành chuỗi JSON
      final userJsonString = json.encode(userJson);

      // Tạo multipart request như backend yêu cầu
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/users/save')
      );

      // Thêm headers
      request.headers['Authorization'] = 'Bearer $token';

      // Thêm trường user dưới dạng form field
      request.fields['user'] = userJsonString;

      // Gửi request
      var streamedResponse = await request.send();
      var responseData = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final updatedUserData = json.decode(responseData);
        print('✅ Cập nhật người dùng thành công: ${updatedUserData['id']}');
        return User.fromJson(updatedUserData);
      } else {
        print('❌ Lỗi cập nhật người dùng: ${streamedResponse.statusCode} - $responseData');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật thông tin người dùng: $e');
      return null;
    }
  }

  /// Cập nhật thông tin bệnh nhân
  Future<PatientProfile?> updatePatientProfile(PatientProfile patientProfile) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      // Tạo cấu trúc JSON phù hợp với SavePatientProfileDTO của backend
      Map<String, dynamic> profileData = {
        'id': patientProfile.id,
        'userId': patientProfile.user.id,
        'bloodType': patientProfile.bloodType?.value,
        'medicalHistory': patientProfile.medicalHistory,
        'allergies': patientProfile.allergies,
        'accountBalance': patientProfile.accountBalance
      };

      final response = await http.post(
        Uri.parse('$baseUrl/patient-profiles/save'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final updatedProfileData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Cập nhật hồ sơ bệnh nhân thành công: ${updatedProfileData['id']}');

        // Sau khi cập nhật thành công, lấy lại dữ liệu đầy đủ của profile
        return await getDataUser(patientProfile.user.id.toString());
      } else {
        print('❌ Lỗi cập nhật hồ sơ bệnh nhân: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật thông tin hồ sơ bệnh nhân: $e');
      return null;
    }
  }

  Future<User?> uploadImage(id, File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      // Tạo request multipart
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/users/$id/upload')
      );

      // Thêm headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Thêm file ảnh - đảm bảo tên trường là 'file'
      request.files.add(
          await http.MultipartFile.fromPath(
              'file',  // Khớp với @RequestPart("file") ở backend
              imageFile.path,
              filename: 'avatar.jpg'
          )
      );

      // Gửi request
      final response = await request.send();

      // Đọc response
      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final userData = json.decode(responseBody);
        print(userData);
        return User.fromJson(userData);
      } else {
        print('❌ Lỗi upload: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi upload ảnh: $e');
      return null;
    }
  }

  Future<PatientProfile?> updateBalance(id, amount) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      print('🔄 Gửi request update balance với ID: $id và số tiền: $amount');

      // Đảm bảo amount là chuỗi nếu controller mong đợi String
      final stringAmount = amount.toString();

      final response = await http.put(
        Uri.parse('$baseUrl/patient-profiles/update/balance/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: stringAmount, // Gửi trực tiếp là chuỗi, không encode JSON
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final patientData = json.decode(response.body);
        print('✅ Cập nhật số dư thành công');
        return PatientProfile.fromJson(patientData);
      } else {
        print('❌ Lỗi khi update tiền: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật tiền: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }
}
