import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_storage/models/appointment.dart';
import 'package:medical_storage/models/appointment_status.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/services/appointment_service.dart';
import 'package:medical_storage/services/auth_service.dart';
import 'package:medical_storage/services/user_service.dart';
import 'package:medical_storage/widgets/HomeWidget/bottom_bar.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> with SingleTickerProviderStateMixin {
  // Using dependency injection pattern for better testability
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  late TabController _tabController;
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    if (!mounted) return; // Safety check to prevent setState after dispose

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Validate user authentication
      if (!await _authService.isLoggedIn()) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // Fetch user data with proper error handling
      final String? userId = await _userService.getUserId();
      if (userId == null) {
        throw const AppointmentException('User ID not found');
      }

      final PatientProfile? patientProfile = await _userService.getDataUser(userId);
      if (patientProfile?.id == null) {
        throw const AppointmentException('Patient profile not found');
      }

      // Get appointments for the patient
      final appointments = await _appointmentService.getAppointmentsByPatient(patientProfile!.id!);

      if (!mounted) return;
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e is AppointmentException
          ? e.message
          : 'Không thể tải danh sách lịch tư vấn: $e';

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });

      _showErrorSnackBar(errorMsg);
    }
  }

  /// Shows an error message in a SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Thử lại',
          textColor: Colors.white,
          onPressed: _fetchAppointments,
        ),
      ),
    );
  }

  void _joinConsultation(Appointment appointment) async {
    try {
      // Show loading indicator
      _showLoadingDialog('Đang kết nối...');
      // Get consultation by appointment ID
      final String? appointmentId = appointment.serviceBooking?.id;
      if (appointmentId == null) {
        throw Exception('ID của lịch đặt không tồn tại');
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Navigate to consultation page
      // Trong phương thức _joinConsultation
      Navigator.pushNamed(
        context,
        '/consultation',
        arguments: {
          'consultationId': appointment.consultation?.id ?? "",
          'consultationCode': appointment.consultation?.consultationCode ?? "",
          'doctor': appointment.doctor,
          'patient': appointment.patient,
          'appointment': appointment,
          'userId': appointment.patient?.user.id ?? "", // Đảm bảo bạn đã truyền userId vào
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Không thể kết nối: $e');
    }
  }

  /// Builds an appointment card with responsive layout
  Widget _buildAppointmentCard(Appointment appointment) {
    final AppointmentStatus appointmentStatus = appointment.status;
    final statusColor = _getStatusColor(appointmentStatus);
    final statusText = _getStatusText(appointmentStatus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with doctor name and status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.doctor!.user.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(statusText, statusColor),
              ],
            ),
            const SizedBox(height: 12),

            // Appointment details
            _buildInfoRow(Icons.medical_services_outlined, appointment.serviceBooking!.service!.name),
            _buildInfoRow(Icons.calendar_today, _formatDate(appointment.parseAppointmentDate())),
            _buildInfoRow(Icons.access_time, _formatTime(appointment.parseAppointmentTime())),
            _buildInfoRow(Icons.payment, '${_formatCurrency(appointment.serviceBooking!.service!.price)} VND'),

            const SizedBox(height: 16),

            // Action buttons section with responsive layout
            _buildActionButtons(appointment, appointmentStatus),
          ],
        ),
      ),
    );
  }

  /// Creates a status badge with appropriate styling
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds responsive action buttons based on appointment status
  Widget _buildActionButtons(Appointment appointment, AppointmentStatus status) {
    // Collecting buttons based on status
    final List<Widget> buttons = [];

    if (status == AppointmentStatus.SCHEDULED) {
      // Check if appointment is within 30 minutes or currently active
      final DateTime now = DateTime.now();
      final DateTime appointmentDate = appointment.parseAppointmentDate();
      final TimeOfDay appointmentTime = appointment.parseAppointmentTime();
      final DateTime appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        appointmentTime.hour,
        appointmentTime.minute,
      );

      // Calculate time difference
      final Duration difference = appointmentDateTime.difference(now);

      // Check if appointment is within 30 minutes or currently active
      // (within 30 min before start up to 1 hour after start)
      final bool isWithin30MinBeforeOrDuring = difference.inMinutes <= 30 && difference.inMinutes > -60;

      if (isWithin30MinBeforeOrDuring) {
        buttons.add(
          ElevatedButton.icon(
            onPressed: () => _joinConsultation(appointment),
            icon: const Icon(Icons.videocam, size: 18),
            label: const Text('Vào tư vấn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        );
      }

      // Always add Cancel button for scheduled appointments
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showCancelDialog(appointment),
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: const Text('Hủy lịch'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
      );
    } else if (status == AppointmentStatus.COMPLETED) {
      // Existing code for completed appointments
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _showReviewDialog(appointment),
          icon: const Icon(Icons.rate_review, size: 18),
          label: const Text('Đánh giá'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
        ),
      );

      if (appointment.prescriptions.isNotEmpty) {
        buttons.add(
          ElevatedButton.icon(
            onPressed: () => _viewPrescription(appointment),
            icon: const Icon(Icons.medication, size: 18),
            label: const Text('Đơn thuốc'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        );
      }
    }

    // Return responsive button layout for different screen sizes
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: buttons,
    );
  }

  /// Creates a consistent info row with icon and text
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Maps appointment status to appropriate color
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.SCHEDULED:
        return Colors.blue;
      case AppointmentStatus.COMPLETED:
        return Colors.green;
      case AppointmentStatus.CANCELLED:
        return Colors.red;
      case AppointmentStatus.PENDING:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Maps appointment status to localized text
  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.SCHEDULED:
        return 'Sắp tới';
      case AppointmentStatus.COMPLETED:
        return 'Đã hoàn thành';
      case AppointmentStatus.CANCELLED:
        return 'Đã hủy';
      case AppointmentStatus.PENDING:
        return 'Đang chờ';
      default:
        return 'Không xác định';
    }
  }

  /// Formats date consistently throughout the app
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formats time consistently throughout the app
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats currency according to Vietnamese locale
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }

  /// Builds a date/time picker for rescheduling
  Widget _buildDateTimePicker(Appointment appointment) {
    // This is a placeholder for the actual implementation
    // In a real app, you would create a date/time picker here
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'Tính năng đang được phát triển',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Shows dialog for cancelling an appointment
  void _showCancelDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch tư vấn'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch tư vấn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _cancelAppointment(appointment);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
  }

  /// Handles the appointment cancellation logic
  Future<void> _cancelAppointment(Appointment appointment) async {
    try {
      // Show loading indicator
      _showLoadingDialog('Đang hủy lịch...');

      if (appointment.serviceBooking?.id != null) {
        await _appointmentService.cancelAppointment(appointment.serviceBooking!.id);
      } else {
        throw Exception('ID của lịch đặt không tồn tại');
      }

      // For demo, we'll just wait to simulate network call
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      _showSuccessSnackBar('Hủy lịch thành công');

      // Refresh appointments list
      _fetchAppointments();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Không thể hủy lịch: $e');
    }
  }

  /// Shows loading dialog with custom message
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Shows a success message in a SnackBar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows dialog for reviewing a completed appointment
  void _showReviewDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá buổi tư vấn'),
        content: const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Tính năng đang được phát triển',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Shows dialog for viewing prescription details
  void _viewPrescription(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đơn thuốc'),
        content: const SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'Tính năng đang được phát triển',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Builds empty state widget with appropriate message
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/services'),
            icon: const Icon(Icons.add),
            label: const Text('Đặt lịch tư vấn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Lịch tư vấn của tôi'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã hoàn thành'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAppointments,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          // Upcoming appointments
          _buildAppointmentList(AppointmentStatus.SCHEDULED),

          // Completed appointments
          _buildAppointmentList(AppointmentStatus.COMPLETED),

          // Cancelled appointments
          _buildAppointmentList(AppointmentStatus.CANCELLED),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
        bottomNavType: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/services');
              break;
            case 2:
              Navigator.pushNamed(context, '/cart');
              break;
            case 3:
            // Already on appointments page, do nothing
              break;
          }
        },
        onNavTypeChanged: (_) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/services'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Đặt lịch tư vấn mới',
      ),
    );
  }

  /// Builds appointment list for a specific status

  Widget _buildAppointmentList(AppointmentStatus status) {
    // Lấy ngày hiện tại
    final DateTime now = DateTime.now();

    // Lọc danh sách các cuộc hẹn
    final List<Appointment> filteredAppointments = _appointments
        .where((appointment) {
      // Nếu đang ở tab Sắp tới (SCHEDULED), cần kiểm tra thêm thời gian
      if (status == AppointmentStatus.SCHEDULED) {
        // Lấy thời gian đầy đủ của cuộc hẹn
        final DateTime appointmentDate = appointment.parseAppointmentDate();
        final TimeOfDay appointmentTime = appointment.parseAppointmentTime();
        final DateTime appointmentDateTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          appointmentTime.hour,
          appointmentTime.minute,
        );

        // Chỉ hiển thị lịch sắp tới nếu: đúng trạng thái VÀ thời gian trong tương lai
        return appointment.status == status && appointmentDateTime.isAfter(now);
      }

      // Với các tab khác (Đã hoàn thành, Đã hủy) chỉ cần kiểm tra trạng thái
      return appointment.status == status;
    })
        .toList();

    // Hiển thị trạng thái trống nếu không có cuộc hẹn nào
    if (filteredAppointments.isEmpty) {
      String message;
      switch (status) {
        case AppointmentStatus.SCHEDULED:
          message = 'Bạn không có lịch tư vấn nào sắp tới';
          break;
        case AppointmentStatus.COMPLETED:
          message = 'Bạn chưa có lịch tư vấn nào đã hoàn thành';
          break;
        case AppointmentStatus.CANCELLED:
          message = 'Bạn không có lịch tư vấn nào đã hủy';
          break;
        case AppointmentStatus.PENDING:
          message = 'Bạn không có lịch tư vấn nào đang chờ';
          break;
        default:
          message = 'Không có lịch tư vấn nào';
          break;
      }
      return _buildEmptyState(message);
    }

    // Sắp xếp lịch hẹn theo thời gian (nếu là tab Sắp tới)
    if (status == AppointmentStatus.SCHEDULED) {
      filteredAppointments.sort((a, b) {
        final dateA = a.parseAppointmentDate();
        final timeA = a.parseAppointmentTime();
        final dateTimeA = DateTime(dateA.year, dateA.month, dateA.day, timeA.hour, timeA.minute);

        final dateB = b.parseAppointmentDate();
        final timeB = b.parseAppointmentTime();
        final dateTimeB = DateTime(dateB.year, dateB.month, dateB.day, timeB.hour, timeB.minute);

        return dateTimeA.compareTo(dateTimeB);
      });
    }

    // Hiển thị danh sách cuộc hẹn
    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: filteredAppointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(filteredAppointments[index]);
        },
      ),
    );
  }
}

/// Custom exception class for appointment-related errors
class AppointmentException implements Exception {
  final String message;

  const AppointmentException(this.message);

  @override
  String toString() => message;
}