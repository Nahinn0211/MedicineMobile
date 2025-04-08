import 'package:flutter/material.dart';
import 'package:medical_storage/models/brand.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/models/attribute.dart';
import 'package:medical_storage/widgets/purchase_options_sheet.dart';
import '../models/media_type.dart';
import '../models/medicine_media.dart';
import '../views/patients/medicine_detail.dart';

class MedicinesCard extends StatelessWidget {
  final Medicine medicine;
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  const MedicinesCard({
    required this.medicine,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy hình ảnh chính (mainImage) từ danh sách MedicineMedia của Medicine
    final String imageUrl = medicine.media.isNotEmpty
        ? medicine.media.firstWhere(
          (media) => media.mainImage,
      orElse: () => medicine.media.first, // Nếu không có mainImage, lấy phần tử đầu tiên
    ).mediaUrl
        : '';  // Nếu danh sách media rỗng, trả về chuỗi rỗng

    // Lấy attribute có giá thấp nhất (hoặc mặc định)
    final attribute = medicine.attributes.isNotEmpty
        ? medicine.attributes.reduce((curr, next) => curr.priceOut < next.priceOut ? curr : next)
        : null;
    final brand = medicine.brand != null
        ? [medicine.brand!]  // Nếu có brand
        : <Brand>[];  // List rỗng nếu không có

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetails(
              medicine: medicine,
              attributes: medicine.attributes,
              mediaList: medicine.media,
              brand: medicine.brand,

            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (medicine.description != null)
                      Text(
                        medicine.description!,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                        attribute != null
                            ? "${_formatCurrency(attribute.priceOut)}đ"
                            : "Liên hệ",
                        style: const TextStyle(fontSize: 14, color: Colors.blueAccent)
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (attribute != null) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => PurchaseOptionsSheet(
                        medicine: medicine,
                        attribute: attribute,
                        mediaList: medicine.media,  // Truyền danh sách mediaList từ Medicine
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Chọn mua', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}