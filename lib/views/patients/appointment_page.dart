import 'package:flutter/material.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/models/service.dart';
import 'package:medical_storage/services/booking_service.dart';
import 'package:medical_storage/views/patients/payment_page.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  final DoctorProfile? doctor;
  final Service? service;

  const AppointmentPage({Key? key, this.doctor, this.service}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final BookingService _bookingService = BookingService();

  DateTime? _selectedDate;
  String? selectedTimeSlot;
  final List<String> _allTimeSlots = ['08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'];
  List<String> _availableTimeSlots = [];
  List<String> _bookedTimeSlots = [];

  bool _isLoading = false;
  bool _isCheckingAvailability = false;

  @override
  void initState() {
    super.initState();
    _availableTimeSlots = List.from(_allTimeSlots);

    // Khởi tạo ngày được chọn là ngày mai
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    if (_selectedDate != null && widget.doctor != null) {
      _checkAvailability(_selectedDate!);
    }
  }

  Future<void> _checkAvailability(DateTime date) async {
    if (widget.doctor == null || widget.doctor!.id == null) {
      setState(() {
        _availableTimeSlots = List.from(_allTimeSlots);
      });
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
    });

    try {
      // Lấy danh sách các khung giờ đã đặt
      final doctorId = widget.doctor!.id ?? '0';
      final bookedSlots = await _bookingService.getDoctorBookedSlots(doctorId, date);

      if (mounted) {
        setState(() {
          _bookedTimeSlots = bookedSlots;

          // Cập nhật danh sách các khung giờ có sẵn
          _availableTimeSlots = _allTimeSlots.where((slot) {
            return !_bookedTimeSlots.contains(slot);
          }).toList();

          _isCheckingAvailability = false;
        });
      }
    } catch (e) {
      print('Error checking availability: $e');
      if (mounted) {
        setState(() {
          _isCheckingAvailability = false;
          _availableTimeSlots = List.from(_allTimeSlots); // Mặc định hiển thị tất cả nếu có lỗi
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể kiểm tra lịch của bác sĩ. Vui lòng thử lại sau.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt lịch hẹn'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Phần thông tin đã chọn
          _buildSelectedInfo(),

          // Phần nội dung chính
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Xác nhận lịch hẹn',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Vui lòng chọn thời gian phù hợp với lịch của bạn.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24),

                  // Chọn ngày
                  Text(
                    'Thời gian tư vấn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildDateField(context),
                  SizedBox(height: 16),

                  // Chọn khung giờ
                  if (_selectedDate != null)
                    _isCheckingAvailability
                        ? Center(
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          CircularProgressIndicator(strokeWidth: 2),
                          SizedBox(height: 8),
                          Text('Đang kiểm tra lịch của bác sĩ...'),
                        ],
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chọn khung giờ:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_bookedTimeSlots.isNotEmpty)
                              Text(
                                '${_availableTimeSlots.length} khung giờ trống',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildTimeSlots(),
                        if (_bookedTimeSlots.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Các khung giờ xám đã được đặt.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Nút tiếp tục cố định ở cuối màn hình
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildSelectedInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ảnh bác sĩ hoặc avatar
          CircleAvatar(
            radius: 25,
            backgroundImage: widget.doctor?.user.avatar != null && widget.doctor!.user.avatar!.isNotEmpty
                ? NetworkImage(widget.doctor!.user.avatar!)
                : null,
            child: widget.doctor?.user.avatar == null || widget.doctor!.user.avatar!.isEmpty
                ? const Icon(Icons.person, size: 25, color: Colors.white)
                : null,
          ),

          const SizedBox(width: 12),

          // Thông tin dịch vụ và bác sĩ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.service != null)
                  Text(
                    widget.service!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                if (widget.doctor != null)
                  Text(
                    widget.doctor!.user.fullName,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Giá dịch vụ
          if (widget.service != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatCurrency(widget.service!.price),
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blueAccent),
          ),
          SizedBox(width: 12),
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
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
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

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Chọn ngày khám',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.calendar_today),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      controller: TextEditingController(
        text: _selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
            : '',
      ),
      onTap: () async {
        final DateTime now = DateTime.now();
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? now.add(Duration(days: 1)),
          firstDate: now,
          lastDate: now.add(Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blueAccent,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            selectedTimeSlot = null; // Reset thời gian khi chọn ngày mới
          });

          // Kiểm tra khả năng sẵn có cho ngày đã chọn
          await _checkAvailability(pickedDate);
        }
      },
    );
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _allTimeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = _allTimeSlots[index];
        final isSelected = selectedTimeSlot == timeSlot;
        final isAvailable = _availableTimeSlots.contains(timeSlot);

        return GestureDetector(
          onTap: isAvailable ? () {
            setState(() {
              selectedTimeSlot = timeSlot;
            });
          } : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent
                  : isAvailable
                  ? Colors.grey.shade100
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.blueAccent
                    : isAvailable
                    ? Colors.grey.shade300
                    : Colors.grey.shade400,
              ),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isAvailable
                      ? Colors.black87
                      : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    final bool canContinue = _selectedDate != null &&
        selectedTimeSlot != null &&
        !_isCheckingAvailability;

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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canContinue ? _proceedToPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Text(
            'Tiếp tục thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _proceedToPayment() async {
    if (_selectedDate == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ngày và giờ tư vấn'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Kiểm tra lần cuối xem khung giờ có còn trống không
      if (widget.doctor != null && widget.doctor!.id != null) {
        final doctorId = widget.doctor!.id ?? '0';
        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

        final isAvailable = await _bookingService.checkDoctorAvailability(
            doctorId,
            dateStr,
            selectedTimeSlot!
        );

        if (!isAvailable) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Khung giờ này vừa được đặt. Vui lòng chọn khung giờ khác.'),
              backgroundColor: Colors.red,
            ),
          );

          // Làm mới danh sách khung giờ
          await _checkAvailability(_selectedDate!);
          return;
        }
      }

      // Chuyển sang trang thanh toán
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(
              service: widget.service,
              doctor: widget.doctor,
              appointmentDate: _selectedDate!,
              appointmentTime: selectedTimeSlot!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    ) + ' đ';
  }
}