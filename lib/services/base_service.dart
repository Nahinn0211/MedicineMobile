import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseService<T> {
  final String baseUrl = 'http://192.168.1.103:8080/api'; // xĐối với giả lập Android
  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;

  BaseService({required this.endpoint, required this.fromJson});

  Future<List<T>> getAll() async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes); // Giải mã UTF-8
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => fromJson(item)).toList();
    } else {
      throw Exception('Failed to load $endpoint');
    }
  }

  Future<T> getById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint/$id'));

    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load $endpoint with id $id');
    }
  }

  Future<T> create(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create $endpoint');
    }
  }

  Future<T> update(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update $endpoint with id $id');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete $endpoint with id $id');
    }
  }
}