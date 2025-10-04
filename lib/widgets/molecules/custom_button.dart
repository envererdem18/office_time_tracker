import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isEnabled;
  final bool isLoading;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isEnabled = true,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = !isEnabled || isLoading || onPressed == null;

    return SizedBox(
      width: width,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppTheme.disabledColor
              : backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: isDisabled ? 0 : 2,
          shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(
                    text,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}

// Check-in ve Check-out için özel butonlar (Long Press ile çalışır)
class CheckInButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  const CheckInButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        !widget.isEnabled || widget.isLoading || widget.onPressed == null;

    return GestureDetector(
      onLongPress: isDisabled ? null : widget.onPressed,
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: isDisabled
              ? AppTheme.disabledColor
              : _isPressed
              ? AppTheme.checkInColor.withValues(alpha: 0.8)
              : AppTheme.checkInColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled || _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.checkInColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: widget.isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Basılı tutun',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class CheckOutButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  const CheckOutButton({
    super.key,
    this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  State<CheckOutButton> createState() => _CheckOutButtonState();
}

class _CheckOutButtonState extends State<CheckOutButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        !widget.isEnabled || widget.isLoading || widget.onPressed == null;

    return GestureDetector(
      onLongPress: isDisabled ? null : widget.onPressed,
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: isDisabled
              ? AppTheme.disabledColor
              : _isPressed
              ? AppTheme.checkOutColor.withValues(alpha: 0.8)
              : AppTheme.checkOutColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled || _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.checkOutColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: widget.isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Çıkış Yap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Basılı tutun',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

// Floating Action Button alternatifi
class CustomFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final String? tooltip;

  const CustomFloatingButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      tooltip: tooltip,
      child: Icon(icon, size: 28),
    );
  }
}
