import 'dart:convert';

import 'base_service.dart';
import 'package:medical_storage/models/brand.dart';
import 'package:http/http.dart' as http;

class BrandService extends BaseService<Brand> {
  BrandService() : super(
      endpoint: 'brands',
      fromJson: Brand.fromJson
  );

  Future<List<Brand>> getAllBrands() async{
    final response = await http.get(
      Uri.parse('$baseUrl/brands')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Brand.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get brands');
    }
  }

  Future<List<Brand>> searchBrandsByName(String name) async {
    final response = await http.get(
        Uri.parse('$baseUrl/brands/search?name=$name')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Brand.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search brands');
    }
  }
  Future<Brand> getBrandById(String brandId) async {
    final response = await http.get(Uri.parse('$baseUrl/brands/$brandId'));

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes);
      final dynamic data = json.decode(utf8Body);
      return Brand.fromJson(data);  // Sử dụng phương thức fromJson để parse dữ liệu vào Brand
    } else {
      throw Exception('Failed to load brand');
    }
  }

}