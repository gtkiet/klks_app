// lib/features/thong_bao/services/thong_bao_hub_service.dart
//
// Thêm vào pubspec.yaml:
//   signalr_netcore: ^1.3.6
//   flutter_local_notifications: ^17.0.0

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/storage/user_session.dart';
import '../../../core/config/app_config.dart';

/// Payload nhận từ SignalR Hub
class ThongBaoEvent {
  final String tieuDe;
  final String noiDung;
  final int? phanBoThongBaoId;

  const ThongBaoEvent({
    required this.tieuDe,
    required this.noiDung,
    this.phanBoThongBaoId,
  });
}

/// Singleton — kết nối SignalR, nhận event, show local notification
/// Vòng đời: connect() sau login, disconnect() sau logout
class ThongBaoHubService {
  ThongBaoHubService._();
  static final ThongBaoHubService instance = ThongBaoHubService._();

  HubConnection? _connection;

  // Stream broadcast để các widget lắng nghe
  final _controller = StreamController<ThongBaoEvent>.broadcast();
  Stream<ThongBaoEvent> get onThongBaoMoi => _controller.stream;

  // Badge count — UI subscribe để hiển thị số chưa đọc
  final _unreadCountController = StreamController<int>.broadcast();
  Stream<int> get onUnreadCountChanged => _unreadCountController.stream;
  int _unreadCount = 0;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  // ─── Local Notifications ──────────────────────────────────────────
  final _localNotif = FlutterLocalNotificationsPlugin();
  bool _notifInitialized = false;

  Future<void> _initLocalNotif() async {
    if (_notifInitialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _notifInitialized = true;
  }

  Future<void> _showLocalNotif(ThongBaoEvent event) async {
    const androidDetails = AndroidNotificationDetails(
      'thong_bao_channel',
      'Thông báo',
      channelDescription: 'Thông báo từ hệ thống chung cư',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    await _localNotif.show(
      id: event.phanBoThongBaoId ??
          DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
      title:  event.tieuDe,
      body:  event.noiDung,
      notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
  // ─────────────────────────────────────────────────────────────────

  /// Gọi sau khi login thành công.
  /// Token tự lấy từ UserSession — không cần truyền vào.
  Future<void> connect() async {
    if (isConnected) return;

    // Lấy token từ UserSession (đã được save sau login)
    final token = await UserSession().getAccessToken();
    if (token == null || token.isEmpty) return;

    await _initLocalNotif();

    // TODO: AppConfig.hubUrl — thêm vào app_config.dart nếu chưa có
    // Ví dụ: static const hubUrl = 'https://your-api.com/notifications';
    const hubUrl = AppConfig.hubUrl; // hoặc hardcode tạm để test

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              // Luôn lấy token mới nhất (phòng trường hợp refresh token)
              return await UserSession().getAccessToken() ?? '';
            },
          ),
        )
        .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
        .build();

    // ── Lắng nghe event từ server ──────────────────────────────────
    // TODO: Hỏi backend đặt tên method Hub là gì
    // Server C# thường: Clients.User(id).SendAsync("ReceiveNotification", payload)
    _connection!.on('ReceiveNotification', (arguments) {
      if (arguments == null || arguments.isEmpty) return;

      final data = arguments[0] as Map<String, dynamic>? ?? {};
      final event = ThongBaoEvent(
        tieuDe: data['tieuDe'] as String? ?? 'Thông báo mới',
        noiDung: data['noiDung'] as String? ?? '',
        phanBoThongBaoId: data['phanBoThongBaoId'] as int?,
      );

      // Đẩy vào stream → ThongBaoListScreen tự reload
      _controller.add(event);

      // Tăng badge count
      _unreadCount++;
      _unreadCountController.add(_unreadCount);

      // Show local notification (kể cả khi app đang foreground)
      _showLocalNotif(event);
    });

    _connection!.onreconnecting(({error}) {
      // TODO: emit trạng thái "Đang kết nối lại..." nếu muốn show banner
    });

    _connection!.onreconnected(({connectionId}) {
      // TODO: emit trạng thái "Đã kết nối" để ẩn banner
    });

    _connection!.onclose(({error}) {
      // withAutomaticReconnect sẽ tự thử lại theo retryDelays
    });

    await _connection!.start();
  }

  /// Reset badge count (gọi khi user mở màn hình thông báo)
  void resetUnreadCount() {
    _unreadCount = 0;
    _unreadCountController.add(0);
  }

  /// Gọi khi logout
  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
    _unreadCount = 0;
  }
}
