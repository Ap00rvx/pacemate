import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/widgets/app_loader.dart';
import 'package:pacemate/core/widgets/pm_text_field.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement sign-in
      debugPrint('Signing in as ${_emailCtrl.text}');
      context.read<AuthBloc>().add(
        LoginEvent(email: _emailCtrl.text.trim(), password: _passCtrl.text),
      );
    }
  }

  void _google() {
    // TODO: Implement Google sign-in
    debugPrint('Google sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state.status == AuthStatus.authenticated) {
            AppRouter.go(RouteNames().home, context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome Back! ${state.user?.fullname}')),
            );
          }
        },
        builder: (BuildContext context, AuthState state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back', style: theme.textTheme.displayMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to continue',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    PMTextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    PMTextField(
                      controller: _passCtrl,
                      isPassword: true,
                      label: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Enter your password';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot password?'),
                      ),
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: state.status == AuthStatus.loading
                              ? AppLoader()
                              : Text('Sign in'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Divider(color: cs.outline)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider(color: cs.outline)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _google,
                        icon: Image.asset(
                          "assets/images/google.png",
                          width: 20,
                          height: 20,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cs.outline),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        label: const Text('Continue with Google'),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => AppRouter.pushReplacement(
                            RouteNames().signup,
                            context,
                          ),
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
