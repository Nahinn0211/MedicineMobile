import 'package:flutter/material.dart';

class ServiceSectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _serviceCard(Icons.medical_services, "Đặt lịch Online", "Dịch vụ 24 giờ"),
              _serviceCard(Icons.access_time, "Giờ làm việc", "T2 - CN: 8:00 - 17:00"),
              _serviceCard(Icons.support_agent, "Chăm sóc khẩn cấp", "+84-969-11-6565"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
