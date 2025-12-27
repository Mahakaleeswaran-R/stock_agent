import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import 'trade_signal.dart';

class StorageService {
  static const String boxName = 'trades_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TradeSignalAdapter());
    }
    // Don't open the box here automatically to avoid locking issues
  }

  // Helper to safely get the box (opening it if needed)
  static Future<Box<TradeSignal>> getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<TradeSignal>(boxName);
    } else {
      return await Hive.openBox<TradeSignal>(boxName);
    }
  }

  static Future<void> addSignal(TradeSignal signal) async {
    final box = await getBox();
    final uniqueId = Random().nextInt(999999).toString();
    final key = "${signal.symbol}_${DateTime.now().microsecondsSinceEpoch}_$uniqueId";
    await box.put(key, signal);
  }

  static Future<void> deleteSignal(dynamic key) async {
    final box = await getBox();
    await box.delete(key);
  }

  static Future<void> cleanupExpiredTrades() async {
    final box = await getBox();
    final keysToDelete = <dynamic>[];

    for (var key in box.keys) {
      final trade = box.get(key);
      if (trade != null && trade.isExpired) {
        keysToDelete.add(key);
      }
    }
    if (keysToDelete.isNotEmpty) {
      await box.deleteAll(keysToDelete);
    }
  }
  
  static Future<void> closeBox() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<TradeSignal>(boxName).close();
    }
  }
}