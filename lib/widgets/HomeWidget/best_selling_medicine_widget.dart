import 'package:flutter/material.dart';
import '../../models/medicine.dart';
import '../../models/medicine_media.dart';
import '../medicines_card.dart';

class BestSellingMedicinesWidget extends StatelessWidget {
  final List<Medicine> bestSellingMedicines;
  final List<MedicineMedia> medialist;
  BestSellingMedicinesWidget({required this.bestSellingMedicines, required this.medialist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Thuốc bán chạy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 10),
        Container(
          height: 220,
          padding: const EdgeInsets.only(left: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bestSellingMedicines.length,
            itemBuilder: (context, index) {
              final medicine = bestSellingMedicines[index];
              return MedicinesCard(medicine: medicine,);
            },
          ),
        ),
      ],
    );
  }
}
