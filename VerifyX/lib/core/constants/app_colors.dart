import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP COLORS - Cấu hình màu sắc toàn app
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Sử dụng:
/// ```dart
/// Container(color: AppColors.primary)
/// ```
class AppColors {
  // Private constructor để ngăn instantiation
  AppColors._();

  // ==================== BRAND COLORS ====================
  
  /// Màu chủ đạo - Cyan (#00BCD4)
  /// Dùng cho: AppBar, Button chính, Icon active
  static const Color primary = Color(0xFF00BCD4);
  
  /// Màu phụ - Cyan nhạt (#4DD0E1)
  /// Dùng cho: Gradient, Accent, Highlight
  static const Color secondary = Color(0xFF4DD0E1);

  // ==================== SEMANTIC COLORS ====================
  
  /// Màu thành công - Xanh lá (#4CAF50)
  /// Dùng cho: Success message, Status "Chính hãng"
  static const Color success = Color(0xFF4CAF50);
  
  /// Màu cảnh báo - Cam (#FF9800)
  /// Dùng cho: Warning message, Status "Cần kiểm tra"
  static const Color warning = Color(0xFFFF9800);
  
  /// Màu lỗi - Đỏ (#F44336)
  /// Dùng cho: Error message, Status "Nghi ngờ giả"
  static const Color error = Color(0xFFF44336);
  
  /// Màu thông tin - Xanh dương (#2196F3)
  /// Dùng cho: Info message, Link
  static const Color info = Color(0xFF2196F3);

  // ==================== NEUTRAL COLORS ====================
  
  /// Màu nền chính
  static const Color background = Colors.white;
  
  /// Màu nền phụ (Surface)
  static const Color surface = Color(0xFFF5F5F5);
  
  /// Màu text chính
  static const Color textPrimary = Color(0xFF212121);
  
  /// Màu text phụ
  static const Color textSecondary = Color(0xFF757575);
  
  /// Màu text disabled
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  /// Màu divider/border
  static const Color divider = Color(0xFFE0E0E0);

  // ==================== GRADIENT ====================
  
  /// Gradient chính (Primary → Secondary)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gradient nền nhạt
  static LinearGradient lightGradient = LinearGradient(
    colors: [
      primary.withValues(alpha: 0.1),
      secondary.withValues(alpha: 0.05),
      Colors.white,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
