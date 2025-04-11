import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/voucher.dart';
import 'package:medical_storage/services/cart_service.dart';
import 'package:medical_storage/models/discount.dart';
import 'package:medical_storage/services/base_service.dart';
import 'package:medical_storage/models/order.dart';
import 'package:medical_storage/models/order_detail.dart';
import 'package:medical_storage/models/order_status.dart';
import 'package:medical_storage/models/payment_method.dart';
import 'package:medical_storage/services/patient_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService extends BaseService<Order> {
  OrderService() : super(endpoint: 'orders', fromJson: Order.fromJson);


  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> createOrderDetails(int orderId, List<CartItem> cartItems) async {
    final token = await getToken();
    for (var item in cartItems) {
      final orderDetail = {
        "orderId": orderId,
        "medicineId": item.medicine.id,
        "attributeId": item.attribute.id ?? null,
        "quantity": item.quantity,
        "unitPrice": item.attribute.priceOut,
      };

      print('📦 Order Details JSON gửi lên: ${jsonEncode(orderDetail)}');

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/order-details/save'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(orderDetail),
        );


        print('📩 Response status: ${response.statusCode}');
        print('🔹 Response body: ${response.body}');

        if (response.statusCode != 200) {
          print("❌ Lỗi khi thêm order detail: ${response.body}");
        }
      } catch (e) {
        print("🚨 Exception khi thêm order detail: $e");
      }
    }
  }
  Future<List<Order>> getOrdersByPatientId(String patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Không có token xác thực');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/orders/by-patient/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Endpoint: ${response.request?.url}');
      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<Order> orders = [];

        // Kiểm tra và xử lý dữ liệu
        if (responseData is List) {
          // Nếu trả về danh sách
          orders = responseData
              .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (responseData is Map) {
          // Nếu trả về map, thử lấy danh sách từ các key khác nhau
          final List<dynamic> orderList = responseData['content'] ??
              responseData['data'] ??
              responseData['orders'] ??
              [responseData];

          orders = orderList
              .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }

        // Sắp xếp các đơn hàng theo ngày tạo, mới nhất lên đầu
        orders.sort((a, b) {
          // Kiểm tra nếu `createdAt` không phải null trước khi so sánh
          if (a.createdAt != null && b.createdAt != null) {
            return b.createdAt!.compareTo(a.createdAt!); // Sắp xếp theo ngày tạo, mới nhất lên đầu
          }
          return 0; // Nếu một trong hai cái null, không thay đổi thứ tự
        });

        print('🛒 Số lượng đơn hàng: ${orders.length}');

        // In chi tiết từng đơn hàng
        orders.forEach((order) {
          print('🏷️ Đơn hàng: ${order.orderCode}, Tổng tiền: ${order.totalPrice}, Trạng thái: ${order.status}, Ngày tạo: ${order.createdAt}');
        });

        return orders;
      } else {
        throw Exception('Không thể tải đơn hàng: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Lỗi khi lấy đơn hàng: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getOrderDetailsByOrderId(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Không có token xác thực');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/order-details/by-order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Order Details Endpoint: ${response.request?.url}');
      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        List<OrderDetail> orderDetails = [];

        // Xử lý nhiều kiểu dữ liệu
        if (responseData is List) {
          orderDetails = responseData
              .map((item) => OrderDetail.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (responseData is Map) {
          final List<dynamic> detailList = responseData['content'] ??
              responseData['data'] ??
              responseData['orderDetails'] ??
              [responseData];

          orderDetails = detailList
              .map((item) => OrderDetail.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }

        print('🛒 Số lượng chi tiết đơn hàng: ${orderDetails.length}');

        return {
          'success': true,
          'orderDetails': orderDetails,
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi khi lấy thông tin chi tiết đơn hàng: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      print('❌ Lỗi khi lấy chi tiết đơn hàng: $e');
      return {
        'success': false,
        'message': 'Lỗi khi lấy thông tin chi tiết đơn hàng: $e',
      };
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String patientId,
    required double totalAmount,
    required String orderCode,
    required double discountAmount,
    required String paymentMethod,
    Voucher? voucher,
    String? note,
  }) async {
    try {
      final token = await getToken();
      if(token == null) {
        return{
          "sucess": false,
          'message': 'Lỗi r ông cháu ơi'
        };
      }

      final paymentMethodEnum = _parsePaymentMethod(paymentMethod);
      print(paymentMethodEnum);
      final statusEnum = _parseStatus("PENDING");

      final orderData = new Order(patientId: patientId, paymentMethod: paymentMethodEnum, totalPrice: totalAmount, discountAmount: discountAmount, voucherCode: voucher?.code, status: statusEnum, orderCode: orderCode);

      print("Order data: ${json.encode(orderData)}");

      final response = await http.post(
        Uri.parse('$baseUrl/orders/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(orderData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Order created: $responseData");
        return {
          'success': true,
          'order_id': responseData['id'].toString(),
          'message': 'Đơn hàng đã được tạo thành công'
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi khi tạo đơn hàng: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      print("Lỗi khi tạo đơn hàng: $e");
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': OrderStatus.CANCELLED.toString().split('.').last.toUpperCase(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi hủy đơn hàng: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final token = await getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Order Info Endpoint: ${response.request?.url}');
      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        return {
          'success': true,
          'order': Order.fromJson(responseData),
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi khi lấy thông tin đơn hàng: ${response.statusCode} - ${response.body}'
        };
      }
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin đơn hàng: $e');
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }
  PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case "CASH":
        return PaymentMethod.CASH;
      case "BALANCEACCOUNT":
        return PaymentMethod.BALANCEACCOUNT;
      case "PAYPAL":
        return PaymentMethod.PAYPAL;
      default:
        return PaymentMethod.CASH;
    }
  }

}

OrderStatus _parseStatus(String status) {
  switch (status) {
    case "PENDING":
      return OrderStatus.PENDING;
    case "PROCESSING":
      return OrderStatus.PROCESSING;
    case "COMPLETED":
      return OrderStatus.COMPLETED;
    case "CANCELLED":
      return OrderStatus.CANCELLED;
    default :
      return OrderStatus.PENDING;
  }
}