// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:medical_storage/models/appointment.dart';
// import 'package:medical_storage/models/appointment_status.dart';
// import 'package:medical_storage/services/appointment_service.dart';
// import 'package:medical_storage/services/auth_service.dart';
// import 'package:medical_storage/services/user_service.dart';
// import 'package:medical_storage/widgets/HomeWidget/bottom_bar.dart';
//
// class AppointmentPage extends StatefulWidget {
//   const AppointmentPage({Key? key}) : super(key: key);
//
//   @override
//   _AppointmentPageState createState() => _AppointmentPageState();
// }
//
// class _AppointmentPageState extends State<AppointmentPage> with SingleTickerProviderStateMixin {
//   final AppointmentService _appointmentService = AppointmentService();
//   final AuthService _authService = AuthService();
//   final UserService _userService = UserService();
//
//   late TabController _tabController;
//   List<Appointment> _appointments = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchAppointments();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetchAppointments() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final isLoggedIn = await _authService.isLoggedIn();
//       if (!isLoggedIn) {
//         Navigator.of(context).pushReplacementNamed('/login');
//         return;
//       }
//
//       final String? userId = await _userService.getUserId();
//       if (userId == null) {
//         throw Exception('User ID not found');
//       }
//
//       final appointments = await _appointmentService.getUserAppointments(userId);
//
//       setState(() {
//         _appointments = appointments;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _errorMessage = 'Không thể tải danh sách lịch tư vấn: $e';
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Không thể tải danh sách lịch tư vấn: $e'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }
//
//   List<Appointment> _getFilteredAppointments(AppointmentStatus status) {
//     return _appointments.where((appointment) => appointment.status == status).toList();
//   }
//
//   Widget _buildAppointmentCard(Appointment appointment) {
//     final statusColor = _getStatusColor(appointment.status);
//     final statusText = _getStatusText(appointment.status);
//
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     appointment.doctorName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     statusText,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow(Icons.medical_services_outlined, appointment.serviceName),
//             _buildInfoRow(Icons.calendar_today, _formatDate(appointment.appointmentDate)),
//             _buildInfoRow(Icons.access_time, _formatTime(appointment.appointmentTime)),
//             _buildInfoRow(Icons.payment, '${_formatCurrency(appointment.price)} VND'),
//
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 if (appointment.status == AppointmentStatus.SCHEDULED)
//                   ElevatedButton.icon(
//                     onPressed: () => _showRescheduleDialog(appointment),
//                     icon: const Icon(Icons.event_available, size: 18),
//                     label: const Text('Đổi lịch'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 if (appointment.status == AppointmentStatus.SCHEDULED)
//                   ElevatedButton.icon(
//                     onPressed: () => _showCancelDialog(appointment),
//                     icon: const Icon(Icons.cancel_outlined, size: 18),
//                     label: const Text('Hủy lịch'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.redAccent,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 if (appointment.status == AppointmentStatus.COMPLETED)
//                   ElevatedButton.icon(
//                     onPressed: () => _showReviewDialog(appointment),
//                     icon: const Icon(Icons.rate_review, size: 18),
//                     label: const Text('Đánh giá'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.amber,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 if (appointment.status == AppointmentStatus.COMPLETED && appointment.hasPrescription)
//                   ElevatedButton.icon(
//                     onPressed: () => _viewPrescription(appointment),
//                     icon: const Icon(Icons.medication, size: 18),
//                     label: const Text('Đơn thuốc'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(fontSize: 16, color: Colors.grey[800]),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getStatusColor(AppointmentStatus status) {
//     switch (status) {
//       case AppointmentStatus.SCHEDULED:
//         return Colors.blue;
//       case AppointmentStatus.COMPLETED:
//         return Colors.green;
//       case AppointmentStatus.CANCELLED:
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String _getStatusText(AppointmentStatus status) {
//     switch (status) {
//       case AppointmentStatus.SCHEDULED:
//         return 'Sắp tới';
//       case AppointmentStatus.COMPLETED:
//         return 'Đã hoàn thành';
//       case AppointmentStatus.CANCELLED:
//         return 'Đã hủy';
//       default:
//         return 'Không xác định';
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     return DateFormat('dd/MM/yyyy').format(date);
//   }
//
//   String _formatTime(TimeOfDay time) {
//     final hour = time.hour.toString().padLeft(2, '0');
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }
//
//   String _formatCurrency(double amount) {
//     final formatter = NumberFormat('#,###', 'vi_VN');
//     return formatter.format(amount);
//   }
//
//   void _showRescheduleDialog(Appointment appointment) {
//     // Implementation for rescheduling appointment
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Đổi lịch tư vấn'),
//         content: const Text('Tính năng đang được phát triển'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Đóng'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showCancelDialog(Appointment appointment) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Hủy lịch tư vấn'),
//         content: const Text('Bạn có chắc chắn muốn hủy lịch tư vấn này?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Không'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Colors.redAccent,
//             ),
//             child: const Text('Hủy lịch'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showReviewDialog(Appointment appointment) {
//     // Implementation for reviewing completed appointment
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Đánh giá buổi tư vấn'),
//         content: const Text('Tính năng đang được phát triển'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Đóng'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _viewPrescription(Appointment appointment) {
//     // Implementation for viewing prescription
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Đơn thuốc'),
//         content: const Text('Tính năng đang được phát triển'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Đóng'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () => Navigator.pushNamed(context, '/services'),
//             icon: const Icon(Icons.add),
//             label: const Text('Đặt lịch tư vấn'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blueAccent,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: const Text('Lịch tư vấn của tôi'),
//         centerTitle: true,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           tabs: const [
//             Tab(text: 'Sắp tới'),
//             Tab(text: 'Đã hoàn thành'),
//             Tab(text: 'Đã hủy'),
//           ],
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_errorMessage!),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _fetchAppointments,
//               child: const Text('Thử lại'),
//             ),
//           ],
//         ),
//       )
//           : TabBarView(
//         controller: _tabController,
//         children: [
//           // Upcoming appointments
//           _buildAppointmentList(AppointmentStatus.SCHEDULED),
//
//           // Completed appointments
//           _buildAppointmentList(AppointmentStatus.COMPLETED),
//
//           // Cancelled appointments
//           _buildAppointmentList(AppointmentStatus.CANCELLED),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavigationBar(
//         selectedIndex: 3,
//         bottomNavType: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               Navigator.pushNamed(context, '/home');
//               break;
//             case 1:
//               Navigator.pushNamed(context, '/services');
//               break;
//             case 2:
//               Navigator.pushNamed(context, '/cart');
//               break;
//             case 3:
//               Navigator.pushNamed(context, '/profile');
//               break;
//           }
//         },
//         onNavTypeChanged: (_) {},
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.pushNamed(context, '/services'),
//         backgroundColor: Colors.blueAccent,
//         child: const Icon(Icons.add, color: Colors.white),
//         tooltip: 'Đặt lịch tư vấn mới',
//       ),
//     );
//   }
//
//   Widget _buildAppointmentList(AppointmentStatus status) {
//     final filteredAppointments = _getFilteredAppointments(status);
//
//     if (filteredAppointments.isEmpty) {
//       String message;
//       switch (status) {
//         case AppointmentStatus.SCHEDULED:
//           message = 'Bạn không có lịch tư vấn nào sắp tới';
//           break;
//         case AppointmentStatus.COMPLETED:
//           message = 'Bạn chưa có lịch tư vấn nào đã hoàn thành';
//           break;
//         case AppointmentStatus.CANCELLED:
//           message = 'Bạn không có lịch tư vấn nào đã hủy';
//           break;
//         default:
//           message = 'Không có lịch tư vấn nào';
//           break;
//       }
//
//       return _buildEmptyState(message);
//     }
//
//     return RefreshIndicator(
//       onRefresh: _fetchAppointments,
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         itemCount: filteredAppointments.length,
//         itemBuilder: (context, index) {
//           return _buildAppointmentCard(filteredAppointments[index]);
//         },
//       ),
//     );
//   }
// }