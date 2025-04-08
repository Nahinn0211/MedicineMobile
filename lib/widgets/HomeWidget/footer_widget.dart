import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _footerItem(Icons.verified, "Thuốc chính hãng", "Đa dạng và chuyên sâu"),
              _footerItem(Icons.autorenew, "Đổi trả trong 30 ngày", "Kể từ ngày mua"),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _footerItem(Icons.thumb_up, "Cam kết 100%", "Chất lượng sản phẩm"),
              _footerItem(Icons.local_shipping, "Miễn phí vận chuyển", "Theo chính sách giao hàng"),
            ],
          ),
          SizedBox(height: 20),
          Divider(),
          Text(
            "© 2024 Công ty Cổ Phần Dược Phẩm THAVP\nĐịa chỉ: 123 Đường ABC, Quận X, Hà Nội ",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            "Điện thoại: (028) 1234 5678 - Email: contact@thavp.com",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Image.asset('assets/images/logo.png', height: 40),
          ),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
      ],
    );
  }
}
