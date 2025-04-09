import 'package:flutter/material.dart';
import 'package:medical_storage/services/order_service.dart';
import 'package:medical_storage/models/order.dart';
import 'package:medical_storage/models/order_status.dart';
import 'package:provider/provider.dart';
import '../../../../services/patient_service.dart';
import '../../../../services/user_service.dart';
import 'order_detail_page.dart';

// Keep original class structure for hot reload compatibility
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

  // Improved error handling in fetch orders
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final String? userId = await userService.getUserId();

      if (userId == null) {
        _setError('Không thể xác định người dùng');
        return;
      }

      final patientResponse = await _patientService.getPatientProfileByUserId(userId);

      if (patientResponse == null) {
        _setError('Không tìm thấy thông tin bệnh nhân');
        return;
      }

      final patientId = patientResponse['id']?.toString();

      if (patientId == null) {
        _setError('Không có thông tin patient ID');
        return;
      }

      try {
        final fetchedOrders = await _orderService.getOrdersByPatientId(patientId);

        setState(() {
          orders = fetchedOrders;
          _isLoading = false;
        });
      } catch (e) {
        _setError('Lỗi khi tải đơn hàng: $e');
        _showErrorSnackBar('$e');
      }
    } catch (e) {
      _setError('Lỗi hệ thống: $e');
    }
  }

  // Helper methods for cleaner code
  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Formatting utilities
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return date.toString().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Extracted widget methods for better organization
  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Quản Lý Đơn Hàng'),
      backgroundColor: Colors.blueAccent,
      elevation: 2,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _fetchOrders,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOrderList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải dữ liệu...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              onPressed: _fetchOrders,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Không có đơn hàng',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Các đơn hàng của bạn sẽ hiển thị tại đây',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToOrderDetail(order.id.toString()),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderHeader(order),
              Divider(height: 16),
              _buildOrderDetails(order),
              SizedBox(height: 8),
              _buildOrderActions(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          color: Colors.blueAccent,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Mã đơn hàng: ${order.orderCode}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        _buildStatusChip(order.status),
      ],
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          Icons.attach_money,
          'Tổng tiền:',
          _formatCurrency(order.totalPrice),
          isBold: true,
        ),
        SizedBox(height: 4),
        _buildDetailRow(
          Icons.calendar_today,
          'Ngày đặt:',
          _formatDate(order.createdAt),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black87 : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (order.status == OrderStatus.PENDING)
          OutlinedButton.icon(
            icon: Icon(Icons.cancel_outlined, size: 16),
            label: Text('Hủy đơn'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => _showCancelConfirmDialog(order),
          ),
        SizedBox(width: 8),
        ElevatedButton.icon(
          icon: Icon(Icons.visibility, size: 16),
          label: Text('Chi tiết'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => _navigateToOrderDetail(order.id.toString()),
        ),
      ],
    );
  }

  void _navigateToOrderDetail(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(
          orderId: orderId,
        ),
      ),
    );
  }

  void _showCancelConfirmDialog(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Xác nhận hủy đơn'),
          content: Text('Bạn có chắc muốn hủy đơn hàng ${order.orderCode} không?'),
          actions: [
            TextButton(
              child: Text('Không'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Có, hủy đơn'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
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
        _showSuccessSnackBar('Đã hủy đơn hàng ${order.orderCode} thành công');
        _fetchOrders();
      } else {
        _showErrorSnackBar('Không thể hủy đơn hàng');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi: $e');
    }
  }
}