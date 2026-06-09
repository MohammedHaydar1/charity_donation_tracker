import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/donation_card.dart';
import '../widgets/category_bar.dart';
import 'add_edit_donation_screen.dart';

class DonationsScreen extends StatefulWidget {
  final int? filterCharityId;
  final String? title;
  const DonationsScreen({super.key, this.filterCharityId, this.title});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final donations = widget.filterCharityId != null
        ? provider.donations.where((d) => d.charityId == widget.filterCharityId).toList()
        : provider.donations;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditDonationScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Search donations...',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          provider.setSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (widget.filterCharityId == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CategoryFilterBar(
                selected: provider.selectedCategory,
                onSelected: provider.setCategory,
              ),
            ),
          Expanded(
            child: donations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        const Text('No donations found', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: donations.length,
                    itemBuilder: (_, i) => DonationCard(
                      donation: donations[i],
                      onDelete: () => _confirmDelete(context, donations[i].id!),
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddEditDonationScreen(donation: donations[i])),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditDonationScreen()),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Donation'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppProvider>().deleteDonation(id);
    }
  }
}