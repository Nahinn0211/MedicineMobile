import 'package:flutter/material.dart';
import 'package:medical_storage/models/voucher.dart';
import '../../services/voucher_service.dart';

class VoucherPage extends StatefulWidget {
  @override
  _VoucherPageState createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  final VoucherService _voucherService = VoucherService();
  List<Voucher> vouchers = [];
  bool _isLoading = true;
  Voucher? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    try {
      final voucherList = await _voucherService.getAllVouchers();

      print("Voucher raw data:");
      for (var voucher in voucherList) {
        print(voucher.toJson()); // hoặc log json raw nếu bạn lấy thủ công
      }

      setState(() {
        vouchers = voucherList
            .where((voucher) =>
        voucher.startDate.isBefore(DateTime.now()) &&
            (voucher.endDate == null || voucher.endDate!.isAfter(DateTime.now())))
            .toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print("Voucher fetch error: $e");
      print(stackTrace);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải voucher: $e')),
      );
    }
  }

  void _applyVoucher(Voucher voucher) {
    setState(() {
      _selectedVoucher = voucher;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pop(context, voucher);
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
          : vouchers.isEmpty
          ? Center(child: Text("Không có mã giảm giá khả dụng"))
          : ListView(
        children: vouchers.map((voucher) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text("Mã: ${voucher.code}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Giảm: ${voucher.voucherPercentage.toStringAsFixed(0)}%"),
                  Text("Số lượng còn: ${voucher.stock}"),
                ],
              ),
              trailing: _selectedVoucher?.code == voucher.code
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                onPressed: () => _applyVoucher(voucher),
                child: Text("Chọn"),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
