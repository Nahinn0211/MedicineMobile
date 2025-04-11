import 'package:flutter/material.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/widgets/medicines_card.dart';
import 'package:medical_storage/services/medicine_service.dart';

class NewMedicinesWidget extends StatefulWidget {
  @override
  _NewMedicinesWidgetState createState() => _NewMedicinesWidgetState();
}

class _NewMedicinesWidgetState extends State<NewMedicinesWidget> {
  List<Medicine> _newMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewMedicines();
  }

  Future<void> _fetchNewMedicines() async {
    try {
      final medicineService = MedicineService();
      final medicines = await medicineService.getMedicineNew();

      setState(() {
        _newMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách thuốc mới: $e'))
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
        : _newMedicines.isEmpty
        ? Center(
      child: Text(
        'Không có thuốc mới',
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
                'Thuốc mới',
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
            itemCount: _newMedicines.length,
            itemBuilder: (context, index) {
              final medicine = _newMedicines[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 8,
                  right: index == _newMedicines.length - 1 ? 16 : 8,
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