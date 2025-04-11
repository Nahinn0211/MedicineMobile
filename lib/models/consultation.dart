import 'package:medical_storage/models/appointment.dart';
import 'package:medical_storage/models/chat_message.dart';
import 'package:medical_storage/models/doctor_profile.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/models/consultation_status.dart';

/// Represents a consultation session between a doctor and a patient
class Consultation {
  final String? id;
  final String? patientId;
  final String? patientName;
  final String? doctorId;
  final String? doctorName;
  final String? appointmentId;
  final String consultationCode;
  final String? consultationLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final ConsultationStatus status;
  final bool? isVideoEnabled;
  final String? sessionToken;
  final String? rtcSessionId;
  final List<dynamic>? recentMessages;
  final List<ChatMessage> chatMessages;
  final List<ConsultationSession> sessions;

  Consultation({
    this.id,
    this.patientId,
    this.patientName,
    this.doctorId,
    this.doctorName,
    this.appointmentId,
    required this.consultationCode,
    this.consultationLink,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.endedAt,
    required this.status,
    this.isVideoEnabled,
    this.sessionToken,
    this.rtcSessionId,
    this.recentMessages,
    this.chatMessages = const [],
    this.sessions = const [],
  });

  /// Create a Consultation object from JSON data
  factory Consultation.fromJson(Map<String, dynamic> json) {
    try {

      // Parse chat messages if available
      final List<ChatMessage> messages = [];
      if (json['chatMessages'] != null && json['chatMessages'] is List) {
        for (final msgJson in json['chatMessages']) {
          try {
            messages.add(ChatMessage.fromJson(msgJson));
          } catch (e) {
            print('Lỗi khi parse chat message: $e');
          }
        }
      }

      return Consultation(
        id: json['id']?.toString(),
        patientId: json['patientId']?.toString(),
        patientName: json['patientName'],
        doctorId: json['doctorId']?.toString(),
        doctorName: json['doctorName'],
        appointmentId: json['appointmentId']?.toString(),
        consultationCode: json['consultationCode'] ?? "",
        consultationLink: json['consultationLink'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'])
            : null,
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'])
            : null,
        status: ConsultationStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => ConsultationStatus.PENDING,
        ),
        isVideoEnabled: json['isVideoEnabled'],
        sessionToken: json['sessionToken'],
        rtcSessionId: json['rtcSessionId'],
        recentMessages: json['recentMessages'],
        chatMessages: messages,
        sessions: json['sessions'] != null && json['sessions'] is List
            ? (json['sessions'] as List)
            .map((e) => ConsultationSession.fromJson(e))
            .toList()
            : [],
      );
    } catch (e, stackTrace) {
      print('ERROR tại Consultation.fromJson: $e');
      print('JSON gây lỗi: $json');
      print('Stack trace: $stackTrace');

      // Tạo đối tượng mặc định thay vì ném lỗi
      return Consultation(
        id: json['id']?.toString(),
        consultationCode: json['consultationCode'] ?? "",
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
        status: ConsultationStatus.PENDING,
        chatMessages: [],
        sessions: [],
      );
    }
  }

  /// Convert Consultation object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'consultationCode': consultationCode,
      'consultationLink': consultationLink,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'isVideoEnabled': isVideoEnabled,
      'sessionToken': sessionToken,
      'rtcSessionId': rtcSessionId,
      'recentMessages': recentMessages,
      'chatMessages': chatMessages.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }

  /// Get the most recent active session if any
  ConsultationSession? get activeSession {
    return sessions
        .where((session) => session.status == ConsultationSessionStatus.ACTIVE)
        .lastOrNull;
  }

  /// Check if the consultation is currently active
  bool get isActive {
    return status == ConsultationStatus.IN_PROGRESS && activeSession != null;
  }

  /// Get the duration of the consultation if it has ended
  Duration? get duration {
    if (startedAt != null && endedAt != null) {
      return endedAt!.difference(startedAt!);
    }
    return null;
  }

  /// Format the duration as a string (e.g., "1h 30m")
  String? get formattedDuration {
    final duration = this.duration;
    if (duration == null) return null;

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get the latest chat message if available
  ChatMessage? get latestMessage {
    if (chatMessages.isEmpty) return null;
    return chatMessages.last;
  }

  /// Get unread message count for a specific user
  int getUnreadMessageCount(String userId) {
    return chatMessages.where((msg) =>
    msg.senderId != userId && !msg.isRead).length;
  }
}

/// Represents a session within a consultation
class ConsultationSession {
  final String? id;
  final String consultationId;
  final String initiatorId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final ConsultationSessionStatus status;

  ConsultationSession({
    this.id,
    required this.consultationId,
    required this.initiatorId,
    required this.startedAt,
    this.endedAt,
    required this.status,
  });

  /// Create a ConsultationSession object from JSON data
  factory ConsultationSession.fromJson(Map<String, dynamic> json) {
    try {
      return ConsultationSession(
        id: json['id']?.toString(),
        consultationId: json['consultationId'] != null ? json['consultationId'].toString() : "",
        initiatorId: json['initiatorId'] != null ? json['initiatorId'].toString() : "",
        startedAt: DateTime.parse(json['startedAt']),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'])
            : null,
        status: ConsultationSessionStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => ConsultationSessionStatus.PENDING,
        ),
      );
    } catch (e) {
      print('Error in ConsultationSession.fromJson: $e');
      print('Problematic JSON: $json');

      // Return a default object instead of failing
      return ConsultationSession(
        consultationId: json['consultationId']?.toString() ?? "",
        initiatorId: json['initiatorId']?.toString() ?? "",
        startedAt: DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
        status: ConsultationSessionStatus.PENDING,
      );
    }
  }

  /// Convert ConsultationSession object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consultationId': consultationId,
      'initiatorId': initiatorId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  /// Get the duration of the session if it has ended
  Duration? get duration {
    if (endedAt != null) {
      return endedAt!.difference(startedAt);
    }
    return null;
  }
}

/// Status of a consultation session
enum ConsultationSessionStatus {
  PENDING,    // Session created but not started
  ACTIVE,     // Session is currently active
  COMPLETED,  // Session ended normally
  ABORTED     // Session ended unexpectedly
}