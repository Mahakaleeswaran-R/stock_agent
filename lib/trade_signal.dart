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
  });


  factory TradeSignal.fromJson(Map<String, dynamic> json) {
    return TradeSignal(
      symbol: json['symbol'] ?? 'UNKNOWN',
      signal: json['signal'] ?? 'ALERT',
      tier: json['tier'] ?? 'MODERATE',
      entry: double.tryParse(json['entry'].toString()) ?? 0.0,
      stopLoss: double.tryParse(json['stop_loss'].toString()) ?? 0.0,
      target: double.tryParse(json['take_profit'].toString()) ?? 0.0,
      reason: json['reason'] ?? 'Technical Signal',
      rsi: json['rsi'] ?? '50',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      source: json['source'] ?? 'SRC_ERR',
      fullJson: json['full_json'] ?? '{}',
    );
  }


  bool get isExpired {
    final expiry = timestamp.add(const Duration(hours: 24));
    return DateTime.now().isAfter(expiry);
  }
}