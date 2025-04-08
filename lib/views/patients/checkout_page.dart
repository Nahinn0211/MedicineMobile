import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical_storage/views/patients/payment_method_page.dart';

import '../../models/discount.dart';
import '../../services/cart_service.dart';
import 'add_address_page.dart';
import 'discount_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;

  CheckoutPage({required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  Map<String, String>? _selectedAddress;

  Discount? _selectedDiscount;
  String? _selectedDiscountCode;
  double _discountAmount = 0;

  String _selectedDeliveryMethod = "Giao hàng tận nơi";


  final TextEditingController _noteController = TextEditingController();

  double _calculateTotal() {
    return widget.cartItems.fold(0, (sum, item) => sum + (item.totalPrice * item.quantity));
  }

  void _showDiscountPage() async {
    final Discount? selectedDiscount = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DiscountPage()),
    );

    if (selectedDiscount != null) {
      setState(() {
        _selectedDiscount = selectedDiscount;


        double totalAmount = _calculateTotal();
        _discountAmount = totalAmount * (selectedDiscount.discountPercentage / 100);

        _selectedDiscountCode = selectedDiscount.code;
      });
    }
  }

  void _showDeliveryMethodSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Chọn hình thức giao hàng",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),

                  ListTile(
                    leading: Icon(Icons.delivery_dining, color: Colors.blue),
                    title: Text("Giao hàng tận nơi"),
                    subtitle: Text("Miễn phí vận chuyển, giao nhanh trong 1 giờ"),
                    trailing: _selectedDeliveryMethod == "Giao hàng tận nơi"
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedDeliveryMethod = "Giao hàng tận nơi";
                      });
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.store, color: Colors.blue),
                    title: Text("Nhận tại nhà thuốc"),
                    subtitle: Text("Nhận hàng ngay tại cửa hàng gần bạn"),
                    trailing: _selectedDeliveryMethod == "Nhận tại nhà thuốc"
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedDeliveryMethod = "Nhận tại nhà thuốc";
                      });
                    },
                  ),
                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Cập nhật UI
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text("Chọn", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xác nhận đơn hàng'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliveryMethodSection(context),
            SizedBox(height: 12),
            _buildAddressSection(),
            SizedBox(height: 12),
            _buildNoteInput(),
            SizedBox(height: 12),
            _buildInvoiceSwitch(),
            SizedBox(height: 12),
            _buildProductList(),
            SizedBox(height: 12),
            _buildTotalAmount(),
            SizedBox(height: 16),
            _buildCheckoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryMethodSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Hình thức nhận hàng", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => _showDeliveryMethodSelection(context),
          child: Text(_selectedDeliveryMethod, style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Giao hàng tới", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final newAddress = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAddressPage(existingAddress: _selectedAddress)),
              );

              if (newAddress != null) {
                setState(() {
                  _selectedAddress = newAddress;
                });
              }
            },
            child: Text(_selectedAddress == null ? "Thêm địa chỉ" : "Thay đổi địa chỉ"),
          ),

          if (_selectedAddress != null) ...[
            SizedBox(height: 8),
            Text("Người nhận: ${_selectedAddress!['name']}"),
            Text("SĐT: ${_selectedAddress!['phone']}"),
            Text("Địa chỉ: ${_selectedAddress!['address']}"),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        hintText: "Thêm ghi chú...",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildInvoiceSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Yêu cầu xuất hóa đơn điện tử", style: TextStyle(fontSize: 16)),
        Switch(value: false, onChanged: (value) {})
      ],
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Danh sách sản phẩm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),

        ...widget.cartItems.map((item) => Card(
          child: ListTile(
            leading: Image.network(
              item.medicine.media.isNotEmpty
                  ? item.medicine.media.first.mediaUrl
                  : 'https://via.placeholder.com/50',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, size: 50, color: Colors.grey);
              },
            ),
            title: Text(item.medicine.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_formatCurrency(item.totalPrice)}đ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text("${_formatCurrency(item.attribute.priceOut)}đ", style: TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                Text("x${item.quantity} ${item.totalPrice}"),
              ],
            ),
            trailing: Text("${_formatCurrency(item.attribute.priceOut * item.quantity)}đ", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        )).toList(),

        SizedBox(height: 12),
        _buildDiscountSection(),
        SizedBox(height: 12),
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildTotalAmount() {
    // Tính toán tổng tiền và áp dụng giảm giá (nếu có)
    double totalAmount = _calculateTotal();
    double finalAmount = max(0, totalAmount - _discountAmount);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Tổng cộng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("${_formatCurrency(finalAmount)}đ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Kiểm tra địa chỉ giao hàng nếu chọn giao hàng tận nơi
        if (_selectedDeliveryMethod == "Giao hàng tận nơi" && _selectedAddress == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Vui lòng thêm địa chỉ giao hàng"),
            duration: Duration(seconds: 2),
          ));
          return;
        }

        double totalAmount = _calculateTotal();
        double finalAmount = max(0, totalAmount - _discountAmount);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentMethodPage(
                  cartItems: widget.cartItems,
                  totalAmount: finalAmount,
                  discountAmount: _discountAmount,
                  address: _selectedAddress,
                  deliveryMethod: _selectedDeliveryMethod,
                  note: _noteController.text,
                  discount: _selectedDiscount,
                )
            )
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        minimumSize: Size(double.infinity, 48),
      ),
      child: Text("Thanh toán", style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  Widget _buildDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.percent, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(child: Text("Giảm ngay 20% áp dụng đến 16/03", style: TextStyle(color: Colors.blue))),
            ],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _showDiscountPage,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hiển thị mã giảm giá nếu đã chọn, nếu không thì hiển thị text mặc định
                Text(
                    _selectedDiscountCode != null
                        ? "Mã giảm giá: $_selectedDiscountCode"
                        : "Áp dụng ưu đãi để được giảm giá",
                    style: TextStyle(fontSize: 16)
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
              ],
            ),
          ),
        ),

        // Hiển thị thông tin chi tiết về mã giảm giá nếu đã chọn
        if (_selectedDiscount != null)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _selectedDiscount!.name,
                          style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      Text(
                          "Giảm ${_selectedDiscount!.discountPercentage.toStringAsFixed(0)}% - Tiết kiệm ${_formatCurrency(_discountAmount)}đ",
                          style: TextStyle(color: Colors.green)
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDiscount = null;
                      _selectedDiscountCode = null;
                      _discountAmount = 0;
                    });
                  },
                  child: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    double totalAmount = _calculateTotal();
    double finalAmount = max(0, totalAmount - _discountAmount); // Đảm bảo không âm

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow("Tổng tiền", _formatCurrency(totalAmount)),
          _buildSummaryRow("Giảm giá", "-${_formatCurrency(_discountAmount)}", color: Colors.orange),
          _buildSummaryRow("Phí vận chuyển", "Miễn phí", color: Colors.green),
          Divider(),
          _buildSummaryRow("Thành tiền", _formatCurrency(finalAmount), fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {double fontSize = 16, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: Colors.black)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color)),
        ],
      ),
    );
  }
}