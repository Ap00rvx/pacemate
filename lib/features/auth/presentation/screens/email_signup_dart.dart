import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:pacemate/core/router/app_router.dart';
import 'package:pacemate/core/router/route_names.dart';
import 'package:pacemate/core/widgets/app_loader.dart';
import 'package:pacemate/core/widgets/pm_text_field.dart';
import 'package:pacemate/features/auth/presentation/bloc/auth_bloc.dart';

class EmailSignupPage extends StatefulWidget {
  const EmailSignupPage({super.key});

  @override
  State<EmailSignupPage> createState() => _EmailSignupPageState();
}

class _EmailSignupPageState extends State<EmailSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _accept = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !_accept) return;
    context.read<AuthBloc>().add(
      CheckEmailExistsEvent(email: _emailCtrl.text.trim()),
    );
  }

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state.emailExists == false) {
          logger.t(
            'Email does not exist, proceed with signup for ${state.message}',
          );
          AppRouter.push(
            RouteNames().signupDetails,
            context,
            queryParams: {
              'name': _nameCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'password': _passCtrl.text,
            },
          );
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Create account')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join Pace Mate',
                      style: theme.textTheme.displayMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let\'s get started',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    PMTextField(
                      controller: _nameCtrl,
                      label: 'Full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),

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
                        if (v == null || v.isEmpty) return 'Enter a password';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    PMTextField(
                      controller: _confirmCtrl,
                      isPassword: true,
                      label: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (v) =>
                          v != _passCtrl.text ? 'Passwords do not match' : null,
                    ),

                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _accept,
                          onChanged: (v) =>
                              setState(() => _accept = v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms & Privacy Policy',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _accept ? _submit : null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: state.status == AuthStatus.loading
                              ? const AppLoader()
                              : Text('Create account'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => AppRouter.pushReplacement(
                            RouteNames().signin,
                            context,
                          ),
                          child: const Text('Sign in'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
