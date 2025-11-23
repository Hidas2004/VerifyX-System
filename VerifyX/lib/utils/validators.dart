import '../core/constants/app_strings.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VALIDATORS - Các hàm validate input
/// ═══════════════════════════════════════════════════════════════════════════
class Validators {
  Validators._();

  // ==================== EMAIL ====================
  
  /// Validate email
  /// 
  /// Trả về:
  /// - `null` nếu hợp lệ
  /// - Error message nếu không hợp lệ
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }
    
    // Regex kiểm tra định dạng email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailInvalid;
    }
    
    return null;
  }

  // ==================== PASSWORD ====================
  
  /// Validate password
  /// 
  /// Yêu cầu:
  /// - Không được trống
  /// - Ít nhất 6 ký tự
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    
    return null;
  }
  
  /// Validate confirm password
  /// 
  /// [password] - Mật khẩu gốc
  /// [confirmPassword] - Mật khẩu xác nhận
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return AppStrings.passwordRequired;
    }
    
    if (password != confirmPassword) {
      return AppStrings.passwordNotMatch;
    }
    
    return null;
  }

  // ==================== NAME ====================
  
  /// Validate display name
  /// 
  /// Yêu cầu:
  /// - Không được trống
  /// - Ít nhất 2 ký tự
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.nameRequired;
    }
    
    if (value.trim().length < 2) {
      return AppStrings.nameTooShort;
    }
    
    return null;
  }

  // ==================== PHONE ====================
  
  /// Validate phone number (Vietnam)
  /// 
  /// Format: 0xxxxxxxxx (10 số)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    
    // Regex cho số điện thoại Việt Nam
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    
    return null;
  }

  // ==================== REQUIRED ====================
  
  /// Validate required field (generic)
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null 
          ? 'Vui lòng nhập $fieldName'
          : 'Trường này không được để trống';
    }
    return null;
  }

  // ==================== MIN LENGTH ====================
  
  /// Validate minimum length
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? 'Vui lòng nhập $fieldName'
          : 'Trường này không được để trống';
    }
    
    if (value.length < min) {
      return fieldName != null
          ? '$fieldName phải có ít nhất $min ký tự'
          : 'Phải có ít nhất $min ký tự';
    }
    
    return null;
  }

  // ==================== MAX LENGTH ====================
  
  /// Validate maximum length
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return fieldName != null
          ? '$fieldName không được vượt quá $max ký tự'
          : 'Không được vượt quá $max ký tự';
    }
    return null;
  }
}
