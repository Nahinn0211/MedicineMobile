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
  String _selectedPaymentMethod = "Tiền mặt";
  final _payPalEmailController = TextEditingController();
  final _payPalPasswordController = TextEditingController();
  bool _isPayPalSelected = false;
  final PatientService _patientService = PatientService();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  String? patientId;
  String? orderCode;

  String _formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return format.format(amount);
  }

  Future<void> _confirmPayment() async {
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

      // Tạo mã đơn hàng ngẫu nhiên
      final orderCode = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        _isLoading = true;
      });

      final result = await _orderService.createOrder(
        patientId: patientId,
        totalAmount: widget.totalAmount,
        orderCode: orderCode,
        discountAmount: widget.discountAmount,
        paymentMethod: _selectedPaymentMethod,
        note: widget.note,
      );

      print('🛒 Kết quả tạo đơn hàng: $result');

      if (result['success'] == true) {
        final orderId = result['order_id'];

        // Tạo chi tiết đơn hàng
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
          SnackBar(content: Text("Thanh toán thành công bằng $_selectedPaymentMethod")),
        );

        // Chuyển trang PaymentSuccessPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              orderId: orderId,
              paymentMethod: _selectedPaymentMethod,
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
                            "x${item.quantity} - ${_formatCurrency(item.totalPrice * item.quantity)}đ",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  _buildPaymentMethods(),
                  if (_isPayPalSelected) _buildPayPalForm(),
                  SizedBox(height: 12),
                  _buildTotalAmount(),
                  SizedBox(height: 16),
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

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Phương thức thanh toán",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _buildPaymentOption("Tiền mặt", Icons.money),
        _buildPaymentOption("Ví THAVP", Icons.account_balance_wallet),
        _buildPaymentOption("PayPal", Icons.payment),
      ],
    );
  }

  void _onPaymentMethodChanged(String value) {
    setState(() {
      _selectedPaymentMethod = value;
      _isPayPalSelected = value == "PayPal";
    });

    if (value == "PayPal") {
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) _payWithPayPal();
      });
    }
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(method),
      trailing: Radio<String>(
        value: method,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          if (value != null) _onPaymentMethodChanged(value);
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

  void _payWithPayPal() {
    double exchangeRate = 24000; // 1 USD = 24,000 VNĐ
    double totalInUSD = widget.totalAmount / exchangeRate;

    if (!mounted) return; // Kiểm tra widget trước khi gọi navigator

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UsePaypal(
          sandboxMode: true,
          clientId: "AZRIOnH-KUdZlGg1WLegmKjjdZKdMkHEHH31IgbtNPfuLHGzVbeQdaFpAfCcK67upsdnnQHThuERJmla",
          secretKey: "EEI_MYEmIAXL3IoUyVVI4cBRbvpEOeqRHTfbMslqObH8zK53bCbA3OM9JHzUrVU2sj9tyJ8TVjFWPxq7",
          returnURL: "https://medicinemedical.com/success",
          cancelURL: "https://example.com/cancel",

          transactions: [
            {
              "amount": {
                "total": totalInUSD.toStringAsFixed(2),
                "currency": "USD",
                "details": {
                  "subtotal": totalInUSD.toStringAsFixed(2),
                  "shipping": "0",
                  "handling_fee": "0",
                  "tax": "0",
                  "shipping_discount": "0"
                }
              },
              "description": "Thanh toán đơn hàng (VNĐ: ${widget.totalAmount})",
            }
          ],
          note: "Cảm ơn bạn đã mua hàng!",
          onSuccess: (Map params) async {
            if (!context.mounted) return;
            print("✅ Thanh toán thành công: $params");

            Navigator.pop(context); // Đóng trang PayPal trước khi xử lý

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Thanh toán PayPal thành công!")),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSuccessPage(
                    orderId: params["order_id"]?.toString() ?? "N/A",
                  ),
                ),
              );
            });
          },


          onCancel: (Map params) {
            if (!context.mounted) return;
            print("⚠️ Thanh toán bị hủy: $params");

            Navigator.pop(context);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Bạn đã hủy thanh toán PayPal")),
              );
            });
          },


          onError: (error) {
            if (!context.mounted) return;
            print("❌ Lỗi thanh toán: $error");

            Navigator.pop(context); // Đóng trang PayPal trước khi xử lý

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Lỗi thanh toán PayPal")),
              );
            });
          },

        ),
      ),
    );
  }


  Widget _buildPayPalForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nhập thông tin PayPal",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: _payPalEmailController,
            decoration: InputDecoration(
              labelText: "Email PayPal",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 8),
          TextField(
            controller: _payPalPasswordController,
            decoration: InputDecoration(
              labelText: "Mật khẩu PayPal",
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
        ],
      ),
    );
  }



}