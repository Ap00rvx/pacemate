import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/widgets/overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/features/auth/domain/model/user_model.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/features/profile/domain/model/profle_model.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key, required this.user});
  final ProfileModel user;

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  bool _uploading = false;

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      if (choice == null) return;

      XFile? file;
      if (choice == 'camera') {
        file = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
        );
      } else {
        file = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
      }
      if (file == null) return;

      setState(() => _uploading = true);
      context.read<AuthBloc>().add(UpdateProfileEvent(avatar: file.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

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
                        GestureDetector(
                          onTap: () {
                            // show bottom sheet with friends list
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return FractionallySizedBox(
                                  heightFactor: 0.75,
                                  child: Scaffold(
                                    appBar: AppBar(
                                      title: const Text('Friends'),
                                      backgroundColor: AppTheme.bg,
                                      foregroundColor: AppTheme.onBg,
                                      elevation: 1,
                                    ),
                                    body: widget.user.friends.isEmpty
                                        ? const Center(
                                            child: Text('No friends yet'),
                                          )
                                        : ListView.separated(
                                            itemCount:
                                                widget.user.friends.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const Divider(),
                                            itemBuilder: (context, index) {
                                              final friend =
                                                  widget.user.friends[index];
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage:
                                                      friend.avatar != null
                                                          ? NetworkImage(
                                                              friend.avatar!)
                                                          : null,
                                                  child: friend.avatar == null
                                                      ? Text(
                                                          friend.fullname[0]
                                                              .toUpperCase(),
                                                        )
                                                      : null,
                                                ),
                                                title: Text(friend.fullname),
                                               
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  // AppRouter.push(
                                                  //   RouteNames().userProfile,
                                                  //   context,
                                                  //   args: friend,
                                                  // );
                                                },
                                              );
                                            },
                                          ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "Friends - ${widget.user.friends.length.toInt()}",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.onBg,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fixedSize: Size.fromHeight(30),
                            backgroundColor: AppTheme.muted.withAlpha(30),
                          ),
                          onPressed: () {
                            AppRouter.push(
                              RouteNames().friendRequests,
                              context,
                            );
                          },
                          child: const Text(
                            "View Friend Requests",
                            style: TextStyle(fontSize: 11),
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
                    Positioned(
                      right: 12,
                      bottom: 8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          shape: const CircleBorder(),
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onBg,
                        ),
                        onPressed: _uploading ? null : _pickAndUploadAvatar,
                        child: _uploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.camera_alt, size: 18),
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
