import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/charity.dart';
import '../providers/app_provider.dart';
import '../app_theme.dart';

class AddEditCharityScreen extends StatefulWidget {
  final Charity? charity;
  const AddEditCharityScreen({super.key, this.charity});

  @override
  State<AddEditCharityScreen> createState() => _AddEditCharityScreenState();
}

class _AddEditCharityScreenState extends State<AddEditCharityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name, _description, _website;
  String _category = AppTheme.categories.first;
  Color _selectedColor = const Color(0xFF43A047);

  final _palette = [
    Color(0xFF43A047), Color(0xFF5C6BC0), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF8D6E63), Color(0xFFEC407A),
    Color(0xFF26C6DA), Color(0xFFFF7043), Color(0xFF7E57C2), Color(0xFF90A4AE),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.charity;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _website = TextEditingController(text: c?.website ?? '');
    if (c != null) {
      _category = c.category;
      _selectedColor = Color(c.colorValue);
    }
  }

  @override
  void dispose() {
    _name.dispose(); _description.dispose(); _website.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final c = Charity(
      id: widget.charity?.id,
      name: _name.text.trim(),
      category: _category,
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      website: _website.text.trim().isEmpty ? null : _website.text.trim(),
      colorValue: _selectedColor.value,
      createdAt: widget.charity?.createdAt ?? DateTime.now(),
    );
    if (widget.charity == null) {
      await provider.addCharity(c);
    } else {
      await provider.updateCharity(c);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.charity == null ? 'Add Charity' : 'Edit Charity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Charity Name', prefixIcon: Icon(Icons.volunteer_activism_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                items: AppTheme.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optional)', prefixIcon: Icon(Icons.notes_outlined)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _website,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Website (optional)', prefixIcon: Icon(Icons.link_outlined)),
              ),
              const SizedBox(height: 20),
              const Text('Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _palette.map((c) {
                  final selected = c.value == _selectedColor.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: Colors.black54, width: 3) : null,
                      ),
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.charity == null ? 'Add Charity' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}