import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// One event streamed by the agent service:
/// status, token, envelope, done, error, session, disconnected.
class AiEvent {
  final String type;
  final Map<String, dynamic> data;

  const AiEvent(this.type, this.data);

  String get text => (data['text'] ?? '') as String;
  String get message => (data['message'] ?? '') as String;
  Map<String, dynamic> get envelope =>
      (data['envelope'] as Map?)?.cast<String, dynamic>() ?? const {};
}

/// WebSocket client for the Ameen agent service.
///
/// Base URL comes from --dart-define AMEEN_WS (Android emulator default:
/// ws://10.0.2.2:8000). The session survives reconnects via session_id.
class AiService {
  static const String _baseUrl = String.fromEnvironment(
    'AMEEN_WS',
    defaultValue: 'ws://10.0.2.2:8000',
  );

  WebSocketChannel? _channel;
  String? _sessionId;
  bool _connected = false;

  final StreamController<AiEvent> _events = StreamController.broadcast();

  Stream<AiEvent> get events => _events.stream;
  bool get isConnected => _connected;

  Uri get _uri {
    final base = _baseUrl.endsWith('/ws') ? _baseUrl : '$_baseUrl/ws';
    return Uri.parse(
      _sessionId == null ? base : '$base?session_id=$_sessionId',
    );
  }

  void connect() {
    if (_connected) return;
    final channel = WebSocketChannel.connect(_uri);
    _channel = channel;
    _connected = true;
    channel.stream.listen(
      (raw) {
        try {
          final map = (jsonDecode(raw as String) as Map).cast<String, dynamic>();
          final type = (map['type'] ?? '') as String;
          if (type == 'session') {
            _sessionId = map['session_id'] as String?;
          }
          _events.add(AiEvent(type, map));
        } catch (_) {
          // Ignore malformed frames rather than breaking the stream.
        }
      },
      onError: (Object error) {
        _connected = false;
        _events.add(AiEvent('error', {
          'code': 'connection',
          'message': 'تعذر الاتصال بالمساعد. تأكد من تشغيل الخدمة وحاول مجدداً.',
        }));
      },
      onDone: () {
        _connected = false;
        _events.add(const AiEvent('disconnected', {}));
      },
    );
  }

  void send(String text) {
    if (!_connected) connect();
    _channel?.sink.add(jsonEncode({'type': 'message', 'text': text}));
  }

  void dispose() {
    _channel?.sink.close();
    _connected = false;
    _events.close();
  }
}
