import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/widgets/overlay.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/features/social/domain/entities/social_user.dart';
import 'package:pacemate/features/social/presentation/bloc/social_bloc.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key, required this.user, required this.isFriend});
  final SocialUser user;
  final bool isFriend;

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthBloc>().state.user?.id;
    final isRequestSent =
        widget.user.friendRequests?.contains(currentUserId) ?? false;
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
                          widget.user.fullname,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.onBg,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          '   (${widget.user.gender})',
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
                          widget.user.location ?? '',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Friends - ${widget.user.friends?.length.toInt()}",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.onBg,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        if (widget.isFriend)
                          const SizedBox.shrink()
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              fixedSize: Size.fromHeight(30),
                              backgroundColor: isRequestSent
                                  ? AppTheme.muted.withAlpha(30)
                                  : AppTheme.primary,
                            ),
                            onPressed: () {
                              if (isRequestSent) return;
                              context.read<SocialBloc>().add(
                                AddFriendEvent(widget.user.id),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Friend request sent to ${widget.user.fullname}',
                                  ),
                                ),
                              );
                            },
                            child: isRequestSent
                                ? const Text(
                                    'Request Sent',
                                    style: TextStyle(fontSize: 12),
                                  )
                                : const Text(
                                    'Add Friend',
                                    style: TextStyle(fontSize: 12),
                                  ),
                          ),
                      ],
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
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
                      child: ClipOval(
                        child: SizedBox(
                          height: 146,
                          width: 146,
                          child: widget.user.avatar != null
                              ? Image.network(
                                  widget.user.avatar!,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    widget.user.fullname[0].toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontSize: 60,
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
