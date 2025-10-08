import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:pacemate/core/env/env_service.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/features/activities/activities_di.dart';
import 'package:pacemate/features/auth/auth_di.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/features/home/presentation/bloc/search_cubit.dart';
import 'package:pacemate/features/social/social_di.dart';
import 'package:pacemate/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/tracking/presentation/background/background_location_callback.dart'
    show kNotifTapFlagKey;
import 'features/tracking/presentation/bloc/location_cubit.dart';
import 'features/tracking/presentation/bloc/tracking_cubit.dart';
import 'package:background_locator_2/background_locator.dart' as bl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.init();
  // Ensure background locator is initialized before app runs
  try {
    await bl.BackgroundLocator.initialize();
  } catch (e) {
    Logger().e("BackgroundLocator initialization failed: $e");
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final String SUPABASE_URL = EnvService().supabaseUrl;
  final String SUPABASE_ANON_KEY = EnvService().supabaseAnonKey;
  await Supabase.initialize(url: SUPABASE_URL, anonKey: SUPABASE_ANON_KEY).then(
    (_) {
      Logger().f("Supabase Initialized SuccessFully");
    },
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthDI.getAuthBloc()..add(const InitialAuthEvent()),
        ),
        BlocProvider(create: (context) => ActivitiesDI.getBloc()),
        BlocProvider(create: (context) => SocialDI.getBloc()),
        BlocProvider(create: (context) => SearchCubit()),
        // Tracking and Location providers (available app-wide for sync on reentry)
        BlocProvider(create: (_) => TrackingCubit()),
        BlocProvider(create: (_) => LocationCubit()),
      ],
      child: ReentryHandler(
        child: MaterialApp.router(
          title: 'Pace Mate',
          theme: AppTheme.dark(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}

class ReentryHandler extends StatefulWidget {
  const ReentryHandler({super.key, required this.child});
  final Widget child;

  @override
  State<ReentryHandler> createState() => _ReentryHandlerState();
}

class _ReentryHandlerState extends State<ReentryHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Register the named ReceivePort early so background isolate can find it
    try {
      context.read<LocationCubit>().ensureReady();
    } catch (_) {}
    _checkNotificationTapAndSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationTapAndSync();
    }
  }

  Future<void> _checkNotificationTapAndSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tapped = prefs.getBool(kNotifTapFlagKey) ?? false;
      // Always attempt to sync pending data at startup/resume
      final loc = context.read<LocationCubit>();
      final tracking = context.read<TrackingCubit>();
      await loc.syncOfflinePoints(tracking);
      if (tapped) {
        await prefs.setBool(kNotifTapFlagKey, false);
        // Navigate to home with Run tab index 2
        AppRouter.router.go('/home', extra: {'tab': 2});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
