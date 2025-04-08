import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/views/patients/appointment_page.dart';

class DoctorDetailPage extends StatelessWidget {
  final DoctorProfile doctor;

  const DoctorDetailPage({required this.doctor});

  @override
  Widget build(BuildContext context) {
    print("FULLNAME: ${doctor.user.fullName}");
    print("EMAIL: ${doctor.user.email}");
    print("WORKPLACE: ${doctor.workplace}");
    print("ADDRESS: ${doctor.user.address}");

    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.user.fullName),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: doctor.user.avatar != null && doctor.user.avatar!.isNotEmpty
                    ? Image.network(
                  doctor.user.avatar!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/images/default_avatar.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Tên và chuyên ngành
            Center(
              child: Column(
                children: [
                  Text(
                    doctor.user.fullName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    doctor.specialization ?? 'Chuyên ngành chưa rõ',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            _infoRow(Icons.email, 'Email', doctor.user.email),
            _infoRow(Icons.work, 'Nơi làm việc', doctor.workplace ?? 'Không rõ nơi làm việc'),
            _infoRow(Icons.home, 'Địa chỉ', doctor.user.address ?? 'Không có địa chỉ'),
            _infoRow(Icons.school, 'Kinh nghiệm', doctor.experience ?? 'Chưa có mô tả.'),



            SizedBox(height: 20),

            // Appointment button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppointmentPage(doctor: doctor),
                    ),
                  );
                },
                icon: Icon(Icons.calendar_today, color: Colors.white),
                label: Text(
                  'Đặt lịch hẹn',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để hiển thị dòng thông tin với icon
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700], size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
