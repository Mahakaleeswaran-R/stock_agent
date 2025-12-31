import 'dart:convert';
import 'package:hive/hive.dart';

part 'trade_signal.g.dart';

@HiveType(typeId: 0)
class TradeSignal extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String signal;

  @HiveField(2)
  final String tier; 

  @HiveField(3)
  final double entry;

  @HiveField(4)
  final double stopLoss;

  @HiveField(5)
  final double target;

  @HiveField(6)
  final String reason;

  @HiveField(7)
  final String rsi;

  @HiveField(8)
  final DateTime timestamp;

  @HiveField(9)
  final String source;

  @HiveField(10)
  final String fullJson;

  @HiveField(11)
  final double aiConfidence;

  @HiveField(12)
  final double techConfidence;

  @HiveField(13)
  final double t1;

  @HiveField(14)
  final double t2;

  @HiveField(15)
  final double t3;

  @HiveField(16)
  final int qty;

  @HiveField(17)
  final List<String> pdfSummary;

  TradeSignal({
    required this.symbol,
    required this.signal,
    required this.tier,
    required this.entry,
    required this.stopLoss,
    required this.target,
    required this.reason,
    required this.rsi,
    required this.timestamp,
    required this.source,
    required this.fullJson,
    this.aiConfidence = 0.0,
    this.techConfidence = 0.0,
    this.t1 = 0.0,
    this.t2 = 0.0,
    this.t3 = 0.0,
    this.qty = 0,
    this.pdfSummary = const [],
  });

  factory TradeSignal.fromJson(Map<String, dynamic> json) {
    List<String> parseSummary(dynamic val) {
      try {
        if (val == null) return [];
        if (val is List) return List<String>.from(val);
        if (val is String) {
          final decoded = jsonDecode(val);
          return List<String>.from(decoded);
        }
        return [];
      } catch (e) {
        return [];
      }
    }

    return TradeSignal(
      symbol: json['symbol'] ?? 'UNKNOWN',
      signal: json['side'] ?? (json['signal'] ?? 'ALERT'), 
      tier: json['tier'] ?? 'MODERATE',
      entry: double.tryParse(json['entry'].toString()) ?? 0.0,
      stopLoss: double.tryParse(json['stop_loss'].toString()) ?? 0.0,
      target: double.tryParse(json['t1'].toString()) ?? 0.0, 
      reason: json['catalyst'] ?? (json['reason'] ?? 'Technical Signal'),
      rsi: json['rsi'] ?? '0',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      source: json['source'] ?? 'AI_BOT',
      fullJson: jsonEncode(json),
      aiConfidence: double.tryParse(json['ai_conf'].toString()) ?? 0.0,
      techConfidence: double.tryParse(json['tech_conf'].toString()) ?? 0.0,
      t1: double.tryParse(json['t1'].toString()) ?? 0.0,
      t2: double.tryParse(json['t2'].toString()) ?? 0.0,
      t3: double.tryParse(json['t3'].toString()) ?? 0.0,
      qty: int.tryParse(json['qty'].toString()) ?? 0,
      pdfSummary: parseSummary(json['pdf_summary']),
    );
  }

  bool get isExpired {
    final expiry = timestamp.add(const Duration(hours: 24));
    return DateTime.now().isAfter(expiry);
  }
}