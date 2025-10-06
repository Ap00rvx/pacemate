import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/widgets/overlay.dart';
import 'package:pacemate/features/auth/domain/model/user_model.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppTheme.bg),
      constraints: BoxConstraints(minHeight: 120, maxHeight: 450),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 225,
                width: double.infinity,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 225,
                      width: double.infinity,
                      child: Image.asset(
                        "assets/images/orange_bg.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    CommonOverlay(),
                  ],
                ),
              ),
              const SizedBox(height: 75),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 7,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          user.fullname,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.onBg,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          '   (${user.gender})',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.muted,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location4,
                          size: 14,
                          color: AppTheme.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.location ?? '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Friends - ${user.friends.length.toInt()}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onBg,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  alignment: Alignment.center,
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryLight.withAlpha(60),
                      width: 2,
                    ),
                    color: AppTheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: user.avatar != null
                      ? Image.network(user.avatar!, fit: BoxFit.cover)
                      : Text(
                          user.initials,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontSize: 60,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
