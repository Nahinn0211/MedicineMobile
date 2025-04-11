import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_storage/models/consultation.dart';
import 'base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class for managing consultation-related API calls
class ConsultationService extends BaseService<Consultation> {
  ConsultationService() : super(
      endpoint: 'consultations',
      fromJson: Consultation.fromJson
  );

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get consultation by appointment ID
  Future<Consultation?> getConsultationByAppointmentId(String appointmentId) async {
    try {
      // Thêm header Authorization nếu cần
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/consultations/by-appointment/$appointmentId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Xử lý response
        final String decodedBody = utf8.decode(response.bodyBytes);

        // In ra response để debug
        print('Consultation response: $decodedBody');

        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is Map<String, dynamic>) {
          return Consultation.fromJson(parsedJson);
        } else {
          throw Exception('Expected Map but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 404) {
        // Consultation not found, which might be normal
        return null;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to get consultation: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getConsultationByAppointmentId: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error getting consultation: $e');
      }
    }
  }

  /// Get consultation by code
  Future<Consultation?> getConsultationByCode(String code) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/consultations/code/$code'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is Map<String, dynamic>) {
          return Consultation.fromJson(parsedJson);
        } else {
          throw Exception('Expected Map but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 404) {
        // Consultation not found
        return null;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to get consultation: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getConsultationByCode: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error getting consultation: $e');
      }
    }
  }

  /// Get active consultation session
  Future<Consultation?> getActiveSession(String consultationId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/consultations/$consultationId/active-session'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is Map<String, dynamic>) {
          return Consultation.fromJson(parsedJson);
        } else {
          throw Exception('Expected Map but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 404) {
        // Active session not found
        return null;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to get active session: Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getActiveSession: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error getting active session: $e');
      }
    }
  }

  /// Start consultation session
  Future<Consultation> startConsultationSession(String consultationId, String userId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/start-session'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'consultationId': consultationId,
          'initiatorId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is Map<String, dynamic>) {
          return Consultation.fromJson(parsedJson);
        } else {
          throw Exception('Expected Map but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        String responseBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to start consultation session: Server returned ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('Exception in startConsultationSession: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error starting consultation session: $e');
      }
    }
  }

  /// End consultation session
  Future<Consultation> endConsultationSession(String consultationId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/end-session'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'consultationId': consultationId,
        }),
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is Map<String, dynamic>) {
          return Consultation.fromJson(parsedJson);
        } else {
          throw Exception('Expected Map but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        String responseBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to end consultation session: Server returned ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('Exception in endConsultationSession: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error ending consultation session: $e');
      }
    }
  }

  /// Send chat message
  Future<ChatMessage> sendChatMessage(Map<String, dynamic> message) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/chat'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'consultationId': message['consultationId'],
          'senderId': message['senderId'],
          'content': message['content'],
        }),
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is Map<String, dynamic>) {
          return ChatMessage.fromJson(parsedJson);
        } else {
          throw Exception('Expected Map but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        String responseBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to send chat message: Server returned ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('Exception in sendChatMessage: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error sending chat message: $e');
      }
    }
  }

  /// Get chat history
  Future<List<ChatMessage>> getChatHistory(String consultationId, {int limit = 50}) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/chat-history'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'consultationId': consultationId,
          'limit': limit,  // Thêm limit vào body
        }),
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);

        // In ra response để debug
        print('Chat history response: $decodedBody');

        final dynamic parsedJson = json.decode(decodedBody);

        if (parsedJson is List) {
          final messages = <ChatMessage>[];

          for (var i = 0; i < parsedJson.length; i++) {
            try {
              final item = parsedJson[i];
              if (item is Map<String, dynamic>) {
                final message = ChatMessage.fromJson(item);
                messages.add(message);
              }
            } catch (e) {
              print('Error parsing message at index $i: $e');
              // Tiếp tục với item tiếp theo thay vì dừng toàn bộ quá trình
            }
          }

          return messages;
        } else {
          throw Exception('Expected List but got ${parsedJson.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        String responseBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to get chat history: Server returned ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('Exception in getChatHistory: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format: $e');
      } else if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else {
        throw Exception('Error getting chat history: $e');
      }
    }
  }

  /// Mark messages as read
  Future<bool> markMessagesAsRead(String consultationId, String userId) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/$consultationId/mark-read'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
        }),
      );

      // Log response code for debugging
      print('Mark as read response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        String responseBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to mark messages as read: Server returned ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('Exception in markMessagesAsRead: $e');
      if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else if (e is Exception) {
        rethrow; // Rethrow already formatted exceptions
      } else {
        throw Exception('Error marking messages as read: $e');
      }
    }
  }

  /// Toggle video stream
  Future<bool> toggleVideoStream(String consultationId, String userId, bool isEnabled) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/consultations/$consultationId/toggle-video'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'isEnabled': isEnabled,
        }),
      );

      // Log response code for debugging
      print('Toggle video response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else {
        String responseBody = utf8.decode(response.bodyBytes);
        throw Exception('Failed to toggle video stream: Server returned ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('Exception in toggleVideoStream: $e');
      if (e is http.ClientException) {
        throw Exception('Network error: $e');
      } else if (e is Exception) {
        rethrow; // Rethrow already formatted exceptions
      } else {
        throw Exception('Error toggling video stream: $e');
      }
    }
  }
}

/// Class representing a chat message
class ChatMessage {
  final String consultationId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final int timestamp;
  final bool isRead;

  ChatMessage({
    required this.consultationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      consultationId: json['consultationId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderRole: json['senderRole'],
      content: json['content'],
      timestamp: json['timestamp'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consultationId': consultationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}