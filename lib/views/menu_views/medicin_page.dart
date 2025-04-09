import 'dart:core';
import 'package:flutter/material.dart';
import 'package:medical_storage/models/brand.dart';
import 'package:medical_storage/models/category.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/services/brand_service.dart';
import 'package:medical_storage/widgets/advanced_filter_dialog.dart';
import 'package:medical_storage/widgets/category_section.dart';
import 'package:medical_storage/widgets/filter_section.dart';
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
  final List<Medicine> _medicines = [];
  final List<Category> _categories = [];
  final List<Brand> _brands = [];
  final CategoryService _categoryService = CategoryService();
  final BrandService _brandService = BrandService();
  final MedicineService _medicineService = MedicineService();
  final ScrollController _scrollController = ScrollController();

  bool _showAllCategories = false;
  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedFilter = 'Tất cả';
  final List<String> _filters = [
    'Tất cả',
    'Bán chạy',
    'Sản phẩm mới',
    'Giá thấp',
    'Giá cao'
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _fetchBrands() async {
    try {
      final fetchedBrands = await _brandService.getAllBrands();

      if (!mounted) return;

      setState(() {
        _brands.clear();
        _brands.addAll(fetchedBrands);
      });
    } catch (e) {
      debugPrint('Lỗi khi tải thương hiệu: $e');
    }
  }
  // Phương thức tải dữ liệu ban đầu
  Future<void> _fetchInitialData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Tải song song danh mục và thuốc
      await Future.wait([
        _fetchCategories(),
        _fetchBrands(),
        _fetchMedicines(),
      ]);

      // Mặc định chọn "Tất cả"
      _selectedFilter = 'Tất cả';
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final fetchedCategories = await _categoryService.getAllCategories();

      if (!mounted) return;

      setState(() {
        _categories.clear();
        _categories.addAll(fetchedCategories);
      });
    } catch (e) {
      debugPrint('Lỗi khi tải danh mục: $e');
      rethrow;
    }
  }

  Future<void> _fetchEnrichedMedicineDetails(List<Medicine> medicinesToEnrich) async {
    try {
      final List<Medicine> enrichedMedicines = [];

      for (final medicine in medicinesToEnrich) {
        try {
          if (medicine.id == null) {
            enrichedMedicines.add(medicine);
            continue;
          }

          // Lấy chi tiết thuốc để lấy attributes
          Medicine? fullMedicineDetails;
          BrandBasic? brand;
          try {
            fullMedicineDetails = await _medicineService.getMedicineById(medicine.id!);

            // Nếu có brandId, gọi API lấy thông tin brand
            if (medicine.brandId != null) {
              final brandDetails = await _medicineService.getBrandById(medicine.brandId!);
              brand = BrandBasic(id: brandDetails.id, name: brandDetails.name);
            }
          } catch (detailError) {
            debugPrint('Lỗi khi tải chi tiết thuốc ${medicine.id}: $detailError');
          }

          // Tạo một bản sao của thuốc với attributes và brand mới
          final enrichedMedicine = medicine.copyWith(
              attributes: fullMedicineDetails?.attributes.isNotEmpty == true
                  ? fullMedicineDetails!.attributes
                  : medicine.attributes,
              brand: brand ?? medicine.brand
          );

          enrichedMedicines.add(enrichedMedicine);
        } catch (e) {
          debugPrint('Lỗi khi làm phong phú thuốc: $e');
          enrichedMedicines.add(medicine);
        }
      }

      // Cập nhật danh sách thuốc
      if (!mounted) return;

      setState(() {
        _medicines.clear();
        _medicines.addAll(enrichedMedicines);
      });
    } catch (e) {
      debugPrint('Lỗi chung trong _fetchEnrichedMedicineDetails: $e');
    }
  }

  // Phương thức tải danh sách thuốc
  Future<void> _fetchMedicines() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Lấy danh sách thuốc ban đầu
      final fetchedMedicines = await _medicineService.getAllMedicines();

      debugPrint('Đã lấy ${fetchedMedicines.length} thuốc từ API');

      // Cập nhật state với danh sách thuốc (ngay cả khi chưa làm phong phú)
      if (!mounted) return;

      setState(() {
        _medicines.clear();
        _medicines.addAll(fetchedMedicines);
      });

      // Làm phong phú chi tiết thuốc
      await _fetchEnrichedMedicineDetails(fetchedMedicines);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi trong _fetchMedicines: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Không thể tải danh sách thuốc: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Lấy thuốc bán chạy
  Future<void> _fetchMedicineBestSellers() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final bestSellers = await _medicineService.getMedicineBestSaling();

      // Làm phong phú danh sách thuốc bán chạy
      final enrichedBestSellers = await _medicineService.enrichMedicineList(bestSellers);

      if (!mounted) return;

      setState(() {
        _medicines.clear();
        _medicines.addAll(enrichedBestSellers);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi tải thuốc bán chạy: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Không thể tải thuốc bán chạy: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Lấy thuốc mới
  Future<void> _fetchMedicineNew() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final newMedicines = await _medicineService.getMedicineNew();

      // Làm phong phú danh sách sản phẩm mới
      final enrichedNewMedicines = await _medicineService.enrichMedicineList(newMedicines);

      if (!mounted) return;

      setState(() {
        _medicines.clear();
        _medicines.addAll(enrichedNewMedicines);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi khi tải thuốc mới: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Không thể tải thuốc mới: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Hàm sắp xếp và lọc thuốc
  void _sortMedicines(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Tất cả':
          _fetchMedicines();
          break;
        case 'Giá thấp':
          _medicines.sort((a, b) {
            if (a.attributes.isEmpty && b.attributes.isEmpty) return 0;
            if (a.attributes.isEmpty) return -1;
            if (b.attributes.isEmpty) return 1;

            final minPriceA = a.attributes.reduce((curr, next) =>
            curr.priceOut < next.priceOut ? curr : next).priceOut;
            final minPriceB = b.attributes.reduce((curr, next) =>
            curr.priceOut < next.priceOut ? curr : next).priceOut;

            return minPriceA.compareTo(minPriceB);
          });
          break;
        case 'Giá cao':
          _medicines.sort((a, b) {
            if (a.attributes.isEmpty && b.attributes.isEmpty) return 0;
            if (a.attributes.isEmpty) return 1;
            if (b.attributes.isEmpty) return -1;

            final maxPriceA = a.attributes.reduce((curr, next) =>
            curr.priceOut > next.priceOut ? curr : next).priceOut;
            final maxPriceB = b.attributes.reduce((curr, next) =>
            curr.priceOut > next.priceOut ? curr : next).priceOut;

            return maxPriceB.compareTo(maxPriceA);
          });
          break;
        case 'Bán chạy':
          _fetchMedicineBestSellers();
          break;
        case 'Sản phẩm mới':
          _fetchMedicineNew();
          break;
      }
    });
  }

  // Hàm toggle hiển thị danh mục
  void _toggleCategoryDisplay() {
    setState(() {
      _showAllCategories = !_showAllCategories;
    });
  }

  // Hiển thị dialog lọc nâng cao
  void _showAdvancedFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdvancedFilterDialog(
          categories: _categories,
          brands: _brands,
          onApplyFilter: _applyAdvancedFilter,
        );
      },
    );
  }

  // Áp dụng bộ lọc nâng cao
  Future<void> _applyAdvancedFilter({
    String? brandId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isPrescriptionRequired,
  }) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Gọi phương thức tìm kiếm nâng cao từ service
      final filteredMedicines = await _medicineService.advancedSearchMedicines(
        brandId: brandId,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        isPrescriptionRequired: isPrescriptionRequired,
      );

      // Làm phong phú danh sách thuốc
      final enrichedMedicines = await _medicineService.enrichMedicineList(filteredMedicines);

      if (!mounted) return;

      setState(() {
        _medicines.clear();
        _medicines.addAll(enrichedMedicines);
        _isLoading = false;

        // Thông báo kết quả lọc
        if (enrichedMedicines.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Không tìm thấy thuốc phù hợp với bộ lọc'),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Đặt lại',
                textColor: Colors.white,
                onPressed: () {
                  _fetchMedicines();
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tìm thấy ${enrichedMedicines.length} kết quả'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Lỗi khi lọc thuốc: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = 'Không thể lọc thuốc: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần danh mục - Sử dụng widget riêng
          CategorySection(
            categories: _categories,
            showAllCategories: _showAllCategories,
            onToggleDisplay: _toggleCategoryDisplay,
          ),

          // Phần bộ lọc - Sử dụng widget riêng
          FilterSection(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterSelected: _sortMedicines,
            onAdvancedFilterTap: _showAdvancedFilterDialog,
          ),

          // Phần danh sách thuốc
          Expanded(
            child: _buildMedicinesList(),
          ),
        ],
      ),
      // Thêm floating action button để cuộn lên đầu
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

  // Xây dựng AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Thuốc",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue.shade700,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
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
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
            // Badge có thể được hiển thị ở đây nếu có sản phẩm trong giỏ hàng
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                // Hiển thị số lượng sản phẩm trong giỏ hàng, nếu cần
                // child: Text('1', style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Xây dựng danh sách thuốc
  Widget _buildMedicinesList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue.shade600),
            const SizedBox(height: 16),
            const Text('Đang tải dữ liệu...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          ],
        ),
      );
    }

    if (_medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Không có thuốc nào',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _fetchInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchInitialData,
      color: Colors.blue.shade700,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,  // Điều chỉnh để phù hợp với card đã sửa
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: _medicines.length,
        itemBuilder: (context, index) {
          return MedicinesCard(medicine: _medicines[index]);
        },
      ),
    );
  }

  // Xây dựng floating action button
  Widget? _buildScrollToTopButton() {
    return _scrollController.hasClients && _scrollController.offset > 200
        ? FloatingActionButton(
      mini: true,
      backgroundColor: Colors.blue.shade700.withOpacity(0.8),
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: const Icon(Icons.arrow_upward, color: Colors.white),
    )
        : null;
  }
}