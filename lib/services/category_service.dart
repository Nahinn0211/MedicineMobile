import 'dart:convert';

import 'base_service.dart';
import 'package:medical_storage/models/category.dart';
import 'package:http/http.dart' as http;

class CategoryService extends BaseService<Category> {
  CategoryService() : super(
      endpoint: 'categories',
      fromJson: Category.fromJson
  );

  Future<List<Category>> getAllCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Category>> getSubCategories(String parentId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/categories/parent/$parentId')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  Future<List<Category>> searchCategoriesByName(String name) async {
    final response = await http.get(
        Uri.parse('$baseUrl/categories/search?name=$name')
    );

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search categories');
    }
  }
}