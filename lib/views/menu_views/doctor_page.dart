import 'package:flutter/material.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/services/doctor_service.dart';
import 'package:medical_storage/widgets/doctors_card.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({Key? key}) : super(key: key);

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final DoctorService _doctorService = DoctorService();

  List<String> _specialties = [];
  List<DoctorProfile> _allDoctors = [];
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDoctorsAndSpecialties();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctorsAndSpecialties() async {
    try {
      final doctors = await _doctorService.getAllDoctors();

      if (mounted) {
        setState(() {
          _allDoctors = doctors;

          // Extract specialties from doctors and filter empty ones
          final uniqueSpecialties = doctors
              .map((doc) => doc.specialization ?? '')
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList();

          // Sort specialties alphabetically
          uniqueSpecialties.sort();

          _specialties = ['Tất cả', ...uniqueSpecialties];
          _tabController = TabController(length: _specialties.length, vsync: this);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải dữ liệu: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<DoctorProfile> _getFilteredDoctors(String specialty) {
    // First filter by specialty
    List<DoctorProfile> doctorsToShow = specialty == 'Tất cả'
        ? _allDoctors
        : _allDoctors.where((doc) => doc.specialization == specialty).toList();

    // Then apply search filter if there's a search query
    if (_searchQuery.isNotEmpty) {
      doctorsToShow = doctorsToShow.where((doc) {
        final fullName = doc.user.fullName.toLowerCase();
        final specialization = (doc.specialization ?? '').toLowerCase();
        final workplace = (doc.workplace ?? '').toLowerCase();
        final experience = (doc.experience ?? '').toLowerCase();

        final query = _searchQuery.toLowerCase();

        return fullName.contains(query) ||
            specialization.contains(query) ||
            workplace.contains(query) ||
            experience.contains(query);
      }).toList();
    }

    return doctorsToShow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bác sĩ'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchDoctorsAndSpecialties();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blueAccent,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bác sĩ...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey[600],
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              tabs: _specialties.map((s) => Tab(text: s)).toList(),
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _specialties.map((specialty) {
                List<DoctorProfile> doctorsToShow = _getFilteredDoctors(specialty);

                if (doctorsToShow.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy bác sĩ phù hợp với "$_searchQuery"'
                              : 'Không có bác sĩ trong chuyên khoa "$specialty"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _fetchDoctorsAndSpecialties,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: doctorsToShow.length,
                    itemBuilder: (context, index) {
                      final doctor = doctorsToShow[index];
                      return DoctorsCard(doctor: doctor);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}