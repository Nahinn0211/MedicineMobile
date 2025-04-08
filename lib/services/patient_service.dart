import 'dart:convert';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:medical_storage/models/salary.dart';
import 'package:path/path.dart' as path;
import 'package:medical_storage/models/notification.dart';
import 'package:medical_storage/models/order.dart';
import 'package:medical_storage/models/order_detail.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/models/prescription.dart';
import 'package:medical_storage/models/review.dart';
import 'package:medical_storage/models/service_booking.dart';
import 'package:medical_storage/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'base_service.dart';
import 'package:http/http.dart' as http;

class PatientService extends BaseService<PatientProfile> {
  PatientService() : super(
      endpoint: 'patient-profiles',
      fromJson: PatientProfile.fromJson
  );
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  Future<String> createServiceBooking(ServiceBooking serviceBooking) async{
    final response = await http.post(
      Uri.parse('$baseUrl/service-bookings/save'),
      body: json.encode(serviceBooking.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return 'Service has been successfully booking.';
    } else {
      throw Exception('Failed to create service booking. Status code: ${response.statusCode}');
    }
  }

  Future<String> cancelServiceBooking(String serviceBookingId) async{
    final response = await http.put(
      Uri.parse('$baseUrl/service-bookings/cancel/$serviceBookingId'),
    );

    if (response.statusCode == 200) {
      return 'Service Booking $serviceBookingId has been successfully cancelled.';
    } else {
      throw Exception('Failed to cancel service booking $serviceBookingId. Status code: ${response.statusCode}');
    }
  }

  Future<List<Prescription>> getAllPrescriptionByUserId(String userId) async{
    final response = await http.get(
        Uri.parse('$baseUrl/prescriptions/by-patient/$userId')
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Prescription.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get prescriptions for $userId');
    }
  }

  Future<List<Notification>> getNotificationsByUser(String userId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/notifications/by-user/$userId')
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Notification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications for user $userId');
    }
  }

  Future<String> review({
    String? medicineId,
    String? doctorId,
    String? serviceId,
  }) async {
    var requestBody = <String, String>{};
    if (medicineId != null && medicineId.isNotEmpty) {
      requestBody['medicineId'] = medicineId;
    }
    if (doctorId != null && doctorId.isNotEmpty) {
      requestBody['doctorId'] = doctorId;
    }
    if (serviceId != null && serviceId.isNotEmpty) {
      requestBody['serviceId'] = serviceId;
    }

    var url = Uri.parse('$baseUrl/reviews');

    final response = await http.post(
      url,
      body: json.encode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return 'Review has been successfully saved.';
    } else {
      throw Exception('Failed to save review. Status code: ${response.statusCode}');
    }
  }

  Future<String> updateUser(PatientProfile patient, File? imageFile) async {
    var url = Uri.parse('$baseUrl/users/save');
    var request = http.MultipartRequest('PUT', url);

    request.fields['patient'] = json.encode(patient);

    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      String extension = path.extension(imageFile.path).toLowerCase();
      MediaType contentType;

      switch (extension) {
        case '.jpg':
        case '.jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case '.png':
          contentType = MediaType('image', 'png');
          break;
        case '.gif':
          contentType = MediaType('image', 'gif');
          break;
        default:
          contentType = MediaType('application', 'octet-stream');
      }

      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(imageFile.path),
        contentType: contentType,
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      return 'User has been successfully updated.';
    } else {
      throw Exception('Failed to update user. Status code: ${response.statusCode}');
    }
  }

  Future<String> saveMoney(String money, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/salaries/deposit'),
      body: json.encode({
        'money': money,
        'userId': userId
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return 'Deposit money into account has been successful.';
    } else {
      throw Exception('Failed to deposit money into account. Status code: ${response.statusCode}');
    }
  }

  Future<List<Order>> getAllOrderByUser(String userId) async{
    final response = await http.get(
        Uri.parse('$baseUrl/orders/by-patient/$userId')
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get orders for $userId');
    }
  }

  Future<List<OrderDetail>> getOrderDetailByOrderId(String orderId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/order-details/by-user/$orderId')
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => OrderDetail.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load order detail for $orderId');
    }
  }

  Future<String> cancelOrder(String orderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/cancel/$orderId'),
    );

    if (response.statusCode == 200) {
      return 'Order $orderId has been successfully cancelled.';
    } else {
      throw Exception('Failed to cancel order $orderId. Status code: ${response.statusCode}');
    }
  }


  Future<String> createOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      body: json.encode(order.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return 'Order has been successfully created.';
    } else {
      throw Exception('Failed to create order. Status code: ${response.statusCode}');
    }
  }

  Future<List<Order>> searchOrder(String code) async{
    final response = await http.get(
        Uri.parse('$baseUrl/orders?code=$code')
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Order.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load order');
    }
  }
  Future<Map<String, dynamic>?> getPatientProfileByUserId(String userId) async {
    try {
      // Lấy token an toàn
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Kiểm tra token
      if (token == null) {
        print('❌ Token không tồn tại');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/patient-profiles/by-user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Patient Profile Endpoint: ${response.request?.url}');
      print('🔍 Patient Profile Status: ${response.statusCode}');
      print('🔍 Patient Profile Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('❌ Không tìm thấy hồ sơ bệnh nhân: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi lấy hồ sơ bệnh nhân: $e');
      return null;
    }
  }

  Future<String?> getPatientIdByUserId(String userId) async {
    final url = '$baseUrl/patient-profiles/by-user/$userId';
    print('Fetching patient_id from: $url'); // 🟢 Debug URL API

    final response = await http.get(Uri.parse(url));

    print('Response status: ${response.statusCode}'); // 🟢 Debug HTTP status
    print('Response body: ${response.body}'); // 🟢 Debug API response

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'].toString(); // Kiểm tra API có trả về "id" không
    } else {
      return null;
    }
  }

}