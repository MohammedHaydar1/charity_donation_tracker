import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/charity_avatar.dart';
import '../app_theme.dart';
import 'add_edit_charity_screen.dart';
import 'donations_screen.dart';

class CharitiesScreen extends StatelessWidget {
  const CharitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final charities = provider.charities;
    final byCharity = provider.byCharity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Charities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditCharityScreen()),
            ),
          ),
        ],
      ),
      body: charities.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('No charities added yet', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditCharityScreen())),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Charity'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: charities.length,
              itemBuilder: (_, i) {
                final c = charities[i];
                final total = byCharity[c.id] ?? 0.0;
                final color = AppTheme.categoryColors[c.category] ?? Colors.grey;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CharityAvatar(charity: c, size: 48),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(c.category, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        if (c.description != null && c.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(c.description!, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E7D32)),
                        ),
                        Text('donated', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => DonationsScreen(filterCharityId: c.id, title: c.name),
                    )),
                    onLongPress: () => _showOptions(context, c.id!),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditCharityScreen())),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showOptions(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                final c = context.read<AppProvider>().charities.firstWhere((x) => x.id == id);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditCharityScreen(charity: c)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                await context.read<AppProvider>().deleteCharity(id);
              },
            ),
          ],
        ),
      ),
    );
  }
}