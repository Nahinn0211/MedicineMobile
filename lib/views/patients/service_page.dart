import 'package:flutter/material.dart';
import 'package:medical_storage/services/service_service.dart';
import 'package:medical_storage/models/service.dart';

import 'appointment_page.dart';

class ServicePage extends StatelessWidget {
  final ServiceService _serviceService = ServiceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dịch vụ'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<Service>>(
        future: _serviceService.getAllServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Lỗi: ${snapshot.error}'));

          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('Không có dịch vụ nào.'));

          final services = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                      SizedBox(width: 16),

                      // Nội dung
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (service.description != null && service.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  service.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            SizedBox(height: 10),
                            // Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                // Trong ServicePage, tại phần onPressed của nút "Đặt lịch"
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AppointmentPage(serviceName: service.name),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Bạn đã chọn: ${service.name}')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child:
                                Text('Đặt lịch',
                                style: TextStyle(color: Colors.black),),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
