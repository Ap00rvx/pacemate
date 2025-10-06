import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/widgets/logo_place.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final DateTime _startAt;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // 🎬 Setup animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // smooth pop effect
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // Start both animations
    _controller.forward();
    _startAt = DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (_navigated) return;
          // Ensure splash stays visible for at least 1200ms
          final minDuration = const Duration(milliseconds: 1200);
          final elapsed = DateTime.now().difference(_startAt);
          final wait = elapsed >= minDuration
              ? Duration.zero
              : minDuration - elapsed;

          if (state.status == AuthStatus.authenticated) {
            _navigated = true;
            await Future.delayed(wait);
            if (mounted) AppRouter.go(RouteNames().home, context);
          } else if (state.status == AuthStatus.unauthenticated) {
            _navigated = true;
            await Future.delayed(wait);
            if (mounted) AppRouter.go(RouteNames().onboarding, context);
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const AppLogo(),
            ),
          ),
        ),
      ),
    );
  }
}
