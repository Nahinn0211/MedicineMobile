import 'package:flutter/material.dart';

class DiseasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bệnh lý'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Phần hình cơ thể người
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Bộ phận cơ thể người',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Image.asset(
                  'assets/images/disease/body.jpg', // Đường dẫn đến hình ảnh cơ thể
                  width: 500,
                  height: 400   ,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Phần danh sách nhóm bệnh
          _buildDiseaseGroup('Ung thư', '131 bài viết', 'assets/images/disease/ung_thu.png'),
          _buildDiseaseGroup('Tim mạch', '91 bài viết', 'assets/images/disease/tim_mach.png'),
          _buildDiseaseGroup('Nội tiết - chuyển hóa', '83 bài viết', 'assets/images/disease/noi_tiet.png'),
          _buildDiseaseGroup('Cơ - Xương - Khớp', '182 bài viết', 'assets/images/disease/co_xuong_khop.png'),
          _buildDiseaseGroup('Da - Tóc - Móng', '100 bài viết', 'assets/images/disease/da_mong_toc.png'),
          _buildDiseaseGroup('Máu', '39 bài viết', 'assets/images/disease/mau.png'),
          _buildDiseaseGroup('Hô hấp', '84 bài viết', 'assets/images/disease/ho_hap.png'),
          _buildDiseaseGroup('Dị ứng', '24 bài viết', 'assets/images/disease/di_ung.png'),
        ],
      ),
    );
  }


  Widget _buildDiseaseGroup(String name, String articles, String imagePath) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: Image.asset(imagePath, width: 50, height: 50),
      title: Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      subtitle: Text(articles),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
      onTap: () {
        // Điều hướng đến chi tiết nhóm bệnh
      },
    );
  }
}
