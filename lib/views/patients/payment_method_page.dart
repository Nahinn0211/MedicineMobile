import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:medical_storage/models/discount.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/models/voucher.dart';
import 'package:medical_storage/services/cart_service.dart';
import 'package:medical_storage/services/order_service.dart';
import 'package:medical_storage/services/patient_service.dart';
import 'package:medical_storage/views/patients/payment_success.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/payment_method.dart';
import '../../services/user_service.dart';

class PaymentMethodPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final double discountAmount;
  final Map<String, String>? address;
  final String deliveryMethod;
  final String? note;
  final Voucher? voucher;

  PaymentMethodPage({
    required this.cartItems,
    required this.totalAmount,
    this.discountAmount = 0,
    this.address,
    this.deliveryMethod = "Giao hàng tận nơi",
    this.note,
    this.voucher,
    Discount? discount,
  });

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.CASH;
  final PatientService _patientService = PatientService();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  bool _isPaymentProcessed = false;

  String _formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(amount);
  }

  void _processPayPal() {
    if (_isPaymentProcessed) return;

    setState(() {
      _isLoading = true;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
          sandboxMode: true,
          clientId: "ASn-24p2EOa4SW4egAbp2d4mmubSL54sScc77I9jnrZ2zCXnXt4I-VR9gqqbjjeTAAlwWxmeozH9g0mu",
          secretKey: "EOcD4eB_KzxOg5sIJNUxjOY90xjx9Fn6arQtM5jyDphGkHMF0vUE28NG9WzJkdR7z51zRepzcD1h4WiC",
          returnURL: "https://example.com",
          cancelURL: "https://example.com",
          transactions: [
            {
              "amount": {
                "total": (widget.totalAmount / 23000).toStringAsFixed(2),
                "currency": "USD",
              },
              "description": "Thanh toán đơn hàng",
            }
          ],
          note: "Thanh toán an toàn qua PayPal",
          onSuccess: (Map params) async {
            if (_isPaymentProcessed) return;

            print("PayPal onSuccess được gọi với params: $params");
            _isPaymentProcessed = true;

            // Đóng màn hình PayPal trước khi xử lý thanh toán
            Navigator.of(context).pop();

            // Chuyển sang xử lý thanh toán
            await _handlePaymentSuccess();
          },
          onError: (error) {
            if (_isPaymentProcessed) return;
            _isPaymentProcessed = true;

            print("PayPal onError được gọi với lỗi: $error");

            // Đóng màn hình PayPal
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Hiển thị lỗi
            _showPaymentErrorSnackBar('Lỗi thanh toán: ${error.toString()}');
          },
          onCancel: (params) async {
            if (_isPaymentProcessed) return;
            _isPaymentProcessed = true;

            print("PayPal onCancel được gọi với params: $params");

            // Đóng màn hình PayPal
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Kiểm tra xem có phải là giao dịch bị hủy thực sự không
            if (params != null && params.containsKey('PayerID') && params['PayerID'] != null) {
              print("Phát hiện PayerID trong params onCancel - xử lý như thanh toán thành công");
              await _handlePaymentSuccess();
              return;
            }

            // Hiển thị thông báo hủy giao dịch
            _showPaymentErrorSnackBar('Đã hủy giao dịch');
          },
        ),
      ),
    ).then((_) {
      // Đảm bảo trạng thái được reset
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      print('Lỗi không mong muốn khi xử lý PayPal: $error');
      _showPaymentErrorSnackBar('Đã xảy ra lỗi không mong muốn');
    });
  }

  void _showPaymentErrorSnackBar(String message) {
    if (!mounted) return;

    // Đảm bảo reset trạng thái
    setState(() {
      _isLoading = false;
      _isPaymentProcessed = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handlePaymentSuccess() async {
    // Kiểm tra trạng thái widget trước khi xử lý
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final userService = Provider.of<UserService>(context, listen: false);
      final String? userId = await userService.getUserId();

      if (userId == null) {
        _showPaymentErrorSnackBar('Không thể xác định người dùng');
        return;
      }

      final patientResponse = await _patientService.getPatientProfileByUserId(userId);

      if (patientResponse == null) {
        _showPaymentErrorSnackBar('Không tìm thấy hồ sơ bệnh nhân');
        return;
      }

      final patientId = patientResponse['id']?.toString();

      if (patientId == null) {
        _showPaymentErrorSnackBar('Không có thông tin patient ID');
        return;
      }

      final orderCode = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      final result = await _orderService.createOrder(
        patientId: patientId,
        totalAmount: widget.totalAmount,
        orderCode: orderCode,
        discountAmount: widget.discountAmount,
        paymentMethod: "PAYPAL",
        note: widget.note,
      );

      if (result['success'] == true) {
        final orderId = result['order_id'];

        try {
          await _orderService.createOrderDetails(
              int.parse(orderId),
              widget.cartItems
          );

          print('✅ Tạo chi tiết đơn hàng thành công');
        } catch (e) {
          print('❌ Lỗi khi tạo chi tiết đơn hàng: $e');
          _showPaymentErrorSnackBar('Lỗi khi tạo chi tiết đơn hàng');
          return;
        }

        // Xóa giỏ hàng
        Provider.of<CartService>(context, listen: false).clearCart();

        // Kiểm tra trạng thái widget trước khi chuyển trang
        if (!mounted) return;

        // Chuyển đến trang thanh toán thành công
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              orderId: orderId,
              paymentMethod: "PayPal",
            ),
          ),
        );
      } else {
        _showPaymentErrorSnackBar(result['message'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      print('❌ Lỗi chung: $e');
      _showPaymentErrorSnackBar('Đã xảy ra lỗi');
    } finally {
      // Đảm bảo reset trạng thái
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPaymentProcessed = false;
        });
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_selectedPaymentMethod == PaymentMethod.PAYPAL) {
      _processPayPal();
      return;
    }

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final String? userId = await userService.getUserId();

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xác định người dùng')),
        );
        return;
      }

      final patientResponse = await _patientService.getPatientProfileByUserId(userId);

      if (patientResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy hồ sơ bệnh nhân')),
        );
        return;
      }

      final patientId = patientResponse['id']?.toString();

      if (patientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không có thông tin patient ID')),
        );
        return;
      }

      final orderCode = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        _isLoading = true;
      });

      final result = await _orderService.createOrder(
        patientId: patientId,
        totalAmount: widget.totalAmount,
        orderCode: orderCode,
        discountAmount: widget.discountAmount,
        paymentMethod: _selectedPaymentMethod.toString().split('.').last,
        note: widget.note,
      );

      print('🛒 Kết quả tạo đơn hàng: $result');

      if (result['success'] == true) {
        final orderId = result['order_id'];

        try {
          await _orderService.createOrderDetails(
              int.parse(orderId),
              widget.cartItems
          );

          print('✅ Tạo chi tiết đơn hàng thành công');
        } catch (e) {
          print('❌ Lỗi khi tạo chi tiết đơn hàng: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi tạo chi tiết đơn hàng: $e')),
          );
          return;
        }

        Provider.of<CartService>(context, listen: false).clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Thanh toán thành công bằng ${_getPaymentMethodName(_selectedPaymentMethod)}")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              orderId: orderId,
              paymentMethod: _getPaymentMethodName(_selectedPaymentMethod),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Lỗi không xác định')),
        );
      }
    } catch (e) {
      print('❌ Lỗi chung: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn phương thức thanh toán"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Danh sách sản phẩm",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.medicine.medias.isNotEmpty
                                  ? item.medicine.medias.first.mediaUrl
                                  : 'https://via.placeholder.com/50',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/aspirin-100.jpg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          title: Text(item.medicine.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "x${item.quantity} - ${_formatCurrency(item.attribute.priceOut * item.quantity)}đ",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildPaymentMethods(),
                  SizedBox(height: 12),
                  _buildTotalAmount(),SizedBox(height: 16),
                  _buildConfirmButton(),
                ],
              ),
            ),
          ),
          // Overlay loading khi đang xử lý
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
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

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Phương thức thanh toán",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildPaymentOption("Tiền mặt", Icons.money, PaymentMethod.CASH),
        _buildPaymentOption("Ví THAVP", Icons.account_balance_wallet, PaymentMethod.BALANCEACCOUNT),
        _buildPaymentOption("PayPal", Icons.payment, PaymentMethod.PAYPAL),
      ],
    );
  }

  void _onPaymentMethodChanged(PaymentMethod value, String displayName) {
    print('🔄 Phương thức thanh toán đã chọn: $value (${displayName})');
    setState(() {
      _selectedPaymentMethod = value;
    });
  }

  Widget _buildPaymentOption(String displayName, IconData icon, PaymentMethod method) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(displayName),
      trailing: Radio<PaymentMethod>(
        value: method,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          if (value != null) _onPaymentMethodChanged(value, displayName);
        },
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Tổng cộng:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("${_formatCurrency(widget.totalAmount)}đ",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _confirmPayment,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isLoading ? Colors.grey : Colors.blue,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Text(
            "Xác nhận thanh toán",
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  PaymentMethod getPaymentMethodFromString(String value) {
    switch (value.toUpperCase()) {
      case 'CASH':
      case 'TIỀN MẶT':
        return PaymentMethod.CASH;
      case 'BALANCEACCOUNT':
      case 'VÍ THAVP':
        return PaymentMethod.BALANCEACCOUNT;
      case 'PAYPAL':
        return PaymentMethod.PAYPAL;
      default:
        return PaymentMethod.CASH; // Giá trị mặc định
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}