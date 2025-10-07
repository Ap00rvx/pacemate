import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/widgets/logo_place.dart';
import '../bloc/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _routes = RouteNames();
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            // Navigate to home page
            AppRouter.go(_routes.home, context);
            break;
          case AuthStatus.googleSignupRequired:
            // Navigate to signup details with prefilled Google data
            final data = state.googleSignupData!;
            final user = FirebaseAuth.instance.currentUser;
            final params = <String, String>{
              'email': data.email,
              'googleId': data.googleId,
            };
            if (user?.displayName != null && user!.displayName!.isNotEmpty) {
              params['name'] = user.displayName!;
            }
            if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
              params['avatarUrl'] = user.photoURL!;
            }
            AppRouter.push(_routes.signupDetails, context, queryParams: params);
            break;
          case AuthStatus.error:
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Authentication failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            break;
          default:
            break;
        }
      },
      child: const _AuthPageView(),
    );
  }
}

class _AuthPageView extends StatefulWidget {
  const _AuthPageView();

  @override
  State<_AuthPageView> createState() => _AuthPageViewState();
}

class _AuthPageViewState extends State<_AuthPageView> {
  final _routes = RouteNames();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId:
        "805163956327-po8rpa88oji5lsldhvj8fl42b85fia25.apps.googleusercontent.com",
  );

  Future<void> _onGooglePressed() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn().onError((
        error,
        stackTrace,
      ) {
        Logger().e('Google sign-in error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google sign-in failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return null;
      });
      print('Google user: ${gUser?.email}, ${gUser?.id}');
      if (gUser == null) return; // canceled
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      final UserCredential userCred = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final user = userCred.user;
      if (!mounted || user == null) return;

      String? googleId;
      for (final p in user.providerData) {
        if (p.providerId == 'google.com') {
          googleId = p.uid;
          break;
        }
      }
      googleId ??= gUser.id;

      final email = user.email ?? gUser.email;

      context.read<AuthBloc>().add(
        GoogleCheckEvent(googleId: googleId, email: email),
      );
    } catch (e) {
      try {
        await FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();
      } catch (_) {}
      if (!mounted) return;
      Logger().e('Firebase Google sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Google sign-in failed. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _onEmailSignup() {
    AppRouter.push(_routes.signup, context);
  }

  void _onSignin() {
    AppRouter.push(_routes.signin, context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Optional background image with dark overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/pacemate_theme_bg.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.15,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    spacing: 14,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      AppLogo(),

                      Text(
                        "Sign In Yourself to begin the ultimate running journey",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                    

                      // Email sign up
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : _onEmailSignup,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: cs.primary),
                          ),
                          child: const Text('Sign up with Email'),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: state.status == AuthStatus.loading
                                ? null
                                : _onSignin,
                            child: const Text('Sign in'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
