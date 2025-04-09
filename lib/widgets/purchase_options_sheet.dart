import 'package:flutter/material.dart';
import 'package:medical_storage/views/patients/checkout_page.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart'; // Import CartService
import '../../models/medicine.dart';
import '../../models/attribute.dart';
import '../../models/medicine_media.dart';
import '../models/media_type.dart';

class PurchaseOptionsSheet extends StatefulWidget {
  final Medicine medicine;
  final Attribute attribute;
  final List<MedicineMedia> mediaList;

  const PurchaseOptionsSheet({
    required this.medicine,
    required this.attribute,
    required this.mediaList,
    Key? key,
  }) : super(key: key);

  @override
  _PurchaseOptionsSheetState createState() => _PurchaseOptionsSheetState();
}

class _PurchaseOptionsSheetState extends State<PurchaseOptionsSheet> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    double medicinePrice = widget.attribute.priceOut;

    // Lấy hình ảnh chính của sản phẩm
    final String imageUrl = widget.mediaList
        .firstWhere((media) => media.mainImage ?? false, orElse: () => widget.mediaList.firstOrNull ?? MedicineMedia(
      medicine: widget.medicine,
      mediaType: MediaType.image,
      mediaUrl: '',
      mainImage: false,
    ))
        .mediaUrl ??
        '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & nút đóng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chọn số lượng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),

          // Hiển thị sản phẩm
          Row(
            children: [
              Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50, color: Colors.grey);
                },
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.medicine.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${medicinePrice.toStringAsFixed(2)}đ", style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Chọn số lượng
          Text("Số lượng", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                },
              ),
              Text("$quantity", style: TextStyle(fontSize: 18)),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() => quantity++);
                },
              ),
            ],
          ),

          Divider(),
          SizedBox(height: 8),

          // Tổng tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tạm tính", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("${(medicinePrice * quantity).toStringAsFixed(2)}đ", style: TextStyle(fontSize: 16, color: Colors.blue)),
            ],
          ),

          SizedBox(height: 16),
          Row(
            children: [
              // Nút thêm vào giỏ hàng
              // Nút thêm vào giỏ hàng
              OutlinedButton(
                onPressed: () {
                  final cartService = Provider.of<CartService>(context, listen: false);
                  cartService.addToCart(widget.medicine, widget.attribute, quantity: quantity);

                  // Hiển thị thông báo & đóng bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                  );
                  Navigator.pop(context);
                },
                child: Text("Thêm vào giỏ"),
              ),

              SizedBox(width: 8),

              // Nút mua ngay
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          cartItems: [
                            CartItem(
                              medicine: widget.medicine,
                              attribute: widget.attribute,
                              quantity: quantity,
                              userId: '',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("Mua ngay", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
