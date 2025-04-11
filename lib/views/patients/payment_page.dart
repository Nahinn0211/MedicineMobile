import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/models/service.dart';
import 'package:medical_storage/services/auth_service.dart';
import 'package:medical_storage/services/booking_service.dart';
import 'package:medical_storage/services/user_service.dart';
import 'package:medical_storage/views/patients/Profile/booking_success.dart';


class PaymentPage extends StatefulWidget {
  final Service? service;
  final DoctorProfile? doctor;
  final DateTime appointmentDate;
  final String appointmentTime;

  const PaymentPage({
    Key? key,
    required this.service,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  double _accountBalance = 0;
  String _selectedPaymentMethod = 'balanceAccount'; // 'balanceAccount' hoặc 'paypal'
  String? _userId;
  String? _patientId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
        _userId = await _authService.getUserId();

        // Lấy thông tin bệnh nhân và số dư tài khoản
        final patientData = await _userService.getDataUser(_userId);
        _patientId = patientData?.id;
        _accountBalance = patientData?.accountBalance ?? 0;
    } catch (e) {
      _showError('Không thể tải thông tin người dùng: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _processBooking() async {
    if (_patientId == null) {
      _showError('Không thể lấy thông tin bệnh nhân');
      return;
    }

    // Kiểm tra số dư nếu thanh toán bằng ví
    if (_selectedPaymentMethod == 'balanceAccount' &&
        _accountBalance < (widget.service?.price ?? 0)) {
      _showError('Số dư không đủ để thanh toán');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra lại lịch bác sĩ trước khi đặt
      if (widget.doctor != null && widget.doctor!.id != null) {
        final doctorId = widget.doctor!.id ?? '0';
        final formattedDate = DateFormat('yyyy-MM-dd').format(widget.appointmentDate);

        final isAvailable = await _bookingService.checkDoctorAvailability(
            doctorId,
            formattedDate,
            widget.appointmentTime
        );

        if (!isAvailable) {
          _showError('Khung giờ này vừa được đặt. Vui lòng quay lại chọn khung giờ khác.');
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Tạo đặt lịch mới
        await _bookingService.createBooking(
          serviceId: widget.service?.id != null ? widget.service!.id! : '0',
          doctorId: doctorId,
          patientId: _patientId ?? '0',
          totalPrice: widget.service?.price ?? 0,
          paymentMethod: _selectedPaymentMethod.toUpperCase(),
          appointmentDate: formattedDate,
          appointmentTime: widget.appointmentTime,
        );

        // Nếu thanh toán bằng ví, cập nhật số dư
        if (_selectedPaymentMethod == 'balanceAccount') {
          final newBalance = _accountBalance - (widget.service?.price ?? 0);
          await _bookingService.updateAccountBalance(_patientId!, widget.service!.price.toString());
        }

        // Chuyển đến trang thành công
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingSuccessPage(
                doctorName: widget.doctor?.user.fullName ?? 'Bác sĩ',
                serviceName: widget.service?.name ?? 'Dịch vụ',
                appointmentDate: widget.appointmentDate,
                appointmentTime: widget.appointmentTime,
              ),
            ),
          );
        }
      } else {
        _showError('Thông tin bác sĩ không hợp lệ');
      }
    } catch (e) {
      _showError('Lỗi khi đặt lịch: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin đặt lịch
                      _buildBookingInfo(),
                      const SizedBox(height: 16),

                      // Tổng thanh toán
                      _buildPaymentSummary(),
                      const SizedBox(height: 16),

                      // Phương thức thanh toán
                      _buildPaymentMethods(),
                      const SizedBox(height: 16),

                      // Thông tin số dư ví nếu chọn thanh toán bằng ví
                      if (_selectedPaymentMethod == 'balanceAccount')
                        _buildBalanceInfo(),
                    ],
                  ),
                ),
              ),

              // Nút thanh toán cố định ở dưới
              _buildPaymentButton(),
            ],
          ),

          // Hiển thị thông báo lỗi nếu có
          if (_errorMessage != null)
            _buildErrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đặt lịch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin dịch vụ
            _buildInfoItem(
              icon: Icons.medical_services,
              label: 'Dịch vụ:',
              value: widget.service?.name ?? 'Không xác định',
            ),

            // Thông tin bác sĩ
            _buildInfoItem(
              icon: Icons.person,
              label: 'Bác sĩ:',
              value: widget.doctor?.user.fullName ?? 'Không xác định',
            ),

            // Ngày tư vấn
            _buildInfoItem(
              icon: Icons.calendar_today,
              label: 'Ngày tư vấn:',
              value: DateFormat('dd/MM/yyyy').format(widget.appointmentDate),
            ),

            // Giờ tư vấn
            _buildInfoItem(
              icon: Icons.access_time,
              label: 'Giờ tư vấn:',
              value: widget.appointmentTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blueAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),

            // Chi tiết tổng thanh toán
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Giá dịch vụ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Giá dịch vụ:',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _formatCurrency(widget.service?.price ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Đường phân cách
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),

                  // Tổng cộng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatCurrency(widget.service?.price ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),

            // Hai phương thức thanh toán
            Row(
              children: [
                // Phương thức ví THAPV
                Expanded(
                  child: _buildPaymentMethodCard(
                    id: 'balanceAccount',
                    title: 'Ví THAPV',
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),

                // Phương thức PayPal
                Expanded(
                  child: _buildPaymentMethodCard(
                    id: 'paypal',
                    title: 'PayPal',
                    icon: Icons.payment,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String id,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blueAccent : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo() {
    final bool isBalanceSufficient = _accountBalance >= (widget.service?.price ?? 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin số dư',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Icon(
                  isBalanceSufficient ? Icons.check_circle : Icons.warning,
                  color: isBalanceSufficient ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chi tiết số dư
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Số dư hiện tại
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số dư hiện tại:',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        _formatCurrency(_accountBalance),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Đường phân cách
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),

                  // Số dư sau thanh toán
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Số dư sau thanh toán:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatCurrency(isBalanceSufficient
                            ? _accountBalance - (widget.service?.price ?? 0)
                            : _accountBalance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isBalanceSufficient ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  // Cảnh báo nếu số dư không đủ
                  if (!isBalanceSufficient)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Số dư không đủ để thanh toán. Vui lòng nạp thêm tiền hoặc chọn phương thức thanh toán khác.',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildPaymentButton() {
    final bool canProceed = _selectedPaymentMethod == 'paypal' ||
        (_selectedPaymentMethod == 'balanceAccount' &&
            _accountBalance >= (widget.service?.price ?? 0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProceed ? _processBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Xác nhận thanh toán',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return GestureDetector(
      onTap: _clearError,
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Đã xảy ra lỗi không xác định',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _clearError,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    ) + ' đ';
  }
}