import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TextFieldRounded extends StatefulWidget {
  const TextFieldRounded({
    Key? key,
    required this.title,
    required this.isPassword,
    this.controller,
  }) : super(key: key);

  final String title;
  final bool isPassword;
  final TextEditingController? controller;

  @override
  _TextFieldRoundedState createState() => _TextFieldRoundedState();
}

class _TextFieldRoundedState extends State<TextFieldRounded> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      cursorColor: AppColors.primary,
      style: AppTypography.body(context),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: AppColors.surface(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelText: widget.title,
        labelStyle: AppTypography.body(context).copyWith(
          color: AppColors.textSecondary(context),
        ),
        floatingLabelStyle: AppTypography.captionMedium(context).copyWith(
          color: AppColors.primary,
        ),
        hintText: !widget.isPassword ? 'e-mail@click.com' : '********',
        hintStyle: AppTypography.body(context).copyWith(
          color: AppColors.textTertiary(context),
        ),
        prefixIcon: Icon(
          widget.isPassword ? PhosphorIcons.lock : PhosphorIcons.envelope,
          color: AppColors.textSecondary(context),
          size: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? PhosphorIcons.eye : PhosphorIcons.eyeSlash,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 48),
      ),
    );
  }
}
