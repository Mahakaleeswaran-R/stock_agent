import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'trade_signal.dart';
import 'storage_service.dart';

class TradeProvider with ChangeNotifier, WidgetsBindingObserver {
  List<TradeSignal> _trades = [];
  List<TradeSignal> get trades => _trades;

  TradeProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loadTrades();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      StorageService.closeBox();
    } else if (state == AppLifecycleState.resumed) {
      _loadTrades();
    }
  }

  Future<void> _loadTrades() async {
    try {
      final box = await StorageService.getBox();
      _refreshList(box);
      box.listenable().addListener(() {
        if (box.isOpen) _refreshList(box);
      });
    } catch (e) {
      debugPrint("Error loading trades: $e");
    }
  }

  void _refreshList(Box<TradeSignal> box) {
    final allTrades = box.values.toList();
    allTrades.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _trades = allTrades.where((t) => !t.isExpired).toList();
    notifyListeners();
  }

  Future<void> removeTrade(TradeSignal signal) async {
    await signal.delete();
    notifyListeners();
  }
}