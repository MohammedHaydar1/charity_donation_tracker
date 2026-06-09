import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/donation.dart';
import '../providers/app_provider.dart';
import '../app_theme.dart';

class AddEditDonationScreen extends StatefulWidget {
  final Donation? donation;
  const AddEditDonationScreen({super.key, this.donation});

  @override
  State<AddEditDonationScreen> createState() => _AddEditDonationScreenState();
}

class _AddEditDonationScreenState extends State<AddEditDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount, _note;

  int? _selectedCharityId;
  String _selectedCharityName = '';
  String _category = AppTheme.categories.first;
  String _paymentMethod = 'Cash';
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  String _recurringInterval = 'Monthly';

  @override
  void initState() {
    super.initState();
    final d = widget.donation;
    _amount = TextEditingController(text: d?.amount.toString() ?? '');
    _note = TextEditingController(text: d?.note ?? '');
    if (d != null) {
      _selectedCharityId = d.charityId;
      _selectedCharityName = d.charityName;
      _category = d.category;
      _paymentMethod = d.paymentMethod;
      _date = d.date;
      _isRecurring = d.isRecurring;
      _recurringInterval = d.recurringInterval ?? 'Monthly';
    }
  }

  @override
  void dispose() {
    _amount.dispose(); _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCharityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a charity')),
      );
      return;
    }
    final provider = context.read<AppProvider>();
    final d = Donation(
      id: widget.donation?.id,
      charityId: _selectedCharityId!,
      charityName: _selectedCharityName,
      amount: double.parse(_amount.text.trim()),
      category: _category,
      date: _date,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      isRecurring: _isRecurring,
      recurringInterval: _isRecurring ? _recurringInterval : null,
      paymentMethod: _paymentMethod,
    );

    if (widget.donation == null) {
      await provider.addDonation(d);
    } else {
      await provider.updateDonation(d);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final charities = context.watch<AppProvider>().charities;

    return Scaffold(
      appBar: AppBar(title: Text(widget.donation == null ? 'Add Donation' : 'Edit Donation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: _selectedCharityId,
                decoration: const InputDecoration(
                  labelText: 'Select Charity',
                  prefixIcon: Icon(Icons.volunteer_activism_outlined),
                ),
                items: charities.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Row(children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(c.colorValue), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(c.name),
                  ]),
                )).toList(),
                onChanged: (v) {
                  final c = charities.firstWhere((c) => c.id == v);
                  setState(() {
                    _selectedCharityId = v;
                    _selectedCharityName = c.name;
                    _category = c.category;
                  });
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final d = double.tryParse(v.trim());
                  if (d == null || d <= 0) return 'Enter a valid positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                items: AppTheme.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method', prefixIcon: Icon(Icons.payment_outlined)),
                items: AppTheme.paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormat('MMMM d, yyyy').format(_date)),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Note (optional)', prefixIcon: Icon(Icons.notes_outlined)),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recurring Donation', style: TextStyle(fontWeight: FontWeight.w500)),
                          Switch(
                            value: _isRecurring,
                            onChanged: (v) => setState(() => _isRecurring = v),
                            activeThumbColor: const Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                      if (_isRecurring) ...[
                        const Divider(height: 1),
                        DropdownButtonFormField<String>(
                          initialValue: _recurringInterval,
                          decoration: const InputDecoration(
                            labelText: 'Interval',
                            border: InputBorder.none,
                          ),
                          items: ['Weekly', 'Monthly', 'Quarterly', 'Yearly']
                              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                              .toList(),
                          onChanged: (v) => setState(() => _recurringInterval = v!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.donation == null ? 'Save Donation' : 'Update Donation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}