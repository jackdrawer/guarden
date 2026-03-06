import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_utils.dart';

/// A neumorphic-styled pie chart showing subscription spending by category or service.
class SubscriptionPieChart extends StatefulWidget {
  /// Map of label → monthly cost (already normalized).
  final Map<String, double> data;
  final String currency;

  const SubscriptionPieChart({
    super.key,
    required this.data,
    required this.currency,
  });

  @override
  State<SubscriptionPieChart> createState() => _SubscriptionPieChartState();
}

class _SubscriptionPieChartState extends State<SubscriptionPieChart> {
  int _touchedIndex = -1;

  static const List<Color> _palette = [
    Color(0xFFEF8539), // primaryAccent orange
    Color(0xFF48BB78), // success green
    Color(0xFF63B3ED), // soft blue
    Color(0xFFFC8181), // soft red
    Color(0xFFD6BCFA), // lavender
    Color(0xFFF6AD55), // amber
    Color(0xFF68D391), // mint
    Color(0xFF7FDBFF), // sky blue
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    final total = widget.data.values.fold(0.0, (a, b) => a + b);
    final entries = widget.data.entries.toList();

    final sections = List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final value = entries[i].value;
      final percent = total > 0
          ? (value / total * 100).toStringAsFixed(1)
          : '0';
      return PieChartSectionData(
        color: _palette[i % _palette.length],
        value: value,
        title: isTouched ? '${entries[i].key}\n$percent%' : '$percent%',
        radius: isTouched ? 72 : 60,
        titleStyle: TextStyle(
          fontSize: isTouched ? 13 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black38, blurRadius: 3)],
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: List.generate(entries.length, (i) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _palette[i % _palette.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${entries[i].key}: ${CurrencyUtils.formatAmount(entries[i].value, widget.currency)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
