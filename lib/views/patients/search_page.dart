import 'package:flutter/material.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/views/patients/medicine_detail.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  List<String> searchSuggestions = [
    "vitamin a",
    "vitamin a-d abipha 10x10",
    "Danh mục Giải pháp làn da",
    "Danh mục Khẩu trang y tế",
  ];

  // Danh sách dữ liệu mẫu sử dụng đối tượng Medicine
  List<Medicine> searchResults = [
  ];

  List<Medicine> filteredResults = [];

  @override
  void initState() {
    super.initState();
    filteredResults = List.from(searchResults);
  }

  // Hàm tìm kiếm
  void _onSearchChanged(String query) {
    setState(() {
      filteredResults = searchResults
          .where((medicine) =>
          medicine.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: "Tìm kiếm sản phẩm...",
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Hiển thị gợi ý tìm kiếm khi chưa nhập
          if (_searchController.text.isEmpty)
            ListView.builder(
              shrinkWrap: true,
              itemCount: searchSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.search),
                  title: Text(searchSuggestions[index]),
                  onTap: () {
                    _searchController.text = searchSuggestions[index];
                    _onSearchChanged(searchSuggestions[index]);
                  },
                );
              },
            ),

          // Hiển thị danh sách kết quả tìm kiếm với ảnh sản phẩm
          if (filteredResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: filteredResults.length + 1,
                itemBuilder: (context, index) {
                  if (index == filteredResults.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            // Xử lý khi nhấn "Xem tất cả"
                          },
                          child: Text("Xem tất cả",
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                    );
                  }

                  final medicine = filteredResults[index];
                  return ListTile(
                    leading: Image.asset(medicine.medias.first.mediaUrl,
                        width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(medicine.name),
                    subtitle: Text(medicine.description ?? ''),
                    trailing: Text(
                      "${medicine.attributes.first.priceOut.toStringAsFixed(0)}đ",
                      style: TextStyle(color: Colors.green),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineDetails(
                            medicine: medicine, attributes: [], mediaList: [],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
