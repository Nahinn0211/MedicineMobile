import 'package:flutter/material.dart';
import 'package:medical_storage/models/order.dart';
import 'package:medical_storage/models/order_detail.dart';
import 'package:medical_storage/services/order_service.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService _orderService = OrderService();
  Order? _order;
  List<OrderDetail> _orderDetails = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
    _fetchOrderInfo();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final orderDetailsResponse = await _orderService.getOrderDetailsByOrderId(widget.orderId);

      print('🔍 Order Details Response: $orderDetailsResponse');

      if (orderDetailsResponse['success']) {
        setState(() {
          _orderDetails = orderDetailsResponse['orderDetails'] ?? [];
          _isLoading = _order == null;
        });
      } else {
        setState(() {
          _errorMessage = orderDetailsResponse['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải chi tiết đơn hàng: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOrderInfo() async {
    try {
      final response = await _orderService.getOrderById(widget.orderId);

      if (response['success']) {
        setState(() {
          _order = response['order'];
          _isLoading = _orderDetails.isEmpty;
        });
      } else {
        print('❌ Lỗi lấy thông tin đơn hàng: ${response['message']}');
        setState(() {
          _errorMessage = response['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Lỗi chi tiết: $e');
      setState(() {
        _errorMessage = 'Lỗi lấy thông tin đơn hàng: $e';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Đơn Hàng '),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
          : _buildOrderDetails(),
    );
  }

  Widget _buildOrderDetails() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummaryCard(),

          SizedBox(height: 16),

          Text(
            'Chi Tiết Sản Phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildOrderItemsList(),

          SizedBox(height: 16),

          _buildOrderTotalCard(),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông Tin Đơn Hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildInfoRow('Mã Đơn Hàng', widget.orderId),
            _buildInfoRow('Trạng Thái', _order?.status.toString().split('.').last ?? 'Đang tải'),
            _buildInfoRow('Phương Thức Thanh Toán', _order?.paymentMethod.toString().split('.').last ?? 'Đang tải'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Card(
      elevation: 4,
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _orderDetails.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final detail = _orderDetails[index];
          return ListTile(
            title: Text(detail.medicine.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số lượng: ${detail.quantity}'),
                Text('Đơn giá: ${_formatCurrency(detail.unitPrice)}'),
              ],
            ),
            trailing: Text(
              _formatCurrency(detail.quantity * detail.unitPrice),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderTotalCard() {
    final totalAmount = _orderDetails.fold(
        0.0,
            (sum, detail) => sum + (detail.quantity * detail.unitPrice)
    );

    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Tổng Sản Phẩm', _formatCurrency(totalAmount)),
            _buildTotalRow('Giảm Giá', _formatCurrency(_order?.discountAmount ?? 0)),
            Divider(),
            _buildTotalRow(
                'Tổng Thanh Toán',
                _formatCurrency(totalAmount - (_order?.discountAmount ?? 0)),
                isTotal: true
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.red : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}