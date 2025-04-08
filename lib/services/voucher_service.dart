import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/discount.dart';
import 'base_service.dart';

class DiscountService extends BaseService<Discount> {
  DiscountService() : super(
      endpoint: 'discounts',
      fromJson: Discount.fromJson
  );

  Future<List<Discount>> getAllDiscounts() async {
    final response = await http.get(
        Uri.parse('$baseUrl/discounts')
    );

    if (response.statusCode == 200) {
      print('Raw JSON data: ${response.body}');
      final String utf8Body = utf8.decode(response.bodyBytes);
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Discount.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách mã giảm giá');
    }
  }

  Future<Discount> getDiscountByCode(String code) async {
    final response = await http.get(
        Uri.parse('$baseUrl/discounts/by-code?code=$code')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes);
      Map<String, dynamic> body = json.decode(utf8Body);
      return Discount.fromJson(body);
    } else {
      throw Exception('Không thể tải mã giảm giá: $code');
    }
  }
}