import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:intl/intl.dart';
import 'package:medical_storage/services/user_service.dart';

class DepositPage extends StatefulWidget {
  final double currentBalance;

  const DepositPage({Key? key, this.currentBalance = 0.0}) : super(key: key);

  @override
  _DepositPageState createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;
  double _userBalance = 0.0; // Biến mới để lưu số dư thực tế

  @override
  void initState() {
    super.initState();
    // Lấy thông tin số dư khi trang được khởi tạo
    _fetchUserBalance();
  }

  // Phương thức mới để lấy số dư của người dùng
  Future<void> _fetchUserBalance() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        final patientData = await _userService.getDataUser(userId);
        if (patientData != null) {
          setState(() {
            _userBalance = patientData.accountBalance ?? 0.0;
          });
        }
      }
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin số dư: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Format currency for display
  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  // Validate and prepare amount for processing
  double? _getValidAmount() {
    if (_formKey.currentState!.validate()) {
      // Remove non-numeric characters and parse
      String cleanedText = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
      return double.tryParse(cleanedText);
    }
    return null;
  }

  void _processPayPal(double amount) {
    setState(() {
      _isProcessing = true;
    });

    // Tạo biến để theo dõi xem giao dịch đã hoàn thành hay chưa
    bool _transactionProcessed = false;

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
                "total": (amount / 23000).toStringAsFixed(2),
                "currency": "USD",
              },
              "description": "Nạp tiền vào tài khoản",
            }
          ],
          note: "Thanh toán an toàn qua PayPal",
          onSuccess: (Map params) async {
            // Đảm bảo chỉ xử lý giao dịch một lần
            if (_transactionProcessed) return;
            _transactionProcessed = true;

            print("PayPal onSuccess được gọi với params: $params");

            // Quay về màn hình chính trước khi thực hiện xử lý tiếp theo
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // Xử lý thành công riêng biệt
            _handlePaymentSuccess(amount);
          },
          onError: (error) {
            // Đảm bảo chỉ xử lý lỗi một lần
            if (_transactionProcessed) return;
            _transactionProcessed = true;

            print("PayPal onError được gọi với lỗi: $error");

            // Quay về màn hình chính
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            if (mounted) {
              setState(() {
                _isProcessing = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi thanh toán: ${error.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onCancel: (params) async {
            // Đảm bảo chỉ xử lý hủy một lần
            if (_transactionProcessed) return;
            _transactionProcessed = true;

            print("PayPal onCancel được gọi với params: $params");

            // Kiểm tra xem URL có chứa PayerID không, nếu có thì xử lý như một giao dịch thành công
            if (params != null && params.containsKey('PayerID') && params['PayerID'] != null) {
              print("Phát hiện PayerID trong params onCancel - xử lý như thanh toán thành công");

              // Quay về màn hình chính trước khi thực hiện xử lý tiếp theo
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }

              // Xử lý như một giao dịch thành công
              _handlePaymentSuccess(amount);
              return;
            }

            // Nếu không có PayerID, xử lý như thông thường (hủy giao dịch)
            // Quay về màn hình chính
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            if (mounted) {
              setState(() {
                _isProcessing = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã hủy giao dịch'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
      ),
    ).then((_) {
      // Đảm bảo rằng trạng thái được cập nhật khi màn hình PayPal đóng
      // ngay cả khi các callback không được gọi
      if (!_transactionProcessed && mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  // Phương thức riêng biệt để xử lý thanh toán thành công
  void _handlePaymentSuccess(double amount) async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true; // Hiển thị loading trong quá trình cập nhật số dư
    });

    try {
      // Lấy ID người dùng hiện tại
      final userId = await _userService.getUserId();
      final patientData = await _userService.getDataUser(userId);

      if (userId == null || patientData == null) {
        if (!mounted) return;

        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy thông tin người dùng.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Gọi API để cập nhật số dư
      print("Đang cập nhật số dư cho patientID: ${patientData.id} với số tiền: $amount");
      final updatedProfile = await _userService.updateBalance(patientData.id, amount);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        // Cập nhật số dư mới nếu thành công
        if (updatedProfile != null) {
          _userBalance = updatedProfile.accountBalance ?? 0.0;
        }
      });

      if (updatedProfile != null) {
        // Trả về kết quả cho màn hình trước đó
        Navigator.pop(context, {
          'success': true,
          'amount': amount,
          'newBalance': updatedProfile.accountBalance,
        });

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã nạp thành công ${_formatCurrency(amount)} vào tài khoản.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Xử lý trường hợp cập nhật thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật số dư tài khoản. Vui lòng kiểm tra lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Lỗi trong quá trình xử lý thanh toán: $e');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nạp tiền'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _isProcessing
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Đang xử lý...'),
          ],
        ),
      )
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current balance display - Sử dụng _userBalance thay vì widget.currentBalance
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số dư hiện tại:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Flexible(
                          child: Text(
                            _formatCurrency(_userBalance),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nút làm mới số dư
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _fetchUserBalance,
                      icon: Icon(Icons.refresh, size: 16),
                      label: Text('Làm mới số dư'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    'Nhập số tiền cần nạp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Amount input field with formatting
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CurrencyInputFormatter(),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Số tiền',
                      hintText: '100,000',
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'VND',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }

                      String cleanedText = value.replaceAll(RegExp(r'[^\d]'), '');
                      double? amount = double.tryParse(cleanedText);

                      if (amount == null) {
                        return 'Số tiền không hợp lệ';
                      }

                      if (amount < 10000) {
                        return 'Số tiền tối thiểu là 10,000₫';
                      }

                      if (amount > 10000000) {
                        return 'Số tiền tối đa là 10,000,000₫';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 16),

                  // Quick amount selection
                  Text(
                    'Chọn nhanh:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),

                  SizedBox(height: 8),

                  // Fixed: Quick amount buttons - Now wraps properly on smaller screens
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickAmountButton(50000),
                      _buildQuickAmountButton(100000),
                      _buildQuickAmountButton(200000),
                      _buildQuickAmountButton(500000),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Payment method selection (simplified for PayPal only)
                  Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Fixed: Image is now constrained with FittedBox and ConstrainedBox
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: screenWidth * 0.2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/PayPal.svg/1200px-PayPal.svg.png',
                              height: 40,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'PayPal',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        double? amount = _getValidAmount();
                        if (amount != null) {
                          _processPayPal(amount);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Xác nhận nạp tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Note about security
                  Center(
                    child: Text(
                      'Giao dịch được bảo mật bởi PayPal',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for quick amount selection
  Widget _buildQuickAmountButton(double amount) {
    return InkWell(
      onTap: () {
        setState(() {
          _amountController.text = _formatCurrency(amount);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          _formatCurrency(amount),
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// Custom input formatter for currency
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only keep digits
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Handle potential parsing errors
    if (newText.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse to double and format
    double value = double.parse(newText);
    final formatCurrency = NumberFormat("#,###", "vi_VN");
    String formattedValue = formatCurrency.format(value);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}