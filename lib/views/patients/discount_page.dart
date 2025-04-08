import 'package:flutter/material.dart';
import 'package:medical_storage/models/discount.dart';
import '../../services/voucher_service.dart';

class DiscountPage extends StatefulWidget {
  @override
  _DiscountPageState createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final DiscountService _discountService = DiscountService();
  List<Discount> discounts = [];
  bool _isLoading = true;
  Discount? _selectedDiscount;

  @override
  void initState() {
    super.initState();
    _fetchDiscounts();
  }

  Future<void> _fetchDiscounts() async {
    try {
      final discountList = await _discountService.getAllDiscounts();

      setState(() {
        discounts = discountList
            .where((discount) =>
        discount.startDate.isBefore(DateTime.now()) &&
            (discount.endDate == null || discount.endDate!.isAfter(DateTime.now())))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải mã giảm giá: $e'))
      );
    }
  }

  void _applyDiscount(Discount discount) {
    setState(() {
      _selectedDiscount = discount;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pop(context, discount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chọn mã giảm giá"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : discounts.isEmpty
          ? Center(child: Text("Không có mã giảm giá"))
          : ListView(
        children: discounts.map((discount) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(discount.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mã: ${discount.code}"),
                  Text("Giảm: ${discount.discountPercentage.toStringAsFixed(0)}%"),
                  if (discount.medicine != null)
                    Text("Áp dụng cho: ${discount.medicine!.name}"),
                ],
              ),
              trailing: _selectedDiscount?.code == discount.code
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                onPressed: () => _applyDiscount(discount),
                child: Text("Chọn"),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}