import 'package:flutter/material.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/utils/wish_message.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${WishMessage.getMessage()}, Ready to do the Good Work Today?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppTheme.muted,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          "Run Your Way to a Better Health",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 35,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
