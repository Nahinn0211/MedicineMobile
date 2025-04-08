import 'package:flutter/material.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/widgets/medicines_card.dart';
import 'package:medical_storage/services/medicine_service.dart';

class NewMedicinesWidget extends StatelessWidget {
  final MedicineService _medicineService = MedicineService(); // Khởi tạo MedicineService
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Thuốc mới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        // FutureBuilder để lấy dữ liệu thuốc mới
        FutureBuilder<List<Medicine>>(
          future: _medicineService.getMedicineNew(), // Gọi phương thức từ MedicineService
          builder: (context, snapshot) {
            // Kiểm tra trạng thái của Future
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final medicines = snapshot.data!;

              // Hiển thị danh sách thuốc mới nếu có dữ liệu
              return Container(
                height: 300,
                padding: const EdgeInsets.only(left: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return MedicinesCard(medicine: medicine); // Hiển thị từng thuốc trong MedicinesCard
                  },
                ),
              );
            } else {
              return Center(child: Text('Không có dữ liệu'));
            }
          },
        ),
      ],
    );
  }
}