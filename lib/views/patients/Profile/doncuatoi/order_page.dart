import 'package:flutter/material.dart';
import 'package:medical_storage/services/order_service.dart';
import 'package:medical_storage/models/order.dart';
import 'package:medical_storage/models/order_status.dart';
import 'package:provider/provider.dart';
import '../../../../services/patient_service.dart';
import '../../../../services/user_service.dart';
import 'order_detail_page.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final OrderService _orderService = OrderService();
  final PatientService _patientService = PatientService();
  List<Order> orders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final String? userId = await userService.getUserId();

      if (userId == null) {
        setState(() {
          _errorMessage = 'Không thể xác định người dùng';
          _isLoading = false;
        });
        return;
      }

      final patientResponse = await _patientService.getPatientProfileByUserId(userId);

      if (patientResponse == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy thông tin bệnh nhân';
          _isLoading = false;
        });
        return;
      }

      final patientId = patientResponse['id']?.toString();

      if (patientId == null) {
        setState(() {
          _errorMessage = 'Không có thông tin patient ID';
          _isLoading = false;
        });
        return;
      }

      try {
        final fetchedOrders = await _orderService.getOrdersByPatientId(patientId);

        setState(() {
          orders = fetchedOrders;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Lỗi khi tải đơn hàng: $e';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi hệ thống: $e';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    ) + ' VND';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.PROCESSING:
        return Colors.blue;
      case OrderStatus.COMPLETED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Đơn Hàng'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red),
        ),
      )
          : orders.isEmpty
          ? Center(child: Text('Không có đơn hàng'))
          : RefreshIndicator(
        onRefresh: _fetchOrders,
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5
              ),
              elevation: 3,
              child: ListTile(
                title: Text(
                  'Mã đơn hàng: ${order.orderCode}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trạng thái: ${order.status.toString().split('.').last}',
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tổng tiền: ${_formatCurrency(order.totalPrice)}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      'Ngày đặt: ${order.createdAt.toString().substring(0, 10)}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: _buildOrderActions(order),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailPage(
                        orderId: order.id.toString(),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderActions(Order order) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(
                  orderId: order.id.toString(),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text('Chi tiết', style: TextStyle(fontSize: 12)),
        ),
        if (order.status == OrderStatus.PENDING)
          TextButton(
            onPressed: () => _showCancelConfirmDialog(order),
            child: Text(
              'Hủy đơn',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 12
              ),
            ),
          ),
      ],
    );
  }

  void _showCancelConfirmDialog(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận hủy đơn'),
          content: Text('Bạn có chắc muốn hủy đơn hàng ${order.orderCode} không?'),
          actions: [
            TextButton(
              child: Text('Không'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Có'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelOrder(order);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      final success = await _orderService.cancelOrder(order.id.toString());

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy đơn hàng ${order.orderCode} thành công'),
            backgroundColor: Colors.green,
          ),
        );

        _fetchOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể hủy đơn hàng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}