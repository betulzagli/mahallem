import 'package:flutter/material.dart';

/// Butonun görsel hiyerarşisini ve tasarım stilini belirleyen tür enum'ı.
enum AppButtonType { primary, secondary, promotional, outlined, text }

/// WCAG AA kontrast kurallarına ve en az 48px dokunma hedefine uygun genel buton bileşeni.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.primary ? colorScheme.onPrimary : colorScheme.primary,
          ),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      child = Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final buttonStyle = switch (type) {
      AppButtonType.primary => ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      AppButtonType.secondary => ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.primary,
          minimumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      AppButtonType.promotional => ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          minimumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      AppButtonType.outlined => OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          minimumSize: Size(width ?? double.infinity, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      AppButtonType.text => TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: Size(width ?? 48, height),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
    };

    return SizedBox(
      width: width,
      height: height,
      child: switch (type) {
        AppButtonType.outlined => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          ),
        AppButtonType.text => TextButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          ),
        _ => ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          ),
      },
    );
  }
}

