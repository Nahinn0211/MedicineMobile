import 'package:flutter/material.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/views/patients/doctors_detail.dart';

class DoctorsCard extends StatelessWidget {
  final DoctorProfile doctor;

  const DoctorsCard({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailPage(doctor: doctor),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: doctor.user.avatar != null && doctor.user.avatar!.isNotEmpty
                  ? Image.network(
                doctor.user.avatar!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/images/default_avatar.png',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    doctor.user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialization ! ,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.workplace ?? 'Không rõ nơi làm việc',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
