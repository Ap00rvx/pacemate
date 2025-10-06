import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/features/activities/activities_di.dart';
import 'package:pacemate/features/auth/auth_di.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pacemate/firebase_options.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthDI.getAuthBloc()..add(const InitialAuthEvent()),
        ),
        BlocProvider(
          create: (context) => ActivitiesDI.getBloc(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Pace Mate',
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
