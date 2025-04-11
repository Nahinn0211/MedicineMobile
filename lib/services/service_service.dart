import 'dart:convert';

import 'package:medical_storage/models/service.dart';

import 'base_service.dart';
import 'package:http/http.dart' as http;

class ServiceService extends BaseService<Service> {
  ServiceService() : super(
      endpoint: 'services',
      fromJson: Service.fromJson
  );

  Future<List<Service>> getAllServices() async {
    try {
      final uri = Uri.parse('$baseUrl/services');
      print('Đang kết nối đến: $uri');

      // Thêm header để đảm bảo UTF-8
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // Giải mã UTF-8 từ phản hồi
        final String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> body = json.decode(decodedBody);
        return body.map((dynamic item) => Service.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get services: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Lỗi chi tiết: $e');
      throw Exception('Failed to get services: $e');
    }
  }
}