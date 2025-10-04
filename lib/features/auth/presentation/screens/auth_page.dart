import 'package:flutter/material.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/widgets/logo_place.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _routes = RouteNames();
  void _onGooglePressed() {
    // TODO: Wire up Google Sign-In logic
    // e.g., context.read<AuthCubit>().signInWithGoogle();
    debugPrint('Google sign-in tapped');
    // For now, just navigate to home
    AppRouter.go(_routes.home, context);
  }

  void _onEmailSignup() {
    // Navigate to email sign up
    AppRouter.push(_routes.signup, context);
  }

  void _onSignin() {
    AppRouter.push(_routes.signin, context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  _GoogleButton(onPressed: _onGooglePressed),

                  // Email sign up
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _onEmailSignup,
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
                        onPressed: _onSignin,
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
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple placeholder Google "G" mark inside a white square
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Text(
                'G',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4285F4), // Google Blue
                ),
              ),
            ),
            const Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}
