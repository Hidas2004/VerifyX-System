import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CUSTOM BUTTON - Nút bấm tùy chỉnh
/// ═══════════════════════════════════════════════════════════════════════════
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? height;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final btnBackgroundColor = backgroundColor ?? AppColors.primary;
    final btnTextColor = textColor ?? Colors.white;
    final btnHeight = height ?? AppSizes.buttonHeight;
    final btnBorderRadius = borderRadius ?? AppSizes.radiusMD;

    // Nếu có gradient background
    if (backgroundColor == null) {
      return Container(
        width: isFullWidth ? double.infinity : null,
        height: btnHeight,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(btnBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(btnBorderRadius),
            ),
          ),
          child: _buildButtonContent(btnTextColor),
        ),
      );
    }

    // Nút thông thường
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: btnHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnBackgroundColor,
          foregroundColor: btnTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(btnBorderRadius),
          ),
        ),
        child: _buildButtonContent(btnTextColor),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSM),
          const SizedBox(width: AppSizes.paddingSM),
          Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontMD,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: AppSizes.fontMD,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// OUTLINE BUTTON - Nút có viền
/// ═══════════════════════════════════════════════════════════════════════════
class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;
  final double? height;

  const CustomOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderColor,
    this.textColor,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final btnBorderColor = borderColor ?? AppColors.primary;
    final btnTextColor = textColor ?? AppColors.primary;
    final btnHeight = height ?? AppSizes.buttonHeight;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: btnHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: btnTextColor,
          side: BorderSide(color: btnBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(btnTextColor),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: AppSizes.iconSM),
                      const SizedBox(width: AppSizes.paddingSM),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: AppSizes.fontMD,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppSizes.fontMD,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      ),
    );
  }
}
