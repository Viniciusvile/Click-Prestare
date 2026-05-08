import 'package:flutter/material.dart';

class AlternativeButton extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final String? subtitle;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const AlternativeButton({
    Key? key,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.onPressed,
    this.buttonStyle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    ButtonStyle btnStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.primaryColor,
      padding: EdgeInsets.all(15),
      alignment: Alignment.center,
      minimumSize: Size(double.infinity, 30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      side: borderColor != null ? BorderSide(width: 3.0, color: borderColor!) : null
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: btnStyle.merge(buttonStyle),
      child: Column(
        children: [
          FittedBox(
            child: titleWidget ??
                Text(                  
                  title,
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.merge(
                    TextStyle(color: textColor ?? Colors.white),
                  ),
                ),
          ),
          if (subtitle != null)
            FittedBox(
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.merge(
                  TextStyle(color: textColor ?? Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
