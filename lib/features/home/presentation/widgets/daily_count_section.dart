import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Displays today's distance and calories in two cards, with a simple
/// weekly calories "graph" made of filled containers.
class DailyCountSection extends StatelessWidget {
  const DailyCountSection({
    super.key,
    required this.distanceKm,
    required this.calories,
    required this.weeklyCalories,
    this.todayIndex,
  });

  /// Distance ran today in kilometers.
  final double distanceKm;

  /// Calories burned today.
  final int calories;

  /// Weekly calories burned, starting from Sunday (length up to 7).
  final List<int> weeklyCalories;

  /// Index of today within [weeklyCalories] (0..6). If null, the last item is highlighted.
  final int? todayIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gradients = theme.extension<AppGradients>() ?? AppGradients.defaults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Your Distance',
                value: '${distanceKm.toStringAsFixed(2)} km',
                icon: Icons.directions_run_outlined,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Calories Burnt',
                value: '$calories kcal',
                icon: Icons.local_fire_department_outlined,
                color: Colors.orangeAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekly bar graph (not actual chart, just containers)
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: _WeeklyBarGraph(
            values: weeklyCalories,
            todayIndex: todayIndex,
            barGradient: gradients.heat as LinearGradient,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarGraph extends StatelessWidget {
  const _WeeklyBarGraph({
    required this.values,
    this.todayIndex,
    required this.barGradient,
  });

  final List<int> values;
  final int? todayIndex;
  final LinearGradient barGradient;

  static const _labels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final list = values.isEmpty
        ? List<int>.filled(7, 0)
        : (values.length == 7
              ? values
              : List<int>.generate(
                  7,
                  (i) => i < values.length ? values[i] : 0,
                ));

    final maxVal = list.fold<int>(0, (p, n) => n > p ? n : p).clamp(0, 1 << 31);
    final highlight = (todayIndex ?? (list.length - 1)).clamp(
      0,
      list.length - 1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weekly Calories Burnt', style: theme.textTheme.titleMedium),
            Text(
              '${list.reduce((a, b) => a + b)} kcal',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < list.length; i++)
                Expanded(
                  child: _Bar(
                    value: list[i].toDouble(),
                    max: (maxVal == 0 ? 1 : maxVal).toDouble(),
                    label: _labels[i],
                    isHighlighted: i == highlight,
                    gradient: barGradient,
                    labelColor: cs.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.max,
    required this.label,
    required this.isHighlighted,
    required this.gradient,
    required this.labelColor,
  });

  final double value;
  final double max;
  final String label;
  final bool isHighlighted;
  final LinearGradient gradient;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final barHeight = (value / (max == 0 ? 1 : max)) * 200.0;
    final minHeight = 8.0;
    final height = barHeight.isFinite
        ? (barHeight.clamp(minHeight, 200.0))
        : minHeight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTapDown: (details) {
              _showValueTooltip(context, details.globalPosition);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: height,
              decoration: BoxDecoration(
                gradient: isHighlighted ? gradient : null,
                color: isHighlighted
                    ? null
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: labelColor,
              fontSize: 10,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showValueTooltip(BuildContext context, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 25,
        top: position.dy - 50,
        child: _TooltipBubble(
          text: '${value.toStringAsFixed(1)} kcal',
          onDismiss: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
  }
}

class _TooltipBubble extends StatefulWidget {
  const _TooltipBubble({required this.text, required this.onDismiss});

  final String text;
  final VoidCallback onDismiss;

  @override
  State<_TooltipBubble> createState() => _TooltipBubbleState();
}

class _TooltipBubbleState extends State<_TooltipBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    // Auto dismiss after 1.5 seconds
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
