import 'package:flutter/material.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/services/doctor_service.dart';
import 'package:medical_storage/widgets/doctors_card.dart';

class DoctorPage extends StatefulWidget {
  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final DoctorService _doctorService = DoctorService();

  List<String> _specialties = [];
  List<DoctorProfile> _allDoctors = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDoctorsAndSpecialties();
  }

  Future<void> _fetchDoctorsAndSpecialties() async {
    try {
      final doctors = await _doctorService.getAllDoctors();

      final uniqueSpecialties = doctors
          .map((doc) => doc.specialization)
          .toSet()
          .toList();

      setState(() {
        _allDoctors = doctors;

        final uniqueSpecialties = doctors
            .map((doc) => doc.specialization ?? '')
            .toSet()
            .where((s) => s.isNotEmpty)
            .toList();

        _specialties = ['All', ...uniqueSpecialties];
        _tabController = TabController(length: _specialties.length, vsync: this);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black,
            tabs: _specialties.map((s) => Tab(text: s)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _specialties.map((specialty) {
                List<DoctorProfile> doctorsToShow = specialty == 'All'
                    ? _allDoctors
                    : _allDoctors.where((doc) => doc.specialization == specialty).toList();

                if (doctorsToShow.isEmpty) {
                  return Center(child: Text('Không có bác sĩ trong chuyên khoa "$specialty"'));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: doctorsToShow.length,
                  itemBuilder: (context, index) {
                    final doctor = doctorsToShow[index];
                    return DoctorsCard(doctor: doctor);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
