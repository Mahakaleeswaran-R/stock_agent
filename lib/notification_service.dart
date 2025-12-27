import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'trade_signal.dart';
import 'storage_service.dart';


final Logger logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await StorageService.init();
  await NotificationService.saveMessageToDb(message.data);
  await StorageService.closeBox();
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('User granted notification permission');
    } else {
      logger.w('User declined or has not accepted notification permission');
    }

    await _firebaseMessaging.subscribeToTopic('trades');
    logger.i("Subscribed to 'trades' broadcast channel");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.d("Foreground Message received: ${message.data}");
      
      saveMessageToDb(message.data);

      if (message.data.isNotEmpty) {
        final signalType = message.data['signal']?.toString().toUpperCase() ?? "ALERT";
        final symbol = message.data['symbol'] ?? "UNKNOWN";
        final entry = message.data['entry'] ?? "0.0";
        final target = message.data['take_profit'] ?? "0.0";

        final isBuy = signalType == "BUY";
        final bgColor = isBuy ? const Color(0xFF00C853) : const Color(0xFFD32F2F);
        final icon = isBuy ? Icons.trending_up : Icons.trending_down;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16), 
            elevation: 8,
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$signalType $symbol",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Price: $entry  ➔  Target: $target",
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 70), 
          ),
        );
      }
    });

    String? token = await _firebaseMessaging.getToken();
    logger.i("DEVICE TOKEN: $token");
  }

  static Future<void> saveMessageToDb(Map<String, dynamic> data) async {
    try {
      if (data.isEmpty) return;
      final signal = TradeSignal.fromJson(data);
      logger.d("Saving Signal to DB: ${signal.symbol}");
      await StorageService.addSignal(signal);
    } catch (e, stackTrace) {
      logger.e("Error saving signal", error: e, stackTrace: stackTrace);
    }
  }
}