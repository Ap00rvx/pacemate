import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/transitions/page_transition.dart';
import 'package:pacemate/features/auth/presentation/screens/auth_page.dart';
import 'package:pacemate/features/auth/presentation/screens/signin_page.dart';
import 'package:pacemate/features/auth/presentation/screens/email_signup_dart.dart';
import 'package:pacemate/features/onboarding/presentation/onboarding.dart';
import 'package:pacemate/features/splash/presentation/splash.dart';

class AppRouter {
  static final _routeNames = RouteNames();
  static final GoRouter router = GoRouter(
    initialLocation: _routeNames.init,
    routes: [
      GoRoute(
        path: _routeNames.init,
        name: "splash",
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: _routeNames.onboarding,
        name: "onboarding",
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingPage(),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      // GoRoute(
      //   path: _routeNames.home,
      //   builder: (context, state) => const HomePage(),
      // ),
      GoRoute(
        path: _routeNames.auth,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AuthPage(),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: _routeNames.signin,
        name: 'signin',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SignInPage(),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: _routeNames.signup,
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const EmailSignupPage(),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
    ],
  );

  static void go(String routeName, BuildContext context) {
    context.go(routeName);
  }

  static void push(String routeName, BuildContext context) {
    context.push(routeName);
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static void pushReplacement(String routeName, BuildContext context) {
    context.pushReplacement(routeName);
  }
}
