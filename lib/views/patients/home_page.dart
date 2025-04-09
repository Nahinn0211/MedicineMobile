import 'package:flutter/material.dart';
import 'package:medical_storage/widgets/HomeWidget/new_medicine.dart';
import '../../widgets/HomeWidget/best_selling_medicine_widget.dart';
import '../../widgets/HomeWidget/featured_categories_widget.dart';
import '../../widgets/HomeWidget/service_section_widget.dart';
import '../../widgets/HomeWidget/footer_widget.dart';
import '../../widgets/HomeWidget/slider_widget.dart';
import '../../widgets/HomeWidget/bottom_bar.dart';
import '../../widgets/HomeWidget/appbar_menu.dart'; // Import AppBarMenu

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  BottomNavigationBarType _bottomNavType = BottomNavigationBarType.fixed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('THAVP Medicine'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppBarMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            Image(image: AssetImage("assets/images/logo.png")),
            SizedBox(height: 40),
            NewMedicinesWidget(),
            BestSellingMedicines(),
            ServiceSectionWidget(),
            FooterWidget(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _currentIndex,
        bottomNavType: _bottomNavType,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onNavTypeChanged: (type) {
          setState(() {
            _bottomNavType = type;
          });
        },
      ),
    );
  }
}
