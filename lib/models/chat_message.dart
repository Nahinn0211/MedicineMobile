class ChatMessage {
  final String? id;
  final String? consultationId;
  final String? senderId;
  final String senderType;
  final String content;
  final DateTime sentAt;
  final DateTime? readAt;
  final String messageType;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessage({
    this.id,
    this.consultationId,
    this.senderId,
    required this.senderType,
    required this.content,
    required this.sentAt,
    this.readAt,
    required this.messageType,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a ChatMessage object from JSON data
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    try {
      return ChatMessage(
        id: json['id']?.toString(),
        consultationId: json['consultationId']?.toString(),
        senderId: json['senderId']?.toString(),
        senderType: json['senderType'] ?? "SYSTEM",
        content: json['content'] ?? "",
        sentAt: DateTime.parse(json['sentAt']),
        readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
        messageType: json['messageType'] ?? "TEXT",
        isEdited: json['isEdited'] ?? false,
        editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
        createdAt: DateTime.parse(json['createdAt'] ?? json['sentAt']),
        updatedAt: DateTime.parse(json['updatedAt'] ?? json['sentAt']),
      );
    } catch (e) {
      print('Error in ChatMessage.fromJson: $e');
      print('Problematic JSON: $json');

      // Return a default object
      return ChatMessage(
        senderType: "SYSTEM",
        content: "Lỗi khi tải tin nhắn",
        sentAt: DateTime.now(),
        messageType: "SYSTEM",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Convert ChatMessage object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consultationId': consultationId,
      'senderId': senderId,
      'senderType': senderType,
      'content': content,
      'sentAt': sentAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'messageType': messageType,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Check if the message is read
  bool get isRead {
    return readAt != null;
  }

  /// Check if this is a system message
  bool get isSystemMessage {
    return messageType == "SYSTEM";
  }
}