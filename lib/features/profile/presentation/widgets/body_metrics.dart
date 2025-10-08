import 'package:flutter/material.dart';

class BodyMetricsSheet extends StatefulWidget {
  const BodyMetricsSheet({required this.user});
  final dynamic
  user; // expects ProfileModel (has gender, height cm, weight kg, age or dob)

  @override
  State<BodyMetricsSheet> createState() => BodyMetricsSheetState();
}

class BodyMetricsSheetState extends State<BodyMetricsSheet> {
  // Common activity multipliers
  static const _activityLevels = <String, double>{
    'Sedentary': 1.2,
    'Lightly active': 1.375,
    'Moderately active': 1.55,
    'Very active': 1.725,
    'Extra active': 1.9,
  };
  String _selectedActivity = 'Lightly active';

  int _computeAge(dynamic u) {
    if (u.age is int) return u.age as int;
    final dob = u.dob; // DateTime?
    if (dob is DateTime) {
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    }
    return 25; // reasonable fallback
  }

  double? _bmr(dynamic u) {
    final gender = (u.gender ?? '').toString().toLowerCase();
    final height = (u.height is num)
        ? (u.height as num).toDouble()
        : null; // cm
    final weight = (u.weight is num)
        ? (u.weight as num).toDouble()
        : null; // kg
    final age = _computeAge(u);
    if (height == null || weight == null || gender.isEmpty) return null;
    // Mifflin–St Jeor
    if (gender == 'male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bmr = _bmr(widget.user);
    final factor = _activityLevels[_selectedActivity]!;
    final tdee = bmr != null ? bmr * factor : null;

    // Targets (kg/week). 1 kg ≈ 7700 kcal
    // Rates are injected per group below.

    Widget _stat(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    Widget _chip(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Body metrics',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.user.bmi != null)
                  _chip('BMI ${widget.user.bmi!.toStringAsFixed(1)}'),
              ],
            ),
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary.withOpacity(0.08)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      children: [
                        _stat('Height', widget.user.height?.toString() ?? '--'),
                        _stat('Weight', widget.user.weight?.toString() ?? '--'),
                        _stat('Age', _computeAge(widget.user).toString()),
                        _stat(
                          'Gender',
                          (widget.user.gender ?? '--').toString(),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Activity level:',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedActivity,
                          items: _activityLevels.keys
                              .map(
                                (k) =>
                                    DropdownMenuItem(value: k, child: Text(k)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedActivity = v!),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _chip(
                          bmr == null ? 'BMR --' : 'BMR ${bmr.round()} kcal',
                        ),
                        const SizedBox(width: 8),
                        _chip(
                          tdee == null
                              ? 'TDEE --'
                              : 'TDEE ${tdee.round()} kcal',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calorie targets per day',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (tdee == null)
              Text(
                'Please add gender, height and weight to see calories.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                children: [
                  // Loss
                  _TargetGroup(
                    title: 'Weight loss',
                    color: cs.errorContainer,
                    textColor: cs.onErrorContainer,
                    tdee: tdee,
                    rates: const [-1.0, -0.75, -0.5, -0.25],
                  ),
                  const SizedBox(height: 8),
                  // Maintenance
                  _TargetGroup(
                    title: 'Maintenance',
                    color: cs.secondaryContainer,
                    textColor: cs.onSecondaryContainer,
                    tdee: tdee,
                    rates: const [0.0],
                  ),
                  const SizedBox(height: 8),
                  // Gain
                  _TargetGroup(
                    title: 'Weight gain',
                    color: cs.primaryContainer,
                    textColor: cs.onPrimaryContainer,
                    tdee: tdee,
                    rates: const [0.25, 0.5, 0.75, 1.0],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TargetGroup extends StatelessWidget {
  const _TargetGroup({
    required this.title,
    required this.color,
    required this.textColor,
    required this.tdee,
    required this.rates,
  });
  final String title;
  final Color color;
  final Color textColor;
  final double tdee;
  final List<double> rates; // kg/week

  static const double kcalPerKg = 7700.0;

  String _rateLabel(double r) => r == 0.0
      ? 'Maintenance'
      : (r.isNegative ? '${r.abs()} kg/wk' : '+${r} kg/wk');

  int _targetCalories(double r) {
    final dailyDelta = (r * kcalPerKg) / 7.0; // negative for loss
    return (tdee + dailyDelta).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            ...rates.map(
              (r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _rateLabel(r),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      '${_targetCalories(r)} kcal',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
