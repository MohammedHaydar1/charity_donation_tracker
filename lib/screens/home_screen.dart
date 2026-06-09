import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_card.dart';
import '../app_theme.dart';
import 'donations_screen.dart';
import 'charities_screen.dart';
import 'analytics_screen.dart';
import 'add_edit_donation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _tabs = const [
    _DashboardTab(),
    DonationsScreen(),
    CharitiesScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_outlined), selectedIcon: Icon(Icons.list), label: 'Donations'),
          NavigationDestination(icon: Icon(Icons.volunteer_activism_outlined), selectedIcon: Icon(Icons.volunteer_activism), label: 'Charities'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Analytics'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final now = DateTime.now();
    final monthTotal = p.thisMonthTotal;
    final goal = p.currentGoal?.goalAmount;
    final progress = (goal != null && goal > 0) ? (monthTotal / goal).clamp(0.0, 1.0) : null;
    final topCategory = p.byCategory.isNotEmpty ? p.byCategory.entries.first : null;
    final recentDonations = p.donations.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charity Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Donation',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditDonationScreen()),
            ),
          ),
        ],
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: p.loadAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Donor 👋',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${p.totalDonated.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Total donated all time',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          if (progress != null) ...[
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DateFormat('MMMM').format(now)} goal',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  '\$${monthTotal.toStringAsFixed(2)} / \$${goal!.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                        children: [
                          StatCard(
                            label: 'This month',
                            value: '\$${monthTotal.toStringAsFixed(2)}',
                            icon: Icons.calendar_month_outlined,
                            color: const Color(0xFF5C6BC0),
                            subtitle: DateFormat('MMM yyyy').format(now),
                          ),
                          StatCard(
                            label: 'Donations',
                            value: '${p.donations.length}',
                            icon: Icons.receipt_long_outlined,
                            color: const Color(0xFF43A047),
                          ),
                          StatCard(
                            label: 'Charities',
                            value: '${p.charities.length}',
                            icon: Icons.volunteer_activism_outlined,
                            color: const Color(0xFFFF8F00),
                          ),
                          if (topCategory != null)
                            StatCard(
                              label: 'Top category',
                              value: topCategory.key,
                              icon: AppTheme.categoryIcons[topCategory.key] ?? Icons.category_outlined,
                              color: AppTheme.categoryColors[topCategory.key] ?? Colors.grey,
                              subtitle: '\$${topCategory.value.toStringAsFixed(0)}',
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Donations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (p.donations.isNotEmpty)
                            TextButton(
                              onPressed: () {},
                              child: const Text('See all'),
                            ),
                        ],
                      ),
                    ),
                    if (recentDonations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              const Text('No donations yet. Add one!', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      ...recentDonations.map((d) {
                        final color = AppTheme.categoryColors[d.category] ?? Colors.grey;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(AppTheme.categoryIcons[d.category] ?? Icons.volunteer_activism_outlined, color: color, size: 20),
                          ),
                          title: Text(d.charityName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                          subtitle: Text(DateFormat('MMM d, yyyy').format(d.date), style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                            '\$${d.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}