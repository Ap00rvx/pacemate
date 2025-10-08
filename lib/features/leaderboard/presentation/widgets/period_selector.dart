// Period segmented control
import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({required this.period, required this.onChanged});
  final String period; // 'week' | 'month' | 'year' | 'all'
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = const ['week', 'month', 'year', 'all'];
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (final p in options)
          ChoiceChip(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            label: Text(p[0].toUpperCase() + p.substring(1)),
            selected: period == p,
            onSelected: (v) => v ? onChanged(p) : null,
          ),
      ],
    );
  }
}
