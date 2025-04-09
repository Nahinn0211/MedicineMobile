import 'package:flutter/material.dart';
import 'package:medical_storage/models/category.dart';

import '../models/brand.dart';

class AdvancedFilterDialog extends StatefulWidget {
  final List<Category> categories;
  final List<Brand> brands;
  final Function({
  String? brandId,
  String? categoryId,
  double? minPrice,
  double? maxPrice,
  bool? isPrescriptionRequired,
  }) onApplyFilter;

  const AdvancedFilterDialog({
    Key? key,
    required this.categories,
    required this.brands,
    required this.onApplyFilter,
  }) : super(key: key);

  @override
  State<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends State<AdvancedFilterDialog> {
  String? selectedBrand;
  String? selectedCategory;
  RangeValues priceRange = const RangeValues(0, 1000000);
  bool? isPrescriptionRequired;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.filter_alt, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          const Text('Bộ lọc nâng cao'),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lọc theo thương hiệu
            _buildFilterSectionHeader('Thương hiệu'),
            _buildDropdown(
              hint: 'Chọn thương hiệu',
              value: selectedBrand,
              items: widget.brands.map((brand) {
                return DropdownMenuItem<String>(
                  value: brand.id,
                  child: Text(brand.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBrand = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Lọc theo danh mục
            _buildFilterSectionHeader('Danh mục'),
            _buildDropdown(
              hint: 'Chọn danh mục',
              value: selectedCategory,
              items: widget.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // Lọc theo khoảng giá
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterSectionHeader('Khoảng giá', margin: EdgeInsets.zero),
                Text(
                  '${_formatCurrency(priceRange.start.round())} - ${_formatCurrency(priceRange.end.round())}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            RangeSlider(
              values: priceRange,
              min: 0,
              max: 1000000,
              divisions: 100,
              activeColor: Colors.blue.shade600,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                '${priceRange.start.round()}',
                '${priceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  priceRange = values;
                });
              },
            ),

            const SizedBox(height: 20),

            // Lọc theo yêu cầu đơn thuốc
            _buildFilterSectionHeader('Yêu cầu đơn thuốc'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Không', style: TextStyle(fontSize: 14)),
                      value: false,
                      groupValue: isPrescriptionRequired,
                      activeColor: Colors.blue.shade700,
                      onChanged: (bool? value) {
                        setState(() {
                          isPrescriptionRequired = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Có', style: TextStyle(fontSize: 14)),
                      value: true,
                      groupValue: isPrescriptionRequired,
                      activeColor: Colors.blue.shade700,
                      onChanged: (bool? value) {
                        setState(() {
                          isPrescriptionRequired = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
          ),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApplyFilter(
              brandId: selectedBrand,
              categoryId: selectedCategory,
              minPrice: priceRange.start,
              maxPrice: priceRange.end,
              isPrescriptionRequired: isPrescriptionRequired,
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }

  Widget _buildFilterSectionHeader(String title, {EdgeInsets margin = const EdgeInsets.only(bottom: 8)}) {
    return Padding(
      padding: margin,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint),
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Hàm định dạng tiền tệ
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.'
    ) + ' đ';
  }
}