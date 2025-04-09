import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../models/medicine_media.dart';
import '../../services/medicine_service.dart';
import '../medicines_card.dart';

class BestSellingMedicines extends StatefulWidget {
  @override
  _BestSellingMedicinesState createState() => _BestSellingMedicinesState();
}

class _BestSellingMedicinesState extends State<BestSellingMedicines> {
  List<Medicine> _bestSellingMedicines = [];
  List<MedicineMedia> _mediaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBestSellingMedicines();
  }

  Future<void> _fetchBestSellingMedicines() async {
    try {
      final medicineService = MedicineService();
      final medicines = await medicineService.getMedicineBestSaling();
      final mediaList = await Future.wait(
          medicines.map((medicine) async {
            if (medicine.id != null) {
              return await medicineService.getAllMediaByMedicineId(medicine.id!);
            }
            return <MedicineMedia>[];
          })
      );
      final flattenedMediaList = mediaList.expand((element) => element).toList();

      setState(() {
        _bestSellingMedicines = medicines;
        _mediaList = flattenedMediaList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách thuốc bán chạy: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
      child: CircularProgressIndicator(
        color: Colors.blue[700],
      ),
    )
        : _bestSellingMedicines.isEmpty
        ? Center(
      child: Text(
        'Không có thuốc bán chạy',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
        ),
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thuốc bán chạy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Xử lý khi nhấn xem thêm
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _bestSellingMedicines.length,
            itemBuilder: (context, index) {
              final medicine = _bestSellingMedicines[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 8,
                  right: index == _bestSellingMedicines.length - 1 ? 16 : 8,
                ),
                child: MedicinesCard(medicine: medicine),
              );
            },
          ),
        ),
      ],
    );
  }
}