import 'package:flutter/material.dart';
import 'package:pacemate/core/widgets/logo_place.dart';
import 'package:pacemate/features/home/presentation/widgets/activity_button.dart';
import 'package:pacemate/features/home/presentation/widgets/daily_count_section.dart';
import 'package:pacemate/features/home/presentation/widgets/header.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, size: 18),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              ActivityButton(),
              DailyCountSection(
                distanceKm: 3.4,
                calories: 333,
                weeklyCalories: [300, 450, 500, 0, 122, 0, 0],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
