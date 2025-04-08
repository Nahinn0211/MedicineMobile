import 'package:flutter/material.dart';

class FeaturedCategoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> featuredCategories;

  FeaturedCategoriesWidget({required this.featuredCategories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Danh Mục Nổi Bật',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 200,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredCategories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final category = featuredCategories[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category["icon"], size: 30, color: Colors.blue),
                  SizedBox(height: 5),
                  Text(category["name"], textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
