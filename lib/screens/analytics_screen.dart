import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../app_theme.dart';
import '../widgets/monthly_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final monthTotal = p.thisMonthTotal;
    final goal = p.currentGoal?.goalAmount;
    final progress = (goal != null && goal > 0) ? (monthTotal / goal).clamp(0.0, 1.0) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Set monthly goal',
            onPressed: () => _showGoalDialog(context, goal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(title: monthName),
            if (goal != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monthly Goal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text(
                            '\$${monthTotal.toStringAsFixed(2)} / \$${goal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: progress! >= 1.0 ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        progress >= 1.0
                            ? 'Goal reached!'
                            : '\$${(goal - monthTotal).toStringAsFixed(2)} remaining',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _SectionHeader(title: 'Monthly Totals'),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  height: 200,
                  child: MonthlyChart(monthlyData: p.monthlyTotals),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionHeader(title: 'By Category'),
            if (p.byCategory.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text('No donations yet')),
                ),
              )
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _PieChart(byCategory: p.byCategory, total: p.totalDonated),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...p.byCategory.entries.map((e) {
                final color = AppTheme.categoryColors[e.key] ?? Colors.grey;
                final pct = p.totalDonated > 0 ? e.value / p.totalDonated : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                              ]),
                              Text(
                                '\$${e.value.toStringAsFixed(2)}  ${(pct * 100).toStringAsFixed(1)}%',
                                style: TextStyle(fontWeight: FontWeight.w600, color: color),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: color.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, double? current) {
    final ctrl = TextEditingController(text: current?.toStringAsFixed(2) ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Goal'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (\$)', prefixIcon: Icon(Icons.attach_money)),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val > 0) {
                context.read<AppProvider>().setGoal(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );
}

class _PieChart extends StatelessWidget {
  final Map<String, double> byCategory;
  final double total;

  const _PieChart({required this.byCategory, required this.total});

  @override
  Widget build(BuildContext context) {
    final sections = byCategory.entries.map((e) {
      final color = AppTheme.categoryColors[e.key] ?? Colors.grey;
      final pct = total > 0 ? (e.value / total * 100) : 0.0;
      return PieChartSectionData(
        value: e.value,
        color: color,
        title: '${pct.toStringAsFixed(0)}%',
        radius: 70,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }
}