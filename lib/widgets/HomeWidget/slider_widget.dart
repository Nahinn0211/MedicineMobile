import 'package:flutter/material.dart';

class SliderWidget extends StatelessWidget {
  final List<String> sliderImages;

  SliderWidget({required this.sliderImages});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: PageView.builder(
        itemCount: sliderImages.length,
        itemBuilder: (context, index) {
          return Image.network(
            sliderImages[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
