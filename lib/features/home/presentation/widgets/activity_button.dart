import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/core/theme/app_theme.dart';

class ActivityButton extends StatefulWidget {
  const ActivityButton({super.key});

  @override
  State<ActivityButton> createState() => _ActivityButtonState();
}

class _ActivityButtonState extends State<ActivityButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: 200,
        ),

        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.route_rounded,
                          size: 30,
                          color: AppTheme.onBg,
                        ),
                        Text(
                          'Total Distance',
                          style: TextStyle(
                            color: AppTheme.onBg,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        text: '10.25',
                        style: TextStyle(
                          color: AppTheme.onBg,
                          fontSize: 55,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: ' km',
                            style: TextStyle(
                              color: AppTheme.onBg,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Increased 5.4%',
                          style: TextStyle(color: AppTheme.onBg, fontSize: 14),
                        ),

                        Icon(
                          Iconsax.arrow_up_1,
                          size: 25,
                          color: AppTheme.onBg,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  stops: [0.6, 1.0],
                  colors: [AppTheme.primaryLight, AppTheme.primary],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Image.asset(
                    'assets/images/pacemate_run.png',
                    scale: 1,
                    height: 160,

                    fit: BoxFit.cover,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
