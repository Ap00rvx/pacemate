import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/widgets/logo_place.dart';
import 'package:pacemate/core/widgets/overlay.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: AppLogo(),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pacemate_theme_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            //overly
            CommonOverlay(),
            //content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Start Your Running Journey",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.onBg,
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Take your first step towards a healthier lifestyle with PaceMate. more active, more energized, and more you.",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigate to the next page or perform an action
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(500),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to the next page or perform an action
                            },
                            child: Icon(Iconsax.arrow_right_1, size: 24),
                          ),
                          Spacer(),
                          Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onBg,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded, size: 20),
                          Icon(Icons.arrow_forward_ios_rounded, size: 20),
                          Icon(Icons.arrow_forward_ios_rounded, size: 20),
                          SizedBox(width: 14),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
