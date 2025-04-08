import 'package:flutter/material.dart';
import 'package:medical_storage/models/attribute.dart';
import 'package:medical_storage/models/brand.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/models/medicine_media.dart';
import 'package:medical_storage/widgets/purchase_options_sheet.dart';

class MedicineDetails extends StatelessWidget {
  final Medicine medicine;
  final List<Attribute> attributes;
  final List<MedicineMedia> mediaList;
  final Brand? brand;
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }


  const MedicineDetails({
    required this.medicine,
    required this.attributes,
    required this.mediaList,
    this.brand,



    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    print("data medicine: ${medicine.brand?.name}");
    // Lọc và lấy hình ảnh chính từ danh sách media
    final mainImageMedia = mediaList.firstWhere(
          (media) => media.mainImage,
      orElse: () => mediaList.isNotEmpty ? mediaList.first : throw Exception("Không có hình ảnh"), // Nếu không có hình ảnh chính, lấy hình đầu tiên
    );
    print('Thương hiệu ID: ${medicine.brand?.id}');
    print('Tên thương hiệu: ${medicine.brand?.name}');

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm từ mediaUrl
            if (mainImageMedia != null) // Kiểm tra nếu có hình ảnh
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(mainImageMedia.mediaUrl),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      print("Lỗi tải ảnh: $error");
                    },
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey,
                child: Center(
                  child: Text("Không có hình ảnh"),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên thuốc
                  Text(
                    medicine.name,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Giá thuốc
                  if (attributes.isNotEmpty)
                    Text(
                      '${_formatCurrency(attributes.first.priceOut)}đ',
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    )
                  else
                    Text(
                      'Không có giá',
                      style: TextStyle(fontSize: 18, color: Colors.redAccent),
                    ),
                  SizedBox(height: 16),
                  Text('Số lượng : ${attributes.first.stock}',
                      style:  TextStyle(fontSize: 18, color:  Colors.redAccent,fontWeight: FontWeight.bold)),

                  // Thông tin chi tiết
                  _buildDetailRow('Thương hiệu', medicine.brand?.name ?? 'Chưa cập nhật'),
                  _buildDetailRow('Xuất xứ', medicine.origin ?? 'Chưa cập nhật'),

                  // Ngày hết hạn
                  if (attributes.isNotEmpty && attributes.first.expiryDate != null)
                    _buildDetailRow(
                        'Ngày hết hạn',
                        '${attributes.first.expiryDate!.day}/${attributes.first.expiryDate!.month}/${attributes.first.expiryDate!.year}'
                    ),

                  // Mô tả thuốc
                  SizedBox(height: 16),
                  Text(
                    'Mô tả:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    medicine.description ?? "Không có mô tả",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 20),

                  // Nút chọn mua
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (attributes.isNotEmpty) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => PurchaseOptionsSheet(
                              medicine: medicine,
                              attribute: attributes.first,
                              mediaList: mediaList,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Không có đơn vị nào khả dụng")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Chọn mua', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
