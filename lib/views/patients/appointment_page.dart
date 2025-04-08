import 'package:flutter/material.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import '../../services/doctor_service.dart';
import 'success_page.dart';
class AppointmentPage extends StatefulWidget {
  final DoctorProfile? doctor;
  final String? serviceName;

  const AppointmentPage({this.doctor, this.serviceName, Key? key}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}


class _AppointmentPageState extends State<AppointmentPage> {
  final DoctorService _doctorService = DoctorService();

  List<DoctorProfile> doctors = [];
  List<String> specializations = [];
  Map<String, List<String>> doctorsByDepartment = {};

  String? selectedDepartment;
  String? selectedDoctor;
  String? selectedDate;
  String? selectedTimeSlot;
  String? selectedService;

  final List<String> timeSlots = ['08:00 - 10:00', '10:00 - 12:00', '14:00 - 16:00', '16:00 - 18:00'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.serviceName != null) {
      selectedService = widget.serviceName;
    }

    if (widget.doctor != null) {
      selectedDepartment = widget.doctor!.specialization;
      selectedDoctor = widget.doctor!.user.fullName;
    }

    _loadDoctors().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadDoctors() async {
    try {
      final allDoctors = await _doctorService.getAllDoctors();

      setState(() {
        doctors = allDoctors;

        // Sửa lỗi cho specializations - loại bỏ giá trị null trước khi thêm vào danh sách
        specializations = doctors
            .map((doctor) => doctor.specialization)
            .where((spec) => spec != null) // Loại bỏ các giá trị null
            .cast<String>() // Chuyển đổi từ String? sang String
            .toSet()
            .toList();

        // Sửa lỗi cho doctorsByDepartment - xử lý các giá trị có thể null
        // Trong phương thức _loadDoctors()
        doctorsByDepartment = {};
        for (var doctor in doctors) {
          if (doctor.specialization != null) {
            String spec = doctor.specialization!;

            if (!doctorsByDepartment.containsKey(spec)) {
              doctorsByDepartment[spec] = [];
            }

            // Thay đổi cách hiển thị tên bác sĩ
            String doctorDisplayName = doctor.user.fullName ?? "Bác sĩ không xác định";
            // Có thể thêm thông tin bổ sung nếu muốn
            // Ví dụ: doctorDisplayName += " - ${doctor.experience ?? ''}";

            doctorsByDepartment[spec]!.add(doctorDisplayName);
          }
        }
      });
    } catch (e) {
      print('Lỗi khi tải danh sách bác sĩ: $e');

      setState(() {
        specializations = [
          'Khoa Nhi', 'Tim Mạch', 'Ngoại Khoa', 'Nhi Khoa', 'Da Liễu'
        ];

        doctorsByDepartment = {
          'Khoa Nhi': ['Nguyễn Tiến Phúc, 8 năm kinh nghiệm'],
          'Tim Mạch': ['Lê Nam Anh, 15 năm kinh nghiệm'],
          'Ngoại Khoa': ['Khổng Khánh Vân, 12 năm kinh nghiệm'],
          'Nhi Khoa': ['Lương Minh Hiếu, 8 năm kinh nghiệm'],
          'Da Liễu': ['Trần Đức Thịnh, 7 năm kinh nghiệm'],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget serviceConfirmation = widget.serviceName != null
        ? Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blueAccent),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dịch vụ đã chọn: ${widget.serviceName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    )
        : SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dịch vụ tư vấn'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đặt Lịch Hẹn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Đặt lịch hẹn với các bác sĩ chuyên gia của chúng tôi.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            serviceConfirmation,
            _buildDropdownField(
              'Chọn Gói',
              ['Cơ bản', 'Tiêu chuẩn', 'Nâng cao'],
                  (value) {
              },
              selectedValue: selectedService,
            ),
            _buildDropdownField(
              'Chọn Chuyên Ngành',
              specializations.isEmpty
                  ? ['Đang tải...']
                  : specializations,
                  (value) {
                setState(() {
                  selectedDepartment = value;
                  selectedDoctor = null;  // Reset bác sĩ khi thay đổi chuyên ngành
                });
              },
              selectedValue: selectedDepartment,
            ),
            if (selectedDepartment != null)
              _buildDropdownField(
                'Chọn Bác Sĩ',
                doctorsByDepartment[selectedDepartment!] ?? [],
                    (value) {
                  setState(() {
                    selectedDoctor = value;
                  });
                },
                selectedValue: selectedDoctor,
              ),

            _buildDateField(context),
            if (selectedDate != null) _buildDropdownField('Chọn Thời Gian', timeSlots, (value) {
              setState(() {
                selectedTimeSlot = value;
              });
            }),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuccessPage()), // Chuyển sang trang thành công
                  );
                },
                child: Text('Nhận Tư Vấn', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, ValueChanged<String?> onChanged, {String? selectedValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        value: options.contains(selectedValue) ? selectedValue : null, // Đảm bảo giá trị hợp lệ
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Chọn Ngày',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        controller: TextEditingController(text: selectedDate ?? ''),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              selectedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
      ),
    );
  }
}
