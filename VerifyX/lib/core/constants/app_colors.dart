import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===========================================================================
  // 1. MÀU CŨ CỦA APP (GIỮ NGUYÊN ĐỂ KHÔNG LỖI APP)
  // ===========================================================================
  static const Color primary = Color(0xFF00BCD4); // Cyan
  static const Color secondary = Color(0xFF4DD0E1);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFE0E0E0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient lightGradient = LinearGradient(
    colors: [primary.withOpacity(0.1), secondary.withOpacity(0.05), Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ===========================================================================
  // 2. MÀU MỚI CHO ADMIN (TAILADMIN STYLE)
  // ===========================================================================
  
  // Nền & Card
  static const Color adminBackground = Color(0xFFF1F5F9); // Xám xanh nhạt (Chuẩn TailAdmin)
  static const Color adminSurface = Colors.white;         // Trắng tinh
  static const Color adminBorder = Color(0xFFE2E8F0);     // Viền nhạt
  
  // Chữ
  static const Color adminTextPrimary = Color(0xFF1C2434); // Đen xám đậm
  static const Color adminTextSecondary = Color(0xFF64748B); // Xám vừa
  static const Color adminIcon = Color(0xFF637381);       // Icon xám
  
  // Màu KPI & Trạng thái
  static const Color kpiBlue = Color(0xFF3C50E0);    // Brand (Xanh dương)
  static const Color kpiOrange = Color(0xFFFFA70B);  // Batch (Vàng cam)
  static const Color kpiPurple = Color(0xFF8E24AA);  // Transaction (Tím)
  static const Color kpiRed = Color(0xFFD34053);     // Fake Alert (Đỏ)
  
  static const Color adminSuccess = Color(0xFF219653); // Xanh lá
}