import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'trade_signal.dart';

class TradeCard extends StatefulWidget {
  final TradeSignal signal;
  final VoidCallback onDelete;

  const TradeCard({
    super.key,
    required this.signal,
    required this.onDelete,
  });

  @override
  State<TradeCard> createState() => _TradeCardState();
}

class _TradeCardState extends State<TradeCard> {
  late Timer _timer;
  late Duration _timeLeft;
  late double _limitPrice;

  @override
  void initState() {
    super.initState();
    _parseDetails();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _parseDetails() {
    try {
      if (widget.signal.fullJson.isNotEmpty) {
        final data = jsonDecode(widget.signal.fullJson);
        _limitPrice = data['limit_price']?.toDouble() ?? 0.0;
      } else {
        _limitPrice = 0.0;
      }
    } catch (e) {
      _limitPrice = 0.0;
    }
  }

  void _calculateTimeLeft() {
    final expiryTime = widget.signal.timestamp.add(const Duration(hours: 24));
    final now = DateTime.now();
    if (now.isAfter(expiryTime)) {
      widget.onDelete();
      _timer.cancel();
    } else {
      if (mounted) {
        setState(() {
          _timeLeft = expiryTime.difference(now);
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.signal.signal == 'BUY';
    final formattedDate = DateFormat('dd MMM HH:mm:ss').format(widget.signal.timestamp);
    final hoursLeft = _timeLeft.inHours;
    final neonColor = isBuy ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final bgGradient = isBuy
        ? [const Color(0xFF0D2810), const Color(0xFF000000)]
        : [const Color(0xFF280D0D), const Color(0xFF000000)];
    final backgroundImageAsset = isBuy ? 'images/bull.png' : 'images/bear.png';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: neonColor.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              bottom: -50,
              child: Opacity(
                opacity: 0.30,
                child: Image.asset(
                  backgroundImageAsset,
                  color: isBuy ? Colors.green : Colors.red,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      isBuy ? Icons.trending_up : Icons.trending_down,
                      size: 180,
                      color: Colors.white.withOpacity(0.04),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: neonColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(isBuy ? Icons.trending_up : Icons.trending_down, color: neonColor, size: 15),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.signal.symbol,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${widget.signal.tier} CONFIDENCE",
                                style: GoogleFonts.inter(
                                  color: neonColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.notifications_on, color: Colors.white60, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child:  Text(
                                    widget.signal.source,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white60,
                                    ),
                                  ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.timer_outlined, color: Colors.white60, size: 10),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${hoursLeft}h",
                                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  Divider(color: Colors.white.withOpacity(0.1)),
                                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildDataPoint("ENTRY PRICE", widget.signal.entry, Colors.white),
                      const SizedBox(width: 8),
                      _buildDataPoint("MAX LIMIT", _limitPrice, Colors.white),
                      const SizedBox(width: 8),
                      _buildDataPoint("TARGET", widget.signal.target, const Color(0xFF69F0AE)),
                      const SizedBox(width: 8),
                      _buildDataPoint("STOP LOSS", widget.signal.stopLoss, const Color(0xFFFF8A80)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: neonColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              "AI CATALYST",
                              style: GoogleFonts.inter(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              "RSI ${widget.signal.rsi}",
                              style: GoogleFonts.robotoMono(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.signal.reason,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 10, height: 1.4, letterSpacing: 0.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPoint(String label, double value, Color color) {
    final currencyFormat = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 8,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value == 0.0 ? "--" : currencyFormat.format(value),
          style: GoogleFonts.robotoMono(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}