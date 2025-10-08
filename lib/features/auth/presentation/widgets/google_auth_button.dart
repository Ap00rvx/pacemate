import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/web.dart';
import 'package:pacemate/core/env/env_service.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class GoogleButton extends StatefulWidget {
  const GoogleButton({super.key});

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  final supabase = Supabase.instance.client;

  Future<void> _googleSignIn(BuildContext ctx) async {
    final webClientId = EnvService().webClientId;
    final androidClientId = EnvService().androidClientId;

    final GoogleSignIn signIn = GoogleSignIn.instance;

    // At the start of your app, initialize the GoogleSignIn instance
    unawaited(
      signIn.initialize(clientId: androidClientId, serverClientId: webClientId),
    );

    // Perform the sign in
    final googleAccount = await signIn.authenticate();
    final googleAuthorization = await googleAccount.authorizationClient
        .authorizationForScopes(['email']);
    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;
    final accessToken = googleAuthorization?.accessToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }
    final response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    if (response.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in failed: No user Logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final user = response.user!;
    final email = user.email ?? '';
    final googleId = user.id;

    ctx.read<AuthBloc>().add(
      GoogleCheckEvent(email: email, googleId: googleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
        if (state.status == AuthStatus.authenticated && state.user != null) {
          AppRouter.go(RouteNames().home, context);
        }
        if (state.status == AuthStatus.googleSignupRequired &&
            state.googleSignupData != null) {
          final data = state.googleSignupData!;
          final email = data.email;
          final googleId = data.googleId;
          final fullName =
              supabase.auth.currentUser?.userMetadata?['full_name'] ?? "";
          final avatarUrl =
              supabase.auth.currentUser?.userMetadata?['avatar_url'] ?? "";
          AppRouter.push(
            RouteNames().signupDetails,
            context,
            queryParams: {
              'email': email,
              'googleId': googleId,
              if (fullName != null && fullName.isNotEmpty) 'name': fullName,
              if (avatarUrl != null && avatarUrl.isNotEmpty)
                'avatarUrl': avatarUrl,
            },
          );
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await _googleSignIn(context);
              } catch (e) {
                Logger().e('Google sign-in error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Google sign-in failed: $e'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: state.status == AuthStatus.loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text('Continue with Google'),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
