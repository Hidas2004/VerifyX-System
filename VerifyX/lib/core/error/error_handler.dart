import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../constants/app_strings.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ERROR HANDLER - Centralized error handling
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Lợi ích:
/// - Xử lý errors tập trung
/// - User-friendly error messages
/// - Easy logging và monitoring
/// - Consistent error handling
/// 
/// Usage:
/// ```dart
/// try {
///   await someOperation();
/// } catch (e) {
///   final message = ErrorHandler.handle(e);
///   showSnackbar(message);
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  // ==================== MAIN HANDLER ====================
  
  /// Handle any error và trả về user-friendly message
  static String handle(dynamic error) {
    debugPrint('🔴 Error: $error');
    
    // Firebase Auth errors
    if (error is firebase_auth.FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    }
    
    // Firebase errors (generic)
    if (error is firebase_auth.FirebaseException) {
      return _handleFirebaseError(error);
    }
    
    // Network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException')) {
      return AppStrings.noInternet;
    }
    
    // Timeout errors
    if (error.toString().contains('TimeoutException')) {
      return 'Yêu cầu hết thời gian chờ, vui lòng thử lại';
    }
    
    // Generic error
    return AppStrings.somethingWentWrong;
  }

  // ==================== FIREBASE AUTH ERRORS ====================
  
  /// Handle Firebase Auth errors
  static String _handleFirebaseAuthError(firebase_auth.FirebaseAuthException error) {
    debugPrint('🔴 Firebase Auth Error: ${error.code}');
    
    switch (error.code) {
      // ==================== EMAIL/PASSWORD ====================
      case 'invalid-email':
        return AppStrings.emailInvalid;
      
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      
      case 'user-not-found':
        return 'Email không tồn tại trong hệ thống';
      
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      
      case 'weak-password':
        return AppStrings.passwordTooShort;
      
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt';
      
      // ==================== NETWORK ====================
      case 'network-request-failed':
        return AppStrings.noInternet;
      
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
      
      // ==================== TOKEN ====================
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ';
      
      case 'invalid-verification-code':
        return 'Mã xác thực không chính xác';
      
      case 'invalid-verification-id':
        return 'ID xác thực không hợp lệ';
      
      case 'expired-action-code':
        return 'Mã xác thực đã hết hạn';
      
      // ==================== SESSION ====================
      case 'user-token-expired':
        return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
      
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để tiếp tục';
      
      // ==================== ACCOUNT ====================
      case 'account-exists-with-different-credential':
        return 'Email đã được đăng ký bằng phương thức khác';
      
      case 'credential-already-in-use':
        return 'Thông tin đăng nhập đã được sử dụng';
      
      // ==================== DEFAULT ====================
      default:
        debugPrint('🔴 Unhandled Firebase Auth Error: ${error.code}');
        return error.message ?? AppStrings.somethingWentWrong;
    }
  }

  // ==================== FIREBASE ERRORS ====================
  
  /// Handle generic Firebase errors
  static String _handleFirebaseError(firebase_auth.FirebaseException error) {
    debugPrint('🔴 Firebase Error: ${error.code}');
    
    switch (error.code) {
      case 'permission-denied':
        return 'Bạn không có quyền thực hiện thao tác này';
      
      case 'unavailable':
        return 'Dịch vụ tạm thời không khả dụng';
      
      case 'not-found':
        return 'Không tìm thấy dữ liệu';
      
      case 'already-exists':
        return 'Dữ liệu đã tồn tại';
      
      case 'resource-exhausted':
        return 'Đã vượt quá giới hạn sử dụng';
      
      case 'cancelled':
        return 'Thao tác đã bị hủy';
      
      case 'deadline-exceeded':
        return 'Yêu cầu hết thời gian chờ';
      
      default:
        return error.message ?? AppStrings.somethingWentWrong;
    }
  }

  // ==================== CUSTOM ERROR TYPES ====================
  
  /// Check if error is network related
  static bool isNetworkError(dynamic error) {
    return error.toString().contains('SocketException') ||
        error.toString().contains('NetworkException') ||
        error.toString().contains('network-request-failed');
  }
  
  /// Check if error is authentication related
  static bool isAuthError(dynamic error) {
    return error is firebase_auth.FirebaseAuthException;
  }
  
  /// Check if error requires re-login
  static bool requiresReLogin(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      return error.code == 'user-token-expired' ||
          error.code == 'requires-recent-login';
    }
    return false;
  }

  // ==================== LOGGING ====================
  
  /// Log error to console (development) or monitoring service (production)
  static void log(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔴 ERROR LOG');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      debugPrint('═══════════════════════════════════════════════════════');
    } else {
      // TODO: Send to monitoring service (Sentry, Crashlytics, etc.)
      // Crashlytics.instance.recordError(error, stackTrace);
    }
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// APP EXCEPTION - Custom exception types
/// ═══════════════════════════════════════════════════════════════════════════
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  AppException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

/// Validation exception
class ValidationException extends AppException {
  ValidationException(String message) : super(message: message, code: 'validation-error');
}

/// Network exception
class NetworkException extends AppException {
  NetworkException([String? message])
      : super(
          message: message ?? AppStrings.noInternet,
          code: 'network-error',
        );
}

/// Auth exception
class AuthException extends AppException {
  AuthException(String message) : super(message: message, code: 'auth-error');
}

/// Server exception
class ServerException extends AppException {
  ServerException([String? message])
      : super(
          message: message ?? AppStrings.somethingWentWrong,
          code: 'server-error',
        );
}
