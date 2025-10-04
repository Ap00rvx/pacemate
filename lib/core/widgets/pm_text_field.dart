import 'package:flutter/material.dart';

/// A reusable text field that respects the app's InputDecorationTheme
/// and provides optional password visibility toggle and validation.
class PMTextField extends StatefulWidget {
  const PMTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
    this.isPassword = false,
    this.autofillHints,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final bool enabled;
  final bool isPassword;
  final Iterable<String>? autofillHints;

  @override
  State<PMTextField> createState() => _PMTextFieldState();
}

class _PMTextFieldState extends State<PMTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final suffix = widget.isPassword
        ? IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          )
        : widget.suffixIcon;

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      obscureText: _obscure,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: suffix,
      ),
    );
  }
}
