import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/voucher.dart';
import 'base_service.dart';

class VoucherService extends BaseService<Voucher> {
  VoucherService()
      : super(
    endpoint: 'vouchers',
    fromJson: Voucher.fromJson,
  );

  // GET /api/vouchers
  Future<List<Voucher>> getAllVouchers() async {
    final response = await http.get(Uri.parse('$baseUrl/vouchers'));

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes);
      List<dynamic> body = json.decode(utf8Body);
      return body.map((dynamic item) => Voucher.fromJson(item)).toList();
    } else {
      throw Exception('Không thể tải danh sách voucher');
    }
  }

  // GET /api/vouchers/by-code/{code}
  Future<Voucher> getVoucherByCode(String code) async {
    final response = await http.get(Uri.parse('$baseUrl/vouchers/by-code/$code'));

    if (response.statusCode == 200) {
      final String utf8Body = utf8.decode(response.bodyBytes);
      Map<String, dynamic> body = json.decode(utf8Body);
      return Voucher.fromJson(body);
    } else {
      throw Exception('Không thể tìm thấy voucher với mã: $code');
    }
  }
}
