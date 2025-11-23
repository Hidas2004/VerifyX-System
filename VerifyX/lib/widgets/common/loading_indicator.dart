import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOADING INDICATOR - Hiển thị loading state
/// ═══════════════════════════════════════════════════════════════════════════
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;
  final double? size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSizes.paddingMD),
            Text(
              message!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSM,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// LOADING OVERLAY - Full screen loading với backdrop
/// ═══════════════════════════════════════════════════════════════════════════
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: LoadingIndicator(message: message),
          ),
      ],
    );
  }
}
