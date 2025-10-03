import 'package:flutter/material.dart';
import 'package:pacemate/core/theme/app_theme.dart';

class AppLogo extends StatefulWidget {
  const AppLogo({super.key});

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: 6,
      children: [
        Text(
          'PaceMate',
          style: TextStyle(
            color: AppTheme.onBg,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        Icon(Icons.directions_run_sharp, color: AppTheme.primary, size: 20),
      ],
    );
  }
}
