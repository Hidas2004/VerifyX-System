import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// EXTENSIONS - Các extension methods cho types có sẵn
/// ═══════════════════════════════════════════════════════════════════════════

// ==================== STRING EXTENSIONS ====================

extension StringExtensions on String {
  /// Kiểm tra string có phải email hợp lệ không
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }
  
  /// Kiểm tra string có phải số điện thoại VN hợp lệ không
  bool get isValidPhoneNumber {
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    return phoneRegex.hasMatch(this);
  }
  
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  /// Capitalize mỗi từ
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// Loại bỏ khoảng trắng thừa
  String get removeExtraSpaces {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

// ==================== DATETIME EXTENSIONS ====================

extension DateTimeExtensions on DateTime {
  /// Kiểm tra có phải hôm nay không
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Kiểm tra có phải hôm qua không
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }
  
  /// Lấy thời gian relative (vừa xong, 5 phút trước...)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${(difference.inDays / 7).floor()} tuần trước';
    }
  }
  
  /// Format thành "dd/MM/yyyy"
  String get formatted {
    final day = this.day.toString().padLeft(2, '0');
    final month = this.month.toString().padLeft(2, '0');
    final year = this.year.toString();
    return '$day/$month/$year';
  }
  
  /// Format thành "HH:mm"
  String get timeFormatted {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// ==================== BUILDCONTEXT EXTENSIONS ====================

extension ContextExtensions on BuildContext {
  /// Get MediaQuery size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Get screen width
  double get screenWidth => screenSize.width;
  
  /// Get screen height
  double get screenHeight => screenSize.height;
  
  /// Get Theme
  ThemeData get theme => Theme.of(this);
  
  /// Get ColorScheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Get TextTheme
  TextTheme get textTheme => theme.textTheme;
  
  /// Show SnackBar
  void showSnackBar(String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  /// Show Success SnackBar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.green);
  }
  
  /// Show Error SnackBar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: Colors.red);
  }
  
  /// Hide keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

// ==================== INT EXTENSIONS ====================

extension IntExtensions on int {
  /// Format với dấu phẩy
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  
  /// Format thành currency VNĐ
  String get toCurrency {
    return '$formatted đ';
  }
}

// ==================== DOUBLE EXTENSIONS ====================

extension DoubleExtensions on double {
  /// Format thành percentage
  String get toPercentage {
    return '${(this * 100).toStringAsFixed(0)}%';
  }
}
