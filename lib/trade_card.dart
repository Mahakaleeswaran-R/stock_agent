import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'trade_signal.dart';

class TradeCard extends StatefulWidget {
  final TradeSignal signal;
  final VoidCallback onDelete;

  const TradeCard({super.key, required this.signal, required this.onDelete});

  @override
  State<TradeCard> createState() => _TradeCardState();
}

class _TradeCardState extends State<TradeCard> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateTimeLeft();
    });
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
    final formattedDate = DateFormat(
      'dd MMM HH:mm:ss',
    ).format(widget.signal.timestamp);
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
          ),
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
                            child: Icon(
                              isBuy ? Icons.trending_up : Icons.trending_down,
                              color: neonColor,
                              size: 15,
                            ),
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
                                "${widget.signal.tier} TIER",
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTitleBadge(
                            formattedDate,
                            Icons.notifications_on,
                            isBuy,
                          ),
                          const SizedBox(width: 6),
                          _buildTitleBadge(
                            "${hoursLeft} hr",
                            Icons.timer_outlined,
                            isBuy,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(color: Colors.white.withOpacity(0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDataPoint(
                        "ENTRY PRICE",
                        widget.signal.entry,
                        Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Text(
                            "TARGETS",
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTarget(
                                widget.signal.t1,
                                widget.signal.entry,
                                isBuy,
                              ),
                              const SizedBox(width: 8),
                              _buildTarget(
                                widget.signal.t2,
                                widget.signal.entry,
                                isBuy,
                              ),
                              const SizedBox(width: 8),
                              _buildTarget(
                                widget.signal.t3,
                                widget.signal.entry,
                                isBuy,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      _buildDataPoint(
                        "STOP LOSS",
                        widget.signal.stopLoss,
                        Colors.red.shade700,
                      ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.bubble_chart,
                                  color: neonColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 1),
                                Text(
                                  "ANALYST",
                                  style: GoogleFonts.inter(
                                    color: Colors.white60,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildConfidenceBadge(
                                  widget.signal.aiConfidence,
                                  Icons.auto_awesome,
                                  isBuy,
                                ),
                                const SizedBox(width: 6),
                                _buildConfidenceBadge(
                                  widget.signal.techConfidence,
                                  Icons.bar_chart,
                                  isBuy,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.signal.reason,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.signal.pdfSummary.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                ...widget.signal.pdfSummary
                                    .take(3)
                                    .map(
                                      (point) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "• ",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                point,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ],
                            ],
                          ),
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
    final currencyFormat = NumberFormat.simpleCurrency(
      name: 'INR',
      decimalDigits: 2,
    );
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

  Widget _buildConfidenceBadge(double value, IconData icon, bool isBuy) {
    final color = isBuy ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            "${(value * 100).toInt()}%",
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBadge(String value, IconData icon, bool isBuy) {
    final color = isBuy ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarget(double val, double entry, bool isBuy) {
    if (val == 0) return const SizedBox();
    final pct = entry > 0 ? ((val - entry) / entry * 100).abs() : 0.0;
    return Column(
      children: [
        Text(
          val.toStringAsFixed(2),
          style: GoogleFonts.robotoMono(
            color: Colors.green,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${pct.toStringAsFixed(1)}%",
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}
