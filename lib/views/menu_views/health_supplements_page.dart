import 'package:flutter/material.dart';
import 'package:medical_storage/models/medicine.dart';
import 'package:medical_storage/views/patients/cart_page.dart';
import 'package:medical_storage/widgets/medicines_card.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';
import '../patients/search_page.dart';

class HealthSupplementPage extends StatefulWidget {
  @override
  _HealthSupplementPageState createState() => _HealthSupplementPageState();
}

class _HealthSupplementPageState extends State<HealthSupplementPage> {
  final List<Medicine> healthSupplements = [];

  String selectedFilter = 'Bán chạy';
  final List<String> filters = ['Bán chạy', 'Giá thấp', 'Giá cao'];

  List<Category> categories = [];
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      List<Category> fetchedCategories = await _categoryService.getAllCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print('Failed to fetch categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thực phẩm chức năng"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()));
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GridView danh mục
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return categoryCard(category);
              },
            ),
          ),

          // Bộ lọc sản phẩm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                for (var filter in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter;
                          if (filter == 'Giá thấp') {
                            healthSupplements.sort((a, b) => a.attributes.first.priceOut.compareTo(b.attributes.first.priceOut));
                          } else if (filter == 'Giá cao') {
                            healthSupplements.sort((a, b) => b.attributes.first.priceOut.compareTo(a.attributes.first.priceOut));
                          }
                        });
                      },
                    ),
                  ),
                Spacer(),
                IconButton(icon: Icon(Icons.filter_list), onPressed: () {})
              ],
            ),
          ),

          // Danh sách sản phẩm
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: healthSupplements.length,
              itemBuilder: (context, index) {
                return MedicinesCard(medicine: healthSupplements[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryCard(Category category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
              ),
            )
                : Icon(Icons.category, size: 30, color: Colors.grey),
            SizedBox(width: 10),

            // Text không xuống dòng
            Flexible(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
