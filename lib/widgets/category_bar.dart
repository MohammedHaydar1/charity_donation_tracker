import 'package:flutter/material.dart';
import '../app_theme.dart';

class CategoryFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryFilterBar({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final all = ['All', ...AppTheme.categories];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: all.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = all[index];
          final isSelected = cat == selected;
          final color = cat == 'All'
              ? const Color(0xFF2E7D32)
              : (AppTheme.categoryColors[cat] ?? Colors.grey);
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}