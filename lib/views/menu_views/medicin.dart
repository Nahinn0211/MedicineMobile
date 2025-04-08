import 'dart:core';
import 'package:flutter/material.dart';
import 'package:medical_storage/models/brand.dart';
import 'package:medical_storage/models/category.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/widgets/medicines_card.dart';
import '../../services/category_service.dart';
import '../../services/medicine_service.dart';
import '../patients/cart_page.dart';
import '../patients/search_page.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({Key? key}) : super(key: key);

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  List<Medicine> medicins = [];
  List<Category> categories = [];
  final CategoryService _categoryService = CategoryService();
  final MedicineService _medicineService = MedicineService();

  bool _showAllCategories = false;
  bool _isLoading = true;
  String _errorMessage = '';

  String selectedFilter = 'Tất cả';
  final List<String> filters = ['Tất cả', 'Bán chạy','Sản phẩm mới', 'Giá thấp', 'Giá cao'];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  // Phương thức tải dữ liệu ban đầu
  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Tải song song danh mục và thuốc
      await Future.wait([
        _fetchCategories(),
        _fetchMedicines(),
      ]);

      // Mặc định chọn "Tất cả"
      selectedFilter = 'Tất cả';
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      List<Category> fetchedCategories = await _categoryService.getAllCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      rethrow;
    }
  }
  Future<void> _fetchEnrichedMedicineDetails(List<Medicine> medicines) async {
    try {
      List<Medicine> enrichedMedicines = [];

      for (var medicine in medicines) {
        try {
          if (medicine.id == null) {
            enrichedMedicines.add(medicine);
            continue;
          }

          // Lấy chi tiết thuốc để lấy attributes
          Medicine? fullMedicineDetails;
          Brand? brand;
          try {
            fullMedicineDetails = await _medicineService.getMedicineById(medicine.id!);

            // Nếu có brandId, gọi API lấy thông tin brand
            if (medicine.brandId != null) {
              brand = await _medicineService.getBrandById(medicine.brandId!);
            }
          } catch (detailError) {
          }

          // Tạo một bản sao của thuốc với attributes và brand mới
          var enrichedMedicine = medicine.copyWith(
              attributes: fullMedicineDetails?.attributes.isNotEmpty == true
                  ? fullMedicineDetails!.attributes
                  : medicine.attributes,
              brand: brand ?? medicine.brand
          );

          enrichedMedicines.add(enrichedMedicine);
        } catch (e) {
          enrichedMedicines.add(medicine);
        }
      }

      // Cập nhật danh sách thuốc
      setState(() {
        medicins = enrichedMedicines;
      });
    } catch (e) {
    }
  }
  // Phương thức tải danh sách thuốc
  Future<void> _fetchMedicines() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Lấy danh sách thuốc ban đầu
      List<Medicine> fetchedMedicines = await _medicineService
          .getAllMedicines();

      // Làm phong phú chi tiết thuốc
      await _fetchEnrichedMedicineDetails(fetchedMedicines);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách thuốc: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Tương tự, điều chỉnh các phương thức khác như _fetchMedicineBestSellers và _fetchMedicineNew
  Future<void> _fetchMedicineBestSellers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      List<Medicine> bestSellers = await _medicineService.getMedicineBestSaling();

      // Làm phong phú danh sách thuốc bán chạy
      List<Medicine> enrichedBestSellers = await _medicineService.enrichMedicineList(bestSellers);
      setState(() {
        medicins = enrichedBestSellers;
        _isLoading = false;
      });
    } catch (e) {
      // ... (giữ nguyên phần xử lý lỗi)
    }
  }

  Future<void> _fetchMedicineNew() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      List<Medicine> newMedicines = await _medicineService.getMedicineNew();

      // Làm phong phú danh sách sản phẩm mới
      List<Medicine> enrichedNewMedicines = await _medicineService.enrichMedicineList(newMedicines);
      setState(() {
        medicins = enrichedNewMedicines;
        _isLoading = false;
      });
    } catch (e) {
      // ... (giữ nguyên phần xử lý lỗi)
    }
  }


  // Hàm sắp xếp và lọc thuốc
  void _sortMedicines(String filter) {
    setState(() {
      selectedFilter = filter;
      switch (filter) {
        case 'Tất cả':
        // Tải lại tất cả thuốc
          _fetchMedicines();
          break;
        case 'Giá thấp':
          medicins.sort((a, b) {
            if (a.attributes.isEmpty && b.attributes.isEmpty) return 0;
            if (a.attributes.isEmpty) return -1; // a không có giá thì xếp trước
            if (b.attributes.isEmpty)
              return 1; // b không có giá thì a xếp trước b

            // Tìm thuộc tính có giá thấp nhất của mỗi thuốc
            var minPriceA = a.attributes.reduce((curr, next) =>
            curr.priceOut < next.priceOut ? curr : next).priceOut;
            var minPriceB = b.attributes.reduce((curr, next) =>
            curr.priceOut < next.priceOut ? curr : next).priceOut;

            return minPriceA.compareTo(minPriceB);
          });
          break;
        case 'Giá cao':
          medicins.sort((a, b) {
            if (a.attributes.isEmpty && b.attributes.isEmpty) return 0;
            if (a.attributes.isEmpty) return 1; // a không có giá thì xếp sau
            if (b.attributes.isEmpty)
              return -1; // b không có giá thì a xếp sau b

            // Tìm thuộc tính có giá cao nhất của mỗi thuốc
            var maxPriceA = a.attributes.reduce((curr, next) =>
            curr.priceOut > next.priceOut ? curr : next).priceOut;
            var maxPriceB = b.attributes.reduce((curr, next) =>
            curr.priceOut > next.priceOut ? curr : next).priceOut;

            return maxPriceB.compareTo(maxPriceA);
          });
          break;
        case 'Bán chạy':
        // Gọi API riêng để lấy thuốc bán chạy
          _fetchMedicineBestSellers();
          break;
        case 'Sản phẩm mới':
        // Gọi API riêng để lấy sản phẩm mới
          _fetchMedicineNew();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách danh mục để hiển thị
    final displayedCategories = _showAllCategories
        ? categories
        : categories.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thuốc"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần danh mục
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: displayedCategories.length,
                  itemBuilder: (context, index) {
                    final category = displayedCategories[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            category.image != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                category.image!,
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                              ),
                            )
                                : const Icon(Icons.category, size: 30, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Nút Xem thêm
                if (categories.length > 4)
                  Center(
                    child: TextButton(
                      onPressed: _toggleCategoryDisplay,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              _showAllCategories
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.blue
                          ),
                          const SizedBox(width: 5),
                          Text(
                              _showAllCategories
                                  ? "Thu gọn"
                                  : "Xem thêm ${categories.length - 4} danh mục",
                              style: const TextStyle(color: Colors.blue)
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Phần bộ lọc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var filter in filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selectedFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            _sortMedicines(filter);
                          }
                        },
                      ),
                    ),
                  const SizedBox(width: 8), // Khoảng cách giữa chips và icon lọc
                  IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // Xử lý lọc nâng cao tại đây
                      }
                  )
                ],
              ),
            ),
          ),

          // Phần danh sách thuốc
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchInitialData,
                      child: const Text('Thử lại'),
                    )
                  ],
                ))
                : medicins.isEmpty
                ? const Center(child: Text('Không có thuốc nào'))
                : RefreshIndicator(
              onRefresh: _fetchInitialData,
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: medicins.length,
                itemBuilder: (context, index) {
                  return MedicinesCard(medicine: medicins[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm toggle hiển thị danh mục
  void _toggleCategoryDisplay() {
    setState(() {
      _showAllCategories = !_showAllCategories;
    });
  }
}