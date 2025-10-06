import 'package:flutter/material.dart';
import 'package:pacemate/core/theme/app_theme.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        backgroundColor: Colors.transparent,
        color: AppTheme.onBg,
        valueColor: AlwaysStoppedAnimation(Colors.white),
      ),
    );
  }
}
