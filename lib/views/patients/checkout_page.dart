import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical_storage/views/patients/payment_method_page.dart';
import 'package:provider/provider.dart';
import '../../models/voucher.dart'; // Đổi từ discount.dart sang voucher.dart
import '../../provider/user_provider.dart';
import '../../services/cart_service.dart';
import 'add_address_page.dart';
import 'voucher_page.dart';

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
  Voucher? _selectedVoucher;
  String? _selectedVoucherCode;
  double _discountAmount = 0;

  String _selectedDeliveryMethod = "Giao hàng tận nơi";

  final TextEditingController _noteController = TextEditingController();

  double _calculateTotal() {
    return widget.cartItems.fold(0, (sum, item) => sum + (item.totalPrice));
  }

  void _showVoucherPage() async {
    final Voucher? selectedVoucher = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoucherPage()),
    );

    if (selectedVoucher != null) {
      setState(() {
        _selectedVoucher = selectedVoucher;

        double totalAmount = _calculateTotal();
        _discountAmount = totalAmount * (selectedVoucher.voucherPercentage / 100);

        _selectedVoucherCode = selectedVoucher.code;
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
          builder: (context, setModalState) {
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
                      setModalState(() {
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
                      setModalState(() {
                        _selectedDeliveryMethod = "Nhận tại nhà thuốc";
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Cập nhật UI khi chọn xong
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
    ).then((_) => setState(() {}));
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
            _buildUserInfoSection(),
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

  Widget _buildUserInfoSection() {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return Text("Không thể tải thông tin người dùng.");
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text("SĐT: ${user.phone ?? ''}", style: TextStyle(color: Colors.black87)),
                SizedBox(height: 2),
                Text("Địa chỉ: ${user.address ?? ''}", style: TextStyle(color: Colors.black87)),
                SizedBox(height: 2),
                Text("Email: ${user.email ?? ''}", style: TextStyle(color: Colors.black87)),
              ],
            ),
          ),
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
              item.medicine.medias.isNotEmpty
                  ? item.medicine.medias.first.mediaUrl
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
                Text("${_formatCurrency(item.attribute.priceOut)}đ", style: TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                Text("${_formatCurrency(item.attribute.priceOut)}đ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text("x${item.quantity}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            trailing: Text("${_formatCurrency(item.attribute.priceOut * item.quantity)}đ", style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
          ),
        )),
        SizedBox(height: 12),
        _buildVoucherSection(),
        SizedBox(height: 12),
        _buildPaymentSummary(),
      ],
    );
  }

  Widget _buildVoucherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showVoucherPage,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    _selectedVoucherCode != null
                        ? "Mã ưu đãi: $_selectedVoucherCode"
                        : "Áp dụng ưu đãi để được giảm giá",
                    style: TextStyle(fontSize: 16)
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
              ],
            ),
          ),
        ),
        if (_selectedVoucher != null)
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
                      Text(_selectedVoucher!.code, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Giảm ${_selectedVoucher!.voucherPercentage.toDouble().toStringAsFixed(0)}% - Tiết kiệm ${_formatCurrency(_discountAmount)}đ", style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedVoucher = null;
                      _selectedVoucherCode = null;
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
    double finalAmount = max(0, totalAmount - _discountAmount);

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

  Widget _buildTotalAmount() {
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
          Text("${_formatCurrency(finalAmount)}đ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final user = Provider.of<UserProvider>(context, listen: false).user;

        if (_selectedDeliveryMethod == "Giao hàng tận nơi") {
          if (user?.address == null || user!.address!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Vui lòng thêm địa chỉ giao hàng"),
              duration: Duration(seconds: 2),
            ));
            return;
          }
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
              address: {
                'name': user?.fullName ?? '',
                'phone': user?.phone ?? '',
                'address': user?.address ?? '',
                'email': user?.email ?? '',
              },
              deliveryMethod: _selectedDeliveryMethod,
              note: _noteController.text,
              voucher: _selectedVoucher,
            ),
          ),
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
