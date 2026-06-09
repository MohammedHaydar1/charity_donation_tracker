import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const MonthlyChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    final reversed = monthlyData.reversed.toList();
    final bars = reversed.asMap().entries.map((entry) {
      final val = (entry.value['total'] as num).toDouble();
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: val,
            color: const Color(0xFF4CAF50),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final maxY = reversed.fold<double>(
      0,
      (m, e) => (e['total'] as num).toDouble() > m ? (e['total'] as num).toDouble() : m,
    );

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barGroups: bars,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toInt()}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= reversed.length) return const SizedBox();
                final month = reversed[idx]['month'] as String;
                final parts = month.split('-');
                const abbr = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                final m = int.tryParse(parts[1]) ?? 0;
                return Text(abbr[m], style: const TextStyle(fontSize: 10, color: Colors.grey));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '\$${rod.toY.toStringAsFixed(2)}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}