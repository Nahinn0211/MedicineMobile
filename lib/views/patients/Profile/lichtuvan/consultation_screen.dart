import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:medical_storage/models/appointment.dart';
import 'package:medical_storage/models/doctor_profile.dart' show DoctorProfile;
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/services/consultation_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class ConsultationScreen extends StatefulWidget {
  final Map<String, dynamic> args;


  const ConsultationScreen({Key? key, required this.args}) : super(key: key);

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  // Services
  final ConsultationService _consultationService = ConsultationService();

  // WebRTC
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // WebSocket
  StompClient? _stompClient;

  // UI state
  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isCameraOn = true;
  bool _isMicOn = true;
  bool _isSpeakerOn = true;
  String? _errorMessage;
  bool _hasVideoTrack = true;

  // Chat
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  // Consultation info
  late final String _consultationId;
  late final String _consultationCode;
  late final DoctorProfile _doctor;
  late final Appointment _appointment;
  late final String _userId;
  bool _isDoctor = false;
  PatientProfile? _patient;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _extractArguments();
    _initSession();
  }

  void _extractArguments() {
    // Trước khi gán giá trị, kiểm tra null và cung cấp giá trị mặc định
    _consultationId = widget.args['consultationId']?.toString() ?? "";
    _consultationCode = widget.args['consultationCode']?.toString() ?? "";
    _doctor = widget.args['doctor'];
    _appointment = widget.args['appointment'];
    _userId = widget.args['userId'] ?? ""; // Thêm null safety

    // Patient might be null if this is the doctor joining
    if (widget.args.containsKey('patient')) {
      _patient = widget.args['patient'];
    }

    // Check if current user is the doctor
    _isDoctor = _doctor?.user?.id == _userId;
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initSession() async {
    try {
      // Initialize WebRTC
      await _initWebRTC();

      // Connect to WebSocket
      await _connectWebSocket();

      // Load chat history
      await _loadChatHistory();

      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
    } catch (e) {
      print('Error initializing session: $e');
      setState(() {
        _isConnecting = false;
        _errorMessage = 'Không thể kết nối: $e';
      });
    }
  }

  Future<void> _initWebRTC() async {
    try {
      // Yêu cầu quyền truy cập camera và microphone trước
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      // Kiểm tra quyền truy cập
      if (statuses[Permission.camera]!.isDenied || statuses[Permission.microphone]!.isDenied) {
        throw Exception('Quyền truy cập camera và microphone bị từ chối. Vui lòng cấp quyền trong cài đặt.');
      }

      // Tạo kết nối peer
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      // Xử lý trường hợp lỗi getUserMedia bằng phương pháp fallback
      try {
        _localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'facingMode': 'user',
            'width': {'ideal': 1280},
            'height': {'ideal': 720}
          }
        });
        _hasVideoTrack = true;
      } catch (mediaError) {
        print('Không thể truy cập video: $mediaError, thử kết nối với chỉ audio');

        // Thử kết nối chỉ với audio
        _localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': false
        });

        // Cập nhật trạng thái hiển thị
        setState(() {
          _isCameraOn = false;
          _hasVideoTrack = false;
        });
      }

      // Phần còn lại của mã như cũ
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _localRenderer.srcObject = _localStream;

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        // Send ice candidate to peer via WebSocket
        if (_stompClient != null && _stompClient!.connected) {
          _stompClient!.send(
            destination: '/app/consultation/$_consultationId/webrtc',
            body: json.encode({
              'type': 'ice_candidate',
              'candidate': candidate.toMap(),
              'senderId': _userId,
            }),
          );
        }
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams[0];

          // Kiểm tra xem có track video không
          bool hasVideoTracks = event.streams[0].getVideoTracks().isNotEmpty;

          // Thông báo cho UI biết về trạng thái video từ xa
          print('Remote stream ${hasVideoTracks ? "có" : "không có"} video tracks');
        }
      };
    } catch (e) {
      print('Error initializing WebRTC: $e');
      throw Exception('Không thể khởi tạo kết nối video: $e');
    }
  }

  // Kiểm tra kết nối internet
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final String? token = await _consultationService.getToken();
      print('Token WebSocket: $token');

      // Sử dụng URL WebSocket chính xác
      String wsUrl = 'ws://192.168.1.250:8080/ws-consultation/websocket';
      // hoặc
      // String wsUrl = 'ws://192.26.1.106:8080/ws-consultation';

      print('Kết nối đến: $wsUrl');

      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: _onConnectWebSocket,
          onWebSocketError: (dynamic error) {
            print('Chi tiết lỗi WebSocket: $error');
            print('Loại lỗi: ${error.runtimeType}');

            // In ra thông tin chi tiết của lỗi
            if (error is WebSocketException) {
              print('WebSocket Exception chi tiết:');
              print('Message: ${error.message}');
            }

            _onWebSocketError(error.toString());
          },
          onStompError: (dynamic error) {
            print('Lỗi STOMP chi tiết: $error');
            _onWebSocketError("Lỗi kết nối: $error");
          },
          connectionTimeout: const Duration(seconds: 30),
          reconnectDelay: const Duration(seconds: 10),
          stompConnectHeaders: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      print('Lỗi toàn bộ quá trình kết nối WebSocket: $e');
      setState(() {
        _isConnecting = false;
        _errorMessage = 'Không thể kết nối: $e';
      });
    }
  }

  void _onConnectWebSocket(StompFrame frame) {
    try {
      // Null checks for consultation ID and STOMP client
      if (_consultationId.isEmpty) {
        print('Consultation ID is empty');
        _onWebSocketError('Consultation ID không hợp lệ');
        return;
      }

      if (_stompClient == null || !_stompClient!.connected) {
        print('STOMP client is not connected');
        _onWebSocketError('Kết nối WebSocket không thành công');
        return;
      }

      // Safely subscribe to WebRTC messages
      _stompClient!.subscribe(
        destination: '/topic/consultation/$_consultationId/webrtc',
        callback: (StompFrame frame) {
          try {
            // Additional null check for frame body
            if (frame.body == null) {
              print('Received empty WebRTC message');
              return;
            }
            final message = json.decode(frame.body!);
            _handleWebRTCMessage(message);
          } catch (e) {
            print('Error parsing WebRTC message: $e');
          }
        },
      );

      // Similar null-safe subscriptions for other channels
      _stompClient!.subscribe(
        destination: '/topic/consultation/$_consultationId/chat',
        callback: (StompFrame frame) {
          try {
            if (frame.body == null) {
              print('Received empty chat message');
              return;
            }
            final message = json.decode(frame.body!);
            _handleChatMessage(message);
          } catch (e) {
            print('Error parsing chat message: $e');
          }
        },
      );

      // Additional subscriptions with similar null safety

      // Notify others that we've joined
      _stompClient!.send(
        destination: '/app/consultation/$_consultationId/system',
        body: json.encode({
          'type': 'join',
          'userId': _userId,
          'userName': _isDoctor ? _doctor.user.fullName : _patient?.user.fullName ?? 'Bệnh nhân',
          'userRole': _isDoctor ? 'DOCTOR' : 'PATIENT',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      // If we're the one initiating the call (usually the patient), create and send offer
      if (!_isDoctor) {
        _createAndSendOffer();
      }
    } catch (e) {
      print('Lỗi trong quá trình kết nối WebSocket: $e');
      _onWebSocketError('Lỗi kết nối: $e');
    }
  }

  void _onWebSocketError(String error) {
    print('WebSocket error: $error');
    setState(() {
      _isConnecting = false;
      _errorMessage = 'Lỗi kết nối WebSocket: $error';
    });
  }

  void _handleWebRTCMessage(Map<String, dynamic> message) async {
    final String type = message['type'];
    final String senderId = message['senderId'];

    // Ignore our own messages
    if (senderId == _userId) return;

    switch (type) {
      case 'ice_candidate':
        final candidate = RTCIceCandidate(
          message['candidate']['candidate'],
          message['candidate']['sdpMid'],
          message['candidate']['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(candidate);
        break;

      case 'offer':
      // Set remote description
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(message['sdp']['sdp'], message['sdp']['type']),
        );

        // Create answer
        final RTCSessionDescription answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        // Send answer
        _stompClient!.send(
          destination: '/app/consultation/$_consultationId/webrtc',
          body: json.encode({
            'type': 'answer',
            'sdp': answer.toMap(),
            'senderId': _userId,
          }),
        );
        break;

      case 'answer':
      // Set remote description
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(message['sdp']['sdp'], message['sdp']['type']),
        );
        break;
    }
  }

  Future<void> _createAndSendOffer() async {
    try {
      // Create offer
      final RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Send offer
      _stompClient!.send(
        destination: '/app/consultation/$_consultationId/webrtc',
        body: json.encode({
          'type': 'offer',
          'sdp': offer.toMap(),
          'senderId': _userId,
        }),
      );
    } catch (e) {
      print('Error creating offer: $e');
      setState(() {
        _errorMessage = 'Không thể tạo kết nối: $e';
      });
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final messages = await _consultationService.getChatHistory(
          _consultationId,
          limit: 50  // Giới hạn mặc định là 50 tin nhắn
      );
      if (mounted) {
        setState(() {
          _messages.addAll(messages);
        });

        // Scroll to bottom of chat
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
      // Don't show error to user as this is non-critical
    }
  }

  void _handleChatMessage(Map<String, dynamic> message) {
    final chatMessage = ChatMessage.fromJson(message);
    setState(() {
      _messages.add(chatMessage);
      // Scroll to bottom of chat
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  void _handleTypingNotification(Map<String, dynamic> notification) {
    final String senderId = notification['senderId'];
    final bool isTyping = notification['isTyping'];

    // Only update typing status for the other user
    if (senderId != _userId) {
      setState(() {
        _isTyping = isTyping;
      });
    }
  }

  void _handleVideoStatusChange(Map<String, dynamic> statusChange) {
    final String senderId = statusChange['senderId'];
    final bool isEnabled = statusChange['isEnabled'];

    // Only update UI if it's the other user's status
    if (senderId != _userId) {
      // Here we would implement logic to show an indicator that remote video is off
      // For now, we'll just print to console
      print('Remote video is ${isEnabled ? 'on' : 'off'}');
    }
  }

  void _handleAudioStatusChange(Map<String, dynamic> statusChange) {
    final String senderId = statusChange['senderId'];
    final bool isEnabled = statusChange['isEnabled'];

    // Only update UI if it's the other user's status
    if (senderId != _userId) {
      // Here we would implement logic to show an indicator that remote audio is off
      // For now, we'll just print to console
      print('Remote audio is ${isEnabled ? 'on' : 'off'}');
    }
  }

  void _toggleCamera() async {
    if (_localStream == null || !_hasVideoTrack) return;

    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isEmpty) return;

    final videoTrack = videoTracks.first;
    final bool newState = !videoTrack.enabled;
    videoTrack.enabled = newState;

    // Notify others of camera status change
    _stompClient!.send(
      destination: '/app/consultation/$_consultationId/video',
      body: json.encode({
        'senderId': _userId,
        'isEnabled': newState,
      }),
    );

    setState(() {
      _isCameraOn = newState;
    });
  }

  void _toggleMicrophone() async {
    if (_localStream == null) return;

    final audioTracks = _localStream!.getAudioTracks();
    if (audioTracks.isEmpty) return;

    final audioTrack = audioTracks.first;
    final bool newState = !audioTrack.enabled;
    audioTrack.enabled = newState;

    // Notify others of microphone status change
    _stompClient!.send(
      destination: '/app/consultation/$_consultationId/audio',
      body: json.encode({
        'senderId': _userId,
        'isEnabled': newState,
      }),
    );

    setState(() {
      _isMicOn = newState;
    });
  }

  void _toggleSpeaker() {
    // In a real app, you would use a plugin to switch audio output
    // For this example, we'll just toggle the state
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'consultationId': _consultationId,
      'senderId': _userId,
      'senderName': _isDoctor ? _doctor.user.fullName : _patient?.user.fullName ?? 'Bệnh nhân',
      'senderRole': _isDoctor ? 'DOCTOR' : 'PATIENT',
      'content': _messageController.text.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    // Send via WebSocket
    _stompClient!.send(
      destination: '/app/consultation/$_consultationId/chat',
      body: json.encode(message),
    );

    // Also save to database via REST API
    _consultationService.sendChatMessage(message);

    // Clear input
    _messageController.clear();

    // Send typing = false notification
    _sendTypingNotification(false);
  }

  void _sendTypingNotification(bool isTyping) {
    if (_stompClient == null || !_stompClient!.connected) return;

    _stompClient!.send(
      destination: '/app/consultation/$_consultationId/typing',
      body: json.encode({
        'senderId': _userId,
        'isTyping': isTyping,
      }),
    );
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      _sendTypingNotification(true);
    } else {
      _sendTypingNotification(false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _endConsultation() async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết thúc tư vấn'),
        content: const Text('Bạn có chắc chắn muốn kết thúc buổi tư vấn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Có'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Notify server that consultation is ending
        await _consultationService.endConsultationSession(_consultationId);

        // Notify other participants
        if (_stompClient != null && _stompClient!.connected) {
          _stompClient!.send(
            destination: '/app/consultation/$_consultationId/system',
            body: json.encode({
              'type': 'end',
              'userId': _userId,
              'userName': _isDoctor ? _doctor.user.fullName : _patient?.user.fullName ?? 'Bệnh nhân',
              'userRole': _isDoctor ? 'DOCTOR' : 'PATIENT',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }),
          );
        }

        // Clean up and go back
        _cleanup();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể kết thúc buổi tư vấn: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  void _cleanup() {
    // Dispose of WebRTC resources
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.getTracks().forEach((track) => track.stop());
    _peerConnection?.close();

    // Disconnect WebSocket
    _stompClient?.deactivate();

    // Dispose of controllers
    _messageController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnecting) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Đang kết nối...'),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang thiết lập kết nối video...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lỗi kết nối'),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  'Không thể kết nối đến cuộc tư vấn',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (_errorMessage!.contains('camera') || _errorMessage!.contains('microphone'))
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Hướng dẫn cấp quyền truy cập:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Mở Cài đặt của thiết bị\n'
                              '2. Chọn Ứng dụng > Medical Storage > Quyền\n'
                              '3. Bật quyền Camera và Microphone\n'
                              '4. Quay lại ứng dụng và thử lại',
                          style: TextStyle(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isConnecting = true;
                          _errorMessage = null;
                        });
                        _initSession();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isDoctor
            ? 'Tư vấn với bệnh nhân ${_patient?.user.fullName ?? "Bệnh nhân"}'
            : 'Tư vấn với bác sĩ ${_doctor.user.fullName}'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: _endConsultation,
            tooltip: 'Kết thúc cuộc gọi',
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;

    return Column(
      children: [
        // Video area (tỷ lệ thay đổi dựa trên kích thước màn hình)
        Expanded(
          flex: isSmallScreen ? 3 : 2,
          child: _buildVideoArea(),
        ),

        // Chat area
        Expanded(
          flex: isSmallScreen ? 2 : 1,
          child: _buildChatArea(),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;

    return Row(
      children: [
        // Video area
        Expanded(
          flex: isWideScreen ? 3 : 2,
          child: _buildVideoArea(),
        ),

        // Chat area
        Expanded(
          flex: 1,
          child: _buildChatArea(),
        ),
      ],
    );
  }

  Widget _buildVideoArea() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Remote video (full screen)
          RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),

          // Local video (small overlay)
          Positioned(
            right: 16,
            bottom: 16,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _hasVideoTrack
                  ? RTCVideoView(
                _localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
                  : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Camera đang tắt',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Controls overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mic toggle
                _buildControlButton(
                  icon: _isMicOn ? Icons.mic : Icons.mic_off,
                  color: _isMicOn ? Colors.white : Colors.red,
                  onPressed: _toggleMicrophone,
                  tooltip: _isMicOn ? 'Tắt microphone' : 'Bật microphone',
                ),

                // Camera toggle
                _buildControlButton(
                  icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                  color: _isCameraOn ? Colors.white : Colors.red,
                  onPressed: _hasVideoTrack ? _toggleCamera : null,
                  tooltip: _hasVideoTrack
                      ? (_isCameraOn ? 'Tắt camera' : 'Bật camera')
                      : 'Camera không khả dụng',
                ),

                // Speaker toggle
                _buildControlButton(
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  color: _isSpeakerOn ? Colors.white : Colors.red,
                  onPressed: _toggleSpeaker,
                  tooltip: _isSpeakerOn ? 'Tắt loa' : 'Bật loa',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: onPressed == null ? Colors.grey.shade700 : Colors.black54,
        child: IconButton(
          icon: Icon(icon, color: onPressed == null ? Colors.grey : color, size: 28),
          onPressed: onPressed,
          tooltip: tooltip,
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.chat, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Tin nhắn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có tin nhắn nào'),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(8),
              controller: _scrollController,
              itemCount: _messages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                // Sử dụng key để tăng hiệu năng cập nhật
                final message = _messages[index];
                final bool isMe = message.senderId == _userId;
                return _buildChatMessageBubble(message, isMe, key: ValueKey('msg_${message.timestamp}'));
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              alignment: Alignment.centerLeft,
              child: Text(
                'Đang nhập...',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // Text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    textInputAction: TextInputAction.send,
                    onChanged: _onTextChanged,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Send button
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                  tooltip: 'Gửi tin nhắn',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessageBubble(ChatMessage message, bool isMe, {Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: message.senderRole == 'DOCTOR' ? Colors.blue.shade100 : Colors.green.shade100,
              child: Icon(
                message.senderRole == 'DOCTOR' ? Icons.medical_services : Icons.person,
                size: 16,
                color: message.senderRole == 'DOCTOR' ? Colors.blue.shade700 : Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}