import 'package:flutter/material.dart';
import 'package:medical_storage/models/brand.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/models/attribute.dart';
import 'package:medical_storage/widgets/purchase_options_sheet.dart';
import '../models/medicine_media.dart';
import '../views/patients/medicine_detail.dart';

class MedicinesCard extends StatelessWidget {
  final Medicine medicine;
  const MedicinesCard({
    required this.medicine,
    Key? key,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.'
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          5,
              (index) => Icon(
            index < rating.round() ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 14,
          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy hình ảnh chính
    final String imageUrl = medicine.medias.isNotEmpty
        ? medicine.medias.firstWhere(
          (media) => media.mainImage ?? false,
      orElse: () => medicine.medias.first,
    ).mediaUrl
        : '';

    // Lấy attribute có giá thấp nhất
    final attribute = medicine.attributes.isNotEmpty
        ? medicine.attributes.reduce((curr, next) => curr.priceOut < next.priceOut ? curr : next)
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicineDetails(
              medicine: medicine,
              attributes: medicine.attributes,
              mediaList: medicine.medias,
              brand: medicine.brand,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 200,
        height: 250, // Reduced height to prevent overflow
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade200, width: 1)
          ),
          elevation: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              // Info section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (medicine.brand != null)
                        Text(
                          'TH: ${medicine.brand!.name}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        attribute != null
                            ? "${_formatCurrency(attribute.priceOut)}đ"
                            : "Liên hệ",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildRatingStars(medicine.rating?.averageRating ?? 0),
                          const SizedBox(width: 4),
                          Text(
                            '(${medicine.rating?.totalReviews ?? 0})',
                            style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Button section
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: SizedBox(
                  width: double.infinity,
                  height: 30, // Fixed height for button
                  child: ElevatedButton(
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
                            mediaList: medicine.medias,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Chọn mua',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}