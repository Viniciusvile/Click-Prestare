import 'package:click/theme/app_colors.dart';
import 'package:click/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TextFieldDefault extends StatefulWidget {
  const TextFieldDefault({
    Key? key,
    required this.title,
    this.isPassword,
    this.keyboard,
    this.mask,
    this.controller,
    this.placeholder,
    this.enabled,
    this.textCapitalization,
    this.fontSize,
  }) : super(key: key);

  final String title;
  final bool? isPassword;
  final TextInputType? keyboard;
  final TextInputFormatter? mask;
  final TextEditingController? controller;
  final String? placeholder;
  final bool? enabled;
  final TextCapitalization? textCapitalization;
  final double? fontSize;

  @override
  _TextFieldDefaultState createState() => _TextFieldDefaultState();
}

class _TextFieldDefaultState extends State<TextFieldDefault> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isPwd = widget.isPassword == true;
    return TextField(
      enabled: widget.enabled ?? true,
      textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
      controller: widget.controller,
      obscureText: isPwd && _obscure,
      keyboardType: widget.keyboard ?? TextInputType.text,
      maxLines: isPwd ? 1 : 1,
      inputFormatters: widget.mask != null ? [widget.mask!] : [],
      cursorColor: AppColors.primary,
      style: AppTypography.body(context).copyWith(
        fontSize: widget.fontSize ?? 16,
      ),
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: AppTypography.body(context).copyWith(
          color: AppColors.textTertiary(context),
          fontSize: 14,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: widget.title,
        labelStyle: AppTypography.caption(context).copyWith(
          color: AppColors.textSecondary(context),
        ),
        floatingLabelStyle: AppTypography.captionMedium(context).copyWith(
          color: AppColors.primary,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: isPwd
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? PhosphorIcons.eye : PhosphorIcons.eyeSlash,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}
