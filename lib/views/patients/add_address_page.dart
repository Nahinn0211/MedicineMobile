import 'package:flutter/material.dart';

class AddAddressPage extends StatefulWidget {
  final Map<String, String>? existingAddress;
  AddAddressPage({this.existingAddress});

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingAddress != null) {
      _nameController.text = widget.existingAddress!['name'] ?? '';
      _phoneController.text = widget.existingAddress!['phone'] ?? '';
      _addressController.text = widget.existingAddress!['address'] ?? '';
    }
  }

  void _saveAddress() {
    Navigator.pop(context, {
      'Tên': _nameController.text,
      'Số điện thoại': _phoneController.text,
      'Địa chỉ': _addressController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm địa chỉ"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Họ và tên"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: "Địa chỉ cụ thể"),
              maxLines: 2,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text("Lưu địa chỉ", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
