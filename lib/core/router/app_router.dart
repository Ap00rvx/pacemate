import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/transitions/page_transition.dart';
import 'package:pacemate/features/auth/presentation/screens/auth_page.dart';
import 'package:pacemate/features/auth/presentation/screens/sign_up_details.dart';
import 'package:pacemate/features/auth/presentation/screens/signin_page.dart';
import 'package:pacemate/features/auth/presentation/screens/email_signup_dart.dart';
import 'package:pacemate/features/onboarding/presentation/onboarding.dart';
import 'package:pacemate/features/splash/presentation/splash.dart';
import 'package:pacemate/features/home/presentation/screens/home_page.dart';
import 'package:pacemate/features/activities/presentation/screens/activity_detail_page.dart';

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

      GoRoute(
        path: _routeNames.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
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
      GoRoute(
        path: _routeNames.signupDetails,
        name: 'signupDetails',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: SignUpDetailsPage(
            email: (state.extra as Map?)?['email'],
            password: (state.extra as Map?)?['password'],
            displayName: (state.extra as Map?)?['name'],
            googleId: (state.extra as Map?)?['googleId'],
            avatarUrl: (state.extra as Map?)?['avatarUrl'],
          ),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: _routeNames.activityDetail,
        name: 'activityDetail',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: ActivityDetailPage(activityId: (state.extra as Map?)?['id']),
          transitionsBuilder: defaultPageTransition,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
    ],
  );

  static void go(
    String routeName,
    BuildContext context, {
    Map<String, String>? queryParams,
  }) {
    context.go(routeName, extra: queryParams);
  }

  static void push(
    String routeName,
    BuildContext context, {
    Map<String, String>? queryParams,
  }) {
    context.push(routeName, extra: queryParams);
  }

  static void pop(BuildContext context) {
    context.pop();
  }

  static void pushReplacement(
    String routeName,
    BuildContext context, {
    Map<String, String>? queryParams,
  }) {
    context.pushReplacement(routeName, extra: queryParams);
  }
}
