// lib/features/thong_bao/services/thong_bao_hub_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../core/storage/user_session.dart';
import '../../../core/config/app_config.dart';

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

class ThongBaoHubService {
  ThongBaoHubService._();
  static final ThongBaoHubService instance = ThongBaoHubService._();

  HubConnection? _connection;

  final _controller = StreamController<ThongBaoEvent>.broadcast();
  Stream<ThongBaoEvent> get onThongBaoMoi => _controller.stream;

  final _unreadCountController = StreamController<int>.broadcast();
  Stream<int> get onUnreadCountChanged => _unreadCountController.stream;
  int _unreadCount = 0;

  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  // ─── Local Notifications ──────────────────────────────────────────
  final _localNotif = FlutterLocalNotificationsPlugin();
  bool _notifInitialized = false;

  Future<void> _initLocalNotif() async {
    if (_notifInitialized) return;

    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      debugPrint('>>> [ThongBao] Notification permission: $result');
      if (!result.isGranted) {
        debugPrint(
          '>>> [ThongBao] Permission bị từ chối — sẽ không show notification',
        );
      }
    }

    await _localNotif.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );

    const channel = AndroidNotificationChannel(
      'thong_bao_channel',
      'Thông báo',
      description: 'Thông báo từ hệ thống chung cư',
      importance: Importance.high,
      playSound: true,
    );
    final androidImpl = _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);

    _notifInitialized = true;
    debugPrint('>>> [ThongBao] Local notification initialized');
  }

  Future<void> _showLocalNotif(ThongBaoEvent event) async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      debugPrint('>>> [ThongBao] Skip notification — permission not granted');
      return;
    }

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

    final notifId =
        event.phanBoThongBaoId ??
        DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

    await _localNotif.show(
      id: notifId,
      title: event.tieuDe,
      body: event.noiDung,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
    debugPrint('>>> [ThongBao] Showed notification id=$notifId');
  }
  // ─────────────────────────────────────────────────────────────────

  Future<void> connect() async {
    debugPrint('>>> [ThongBao] connect() called, isConnected=$isConnected');

    if (isConnected) {
      debugPrint('>>> [ThongBao] Already connected, skip');
      return;
    }

    final token = await UserSession().getAccessToken();
    debugPrint(
      '>>> [ThongBao] token=${token == null
          ? "NULL"
          : token.isEmpty
          ? "EMPTY"
          : "OK (${token.length} chars)"}',
    );

    if (token == null || token.isEmpty) {
      debugPrint('>>> [ThongBao] No token — abort connect');
      return;
    }

    await _initLocalNotif();

    // Bật SignalR internal logger để thấy negotiate/transport details
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('>>> [SignalR] ${record.level.name}: ${record.message}');
    });

    const hubUrl = AppConfig.hubUrl;
    debugPrint('>>> [ThongBao] Connecting to $hubUrl');

    _connection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              final t = await UserSession().getAccessToken() ?? '';
              debugPrint(
                '>>> [ThongBao] accessTokenFactory called, token length=${t.length}',
              );
              return t;
            },
            logMessageContent: true,
          ),
        )
        .configureLogging(Logger('SignalR'))
        .withAutomaticReconnect(retryDelays: [0, 2000, 10000, 30000])
        .build();

    _connection!.on('ReceiveNotification', (arguments) {
      debugPrint('>>> [ThongBao] ReceiveNotification raw: $arguments');
      if (arguments == null || arguments.isEmpty) return;

      final data = arguments[0] as Map<String, dynamic>? ?? {};
      final event = ThongBaoEvent(
        tieuDe: data['tieuDe'] as String? ?? 'Thông báo mới',
        noiDung: data['noiDung'] as String? ?? '',
        phanBoThongBaoId: data['phanBoThongBaoId'] as int?,
      );

      _controller.add(event);
      _unreadCount++;
      _unreadCountController.add(_unreadCount);
      _showLocalNotif(event);
    });

    _connection!.onreconnecting(
      ({error}) => debugPrint('>>> [ThongBao] Reconnecting... error=$error'),
    );

    _connection!.onreconnected(
      ({connectionId}) =>
          debugPrint('>>> [ThongBao] Reconnected id=$connectionId'),
    );

    _connection!.onclose(
      ({error}) => debugPrint('>>> [ThongBao] Connection closed error=$error'),
    );

    try {
      debugPrint('>>> [ThongBao] Calling _connection.start()...');
      await _connection!.start()?.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('>>> [ThongBao] TIMEOUT sau 30 giây');
          debugPrint('>>> [ThongBao] State khi timeout=${_connection?.state}');
        },
      );
      debugPrint('>>> [ThongBao] Connected! State=${_connection!.state}');
    } catch (e, stack) {
      debugPrint('>>> [ThongBao] connect() FAILED: $e');
      debugPrint('>>> [ThongBao] stack: $stack');
    }
  }

  void resetUnreadCount() {
    _unreadCount = 0;
    _unreadCountController.add(0);
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
    _unreadCount = 0;
    debugPrint('>>> [ThongBao] Disconnected');
  }
}
