import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pacemate/core/theme/app_theme.dart';
import 'package:pacemate/core/widgets/pm_text_field.dart';
import 'package:geocoding/geocoding.dart' as gc;

import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/auth_requests.dart';
import '../bloc/auth_bloc.dart';
import '../../../tracking/presentation/bloc/location_cubit.dart';

class SignUpDetailsPage extends StatefulWidget {
  const SignUpDetailsPage({
    super.key,
    this.email,
    this.googleId,
    this.password,
    this.avatarUrl,
    this.displayName,
  });

  final String? email;
  final String? googleId;
  final String? avatarUrl;
  final String? password;
  final String? displayName;

  @override
  State<SignUpDetailsPage> createState() => _SignUpDetailsPageState();
}

class _SignUpDetailsPageState extends State<SignUpDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  // Wheel picker selections
  int _heightCm = 170; // 100 - 250
  int _weightKg = 70; // 30 - 300

  DateTime? _dob;
  String _gender = 'male';
  int _currentStep =
      0; // 0: name/email, 1: dob/age/gender, 2: height/weight, 3: location
  bool _locLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.displayName != null) _fullnameCtrl.text = widget.displayName!;
    if (widget.email != null) _emailCtrl.text = widget.email!;
    if (widget.password != null) _passwordCtrl.text = widget.password!;
    // Fetch location automatically
    _prefetchLocation();
  }

  @override
  void dispose() {
    _fullnameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _locationCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _prefetchLocation() async {
    setState(() => _locLoading = true);
    final cubit = LocationCubit();
    final pos = await cubit.getCurrentPosition();
    if (pos != null) {
      try {
        final placemarks = await gc.placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final locality = [p.locality, p.subLocality].where((e) => (e ?? '').isNotEmpty).join(', ');
          final admin = [p.administrativeArea, p.subAdministrativeArea].where((e) => (e ?? '').isNotEmpty).join(', ');
          final country = p.country ?? '';
          final composed = [locality, admin, country].where((e) => e.isNotEmpty).join(', ');
          _locationCtrl.text = composed.isNotEmpty ? composed : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        } else {
          _locationCtrl.text = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        }
      } catch (_) {
        _locationCtrl.text = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      }
    }
    if (mounted) setState(() => _locLoading = false);
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 25, now.month, now.day);
    final first = DateTime(now.year - 100);
    final last = DateTime(now.year - 13, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        final age = _yearsBetween(picked, DateTime.now());
        _ageCtrl.text = age.toString();
      });
    }
  }

  int _yearsBetween(DateTime from, DateTime to) {
    int years = to.year - from.year;
    if (to.month < from.month ||
        (to.month == from.month && to.day < from.day)) {
      years--;
    }
    return years;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick your date of birth')),
      );
      return;
    }

    // Calculate values
    final age = _yearsBetween(_dob!, DateTime.now());
    final height = _heightCm.toDouble();
    final weight = _weightKg.toDouble();

    final bloc = context.read<AuthBloc>();
    final isGoogleFlow = widget.googleId != null;

    if (isGoogleFlow) {
      bloc.add(
        GoogleSignupEvent(
          googleId: widget.googleId!,
          email: _emailCtrl.text.trim(),
          fullname: _fullnameCtrl.text.trim(),
          avatar: widget.avatarUrl,
          dob: _dob?.toIso8601String() ?? '',
          gender: _gender,
          age: age,
          height: height,
          weight: weight,
          location: _locationCtrl.text.trim().isEmpty
              ? null
              : _locationCtrl.text.trim(),
        ),
      );
    } else {
      bloc.add(
        SignupEvent(
          fullname: _fullnameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          dob: _dob?.toIso8601String() ?? '',
          gender: _gender,
          age: age,
          height: height,
          weight: weight,
          location: _locationCtrl.text.trim().isEmpty
              ? null
              : _locationCtrl.text.trim(),
          avatar: null,
        ),
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    final cubit = LocationCubit();
    final pos = await cubit.getCurrentPosition();
    if (pos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enable location permission and services')),
        );
      }
      return;
    }
    try {
      final placemarks = await gc.placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final locality = [p.locality, p.subLocality].where((e) => (e ?? '').isNotEmpty).join(', ');
        final admin = [p.administrativeArea, p.subAdministrativeArea].where((e) => (e ?? '').isNotEmpty).join(', ');
        final country = p.country ?? '';
        final composed = [locality, admin, country].where((e) => e.isNotEmpty).join(', ');
        setState(() => _locationCtrl.text = composed.isNotEmpty ? composed : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
      } else {
        setState(() => _locationCtrl.text = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
      }
    } catch (_) {
      setState(() => _locationCtrl.text = '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}');
    }
  }

  Future<void> _showNumberPicker({
    required String title,
    required int min,
    required int max,
    required int initial,
    required String unit,
    required ValueChanged<int> onSelected,
  }) async {
    int tempIndex = (initial - min).clamp(0, max - min);
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final value = min + tempIndex;
                          onSelected(value);
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 36,
                          scrollController: FixedExtentScrollController(
                            initialItem: tempIndex,
                          ),
                          onSelectedItemChanged: (i) => tempIndex = i,
                          children: [
                            for (int v = min; v <= max; v++)
                              Center(child: Text('$v')),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          unit,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routes = RouteNames();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          // Navigate to home on success
          AppRouter.go(routes.home, context);
        } else if (state.status == AuthStatus.error && state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Complete your details')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Step indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _StepIndicator(current: _currentStep, total: 4),
                ),
                const SizedBox(height: 8),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildStepCard(context),
                  ),
                ),

                // Navigation
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _goBack,
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == AuthStatus.loading;
                            final isLast = _currentStep == 3;
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : (isLast ? _submit : _goNext),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(isLast ? 'Finish' : 'Next'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build current step card
  Widget _buildStepCard(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _stepNameEmail(context);
      case 1:
        return _stepDobGender(context);
      case 2:
        return _stepHeightWeight(context);
      case 3:
      default:
        return _stepLocation(context);
    }
  }

  Widget _stepNameEmail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's us know you better",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.muted,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Signing you up with ${widget.email}",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 20),
          PMTextField(
            controller: _fullnameCtrl,
            label: 'Full name',
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          Text(
            "We'll use this name in the app",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
          const SizedBox(height: 1),
          //
          if (widget.googleId == null &&
              (widget.password == null || widget.password!.isEmpty)) ...[
            const SizedBox(height: 12),
            PMTextField(
              controller: _passwordCtrl,
              isPassword: true,
              label: 'Password',
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepDobGender(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickDob,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dob == null
                        ? 'Tap to pick'
                        : DateFormat('dd MMM yyyy').format(_dob!),
                  ),
                  if (_dob != null)
                    Chip(
                      label: Text(
                        '${_yearsBetween(_dob!, DateTime.now())} yrs',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _gender = v ?? 'male'),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _ageCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Age (auto)'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "We'll use your date of birth to calculate your age",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _stepHeightWeight(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showNumberPicker(
              title: 'Select Height',
              min: 100,
              max: 250,
              initial: _heightCm,
              unit: 'cm',
              onSelected: (v) => setState(() => _heightCm = v),
            ),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Height',
                border: OutlineInputBorder(),
              ),
              child: Text('$_heightCm cm'),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showNumberPicker(
              title: 'Select Weight',
              min: 30,
              max: 300,
              initial: _weightKg,
              unit: 'kg',
              onSelected: (v) => setState(() => _weightKg = v),
            ),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
              child: Text('$_weightKg kg'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "We'll use these to estimate calories burned",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  Widget _stepLocation(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _locLoading ? null : _useCurrentLocation,
              icon: _locLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Use my location'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: cs.outlineVariant)),
              Text(
                ' or ',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
              ),
              Expanded(child: Divider(color: cs.outlineVariant)),
            ],
          ),
          const SizedBox(height: 20),
          PMTextField(
            controller: _locationCtrl,
            label: 'Location',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          Text(
            "This will help others find you in the app",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
          ),
        ],
      ),
    );
  }

  void _goNext() {
    if (_currentStep == 0) {
      // Validate name/email/password (when required)
      final needsPassword =
          widget.googleId == null &&
          (widget.password == null || widget.password!.isEmpty);
      final ok =
          (_fullnameCtrl.text.trim().isNotEmpty) &&
          RegExp(
            r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}",
          ).hasMatch(_emailCtrl.text.trim()) &&
          (!needsPassword || _passwordCtrl.text.length >= 6);
      if (!ok) {
        _formKey.currentState?.validate();
        return;
      }
    }
    if (_currentStep == 1) {
      if (_dob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick your date of birth')),
        );
        return;
      } else {
        _ageCtrl.text = _yearsBetween(_dob!, DateTime.now()).toString();
      }
    }
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (int i = 0; i < total; i++) ...[
          Expanded(
            child: Row(
              children: [
                _Dot(active: i <= current),
                if (i < total - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < current ? cs.primary : cs.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: active ? cs.primary : cs.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? cs.primary : cs.outlineVariant),
      ),
    );
  }
}
