import 'package:flutter/material.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/models/medicine_media.dart';
import 'package:medical_storage/models/order.dart';
import 'package:medical_storage/models/order_detail.dart';
import 'package:medical_storage/services/order_service.dart';
import 'package:medical_storage/models/order_status.dart';
import 'package:medical_storage/models/payment_method.dart';

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
    _fetchOrderData();
  }

  // Tối ưu việc fetch dữ liệu bằng cách gộp 2 request vào 1 hàm
  Future<void> _fetchOrderData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Sử dụng Future.wait để song song hóa các request
      final results = await Future.wait([
        _orderService.getOrderById(widget.orderId),
        _orderService.getOrderDetailsByOrderId(widget.orderId),
      ]);

      final orderResponse = results[0];
      final detailsResponse = results[1];

      // Xử lý kết quả đơn hàng
      if (orderResponse['success']) {
        _order = orderResponse['order'];
        print(_order?.paymentMethod.toString());
      } else {
        _setError('Lỗi lấy thông tin đơn hàng: ${orderResponse['message']}');
        return;
      }

      // Xử lý kết quả chi tiết đơn hàng
      if (detailsResponse['success']) {
        _orderDetails = detailsResponse['orderDetails'] ?? [];
      } else {
        _setError('Lỗi lấy chi tiết đơn hàng: ${detailsResponse['message']}');
        return;
      }

      // Cập nhật UI khi cả hai đều thành công
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _setError('Lỗi khi tải dữ liệu: $e');
    }
  }

  // Helper để đặt thông báo lỗi
  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  // Định dạng tiền tệ
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    ) + ' VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Chi Tiết Đơn Hàng #${widget.orderId}'),
      backgroundColor: Colors.blueAccent,
      elevation: 2,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _fetchOrderData,
          tooltip: 'Tải lại',
        )
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

    return _buildOrderDetails();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải thông tin đơn hàng...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              onPressed: _fetchOrderData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return RefreshIndicator(
      onRefresh: _fetchOrderData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusBanner(),
            SizedBox(height: 16),
            _buildOrderSummaryCard(),
            SizedBox(height: 20),
            _buildSectionHeader('Chi Tiết Sản Phẩm', Icons.medication),
            SizedBox(height: 8),
            _buildOrderItemsList(),
            SizedBox(height: 20),
            _buildOrderTotalCard(),
            SizedBox(height: 24),
            _buildPaymentMethodInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 22),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusBanner() {
    if (_order == null) return SizedBox();

    Color statusColor;
    IconData statusIcon;
    final orderStatus = _order!.status;
    print(orderStatus);
    String statusText;
    // Determine color and icon based on status
    switch (orderStatus) {
      case OrderStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Hoàn thành';
        break;
      case OrderStatus.processing:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        statusText = 'Đang xử lý';
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Đã hủy';
        break;
      case OrderStatus.pending:
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Chờ xử lý';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trạng thái đơn hàng',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 2),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }String _getPaymentMethodName(PaymentMethod? method) {
    if (method == null) return 'N/A';

    print('Phương thức thanh toán: $method'); // Thêm dòng này để debug

    switch (method) {
      case PaymentMethod.CASH:
        return 'Tiền mặt';
      case PaymentMethod.BALANCEACCOUNT:
        return 'Ví THAVP';
      case PaymentMethod.PAYPAL:
        return 'PayPal';
      default:
        return method.toString().split('.').last;
    }
  }

  Widget _buildOrderSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Thông Tin Đơn Hàng', Icons.receipt),
            SizedBox(height: 12),
            _buildInfoRow('Mã Đơn Hàng', _order?.orderCode ?? 'N/A', Icons.confirmation_number),
            _buildInfoRow(
                'Ngày Đặt',
                _order?.createdAt != null
                    ? '${_formatDate(_order!.createdAt)}'
                    : 'N/A',
                Icons.calendar_today
            ),
            _buildInfoRow(
                'Phương Thức Thanh Toán',
                _getPaymentMethodName(_order?.paymentMethod),
                Icons.payment
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Widget _buildOrderItemsList() {
    if (_orderDetails.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Không có sản phẩm nào',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _orderDetails.length,
          separatorBuilder: (context, index) => Divider(height: 1),
          itemBuilder: (context, index) => _buildOrderItemTile(_orderDetails[index]),
        ),
      ),
    );
  }

  Widget _buildOrderItemTile(OrderDetail detail) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getMedicineImage(detail.medicine),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.medicine.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  'Đơn giá: ${_formatCurrency(detail.unitPrice)}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(detail.quantity * detail.unitPrice),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'SL: ${detail.quantity}',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotalCard() {
    final subtotal = _orderDetails.fold(
        0.0,
            (sum, detail) => sum + (detail.quantity * detail.unitPrice)
    );

    final discount = _order?.discountAmount ?? 0.0;
    final total = subtotal - discount;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Tổng Thanh Toán', Icons.receipt_long),
            SizedBox(height: 12),
            _buildTotalRow('Tổng tiền hàng', _formatCurrency(subtotal)),
            _buildTotalRow(
                'Giảm giá',
                discount > 0 ? '- ${_formatCurrency(discount)}' : _formatCurrency(0)
            ),
            Divider(thickness: 1, height: 24),
            _buildTotalRow('Thành tiền', _formatCurrency(total), isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _getMedicineImage(Medicine medicine) {
    // Tìm ảnh chính (mainImage = true) trong danh sách medias
    MedicineMedia? mainMedia;

    // Tìm ảnh có mainImage = true (nếu có)
    if (medicine.medias != null && medicine.medias!.isNotEmpty) {
      try {
        mainMedia = medicine.medias!.firstWhere((media) => media.mainImage == true);
      } catch (_) {
        // Nếu không tìm thấy ảnh mainImage = true, sử dụng ảnh đầu tiên
        mainMedia = medicine.medias!.isNotEmpty ? medicine.medias!.first : null;
      }
    }

    // Nếu có ảnh, hiển thị ảnh
    if (mainMedia != null && mainMedia.mediaUrl != null && mainMedia.mediaUrl!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(mainMedia.mediaUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Nếu không có ảnh, hiển thị icon mặc định
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.medication, color: Colors.blue),
    );
  }

  Widget _buildPaymentMethodInfo() {
    if (_order == null) return SizedBox();

    IconData paymentIcon;
    String paymentTitle;
    String paymentDesc;

    // Set payment method info
    switch (_order!.paymentMethod) {
      case PaymentMethod.CASH:
        paymentIcon = Icons.money;
        paymentTitle = 'Thanh toán tiền mặt';
        paymentDesc = 'Khách hàng sẽ thanh toán khi nhận hàng';
        break;
      case PaymentMethod.PAYPAL:
        paymentIcon = Icons.paypal;
        paymentTitle = 'Thanh toán qua PayPal';
        paymentDesc = 'Đã thanh toán qua PayPal';
        break;
      case PaymentMethod.BALANCEACCOUNT:
        paymentIcon = Icons.account_balance_wallet;
        paymentTitle = 'Thanh toán qua Ví THAVP';
        paymentDesc = 'Đã thanh toán bằng Ví THAVP';
        break;
      default:
        paymentIcon = Icons.payment;
        paymentTitle = 'Phương thức thanh toán';
        paymentDesc = 'Chưa có thông tin thanh toán';
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Icon(paymentIcon, color: Colors.blue, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    paymentDesc,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
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
              color: isTotal ? Colors.red[700] : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}