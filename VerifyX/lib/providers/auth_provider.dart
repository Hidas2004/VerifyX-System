// NỘI DUNG ĐẦY ĐỦ CHO: lib/providers/auth_provider.dart
// ĐÃ SỬA LỖI TỰ ĐỘNG TẢI LẠI USER KHI REFRESH

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false; // Chỉ loading cho sign-in/sign-up
  bool _isAuthLoading = true; // Loading cho trạng thái ban đầu
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthLoading => _isAuthLoading; // Thêm getter
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userModel != null;

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  AuthProvider() {
    debugPrint('🔧 AuthProvider initialized');
    // Tự động lắng nghe auth state
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Tự động gọi khi auth state thay đổi (lúc mở app, login, logout)
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      // Người dùng đã đăng xuất
      _userModel = null;
      _isAuthLoading = false;
      notifyListeners();
      debugPrint('Auth listener: User logged out.');
    } else {
      // Người dùng đã đăng nhập (hoặc vừa refresh)
      // Kiểm tra xem đã có user model chưa
      if (_userModel?.uid != user.uid) {
        debugPrint('Auth listener: User detected. Fetching user model...');
        // Đặt _isAuthLoading = true để UI biết đang tải user
        _isAuthLoading = true;
        notifyListeners();
        
        try {
          // Lấy dữ liệu từ Firestore bằng hàm trong AuthService
          _userModel = await _authService.getUserData(user.uid);
          if (_userModel == null) {
            _errorMessage = 'Lỗi: Không tìm thấy hồ sơ người dùng trong Firestore.';
            await _authService.signOut(); // Đẩy ra nếu data không khớp
          } else {
             debugPrint('Auth listener: User model loaded successfully.');
          }
        } catch (e) {
           _errorMessage = e.toString();
           _userModel = null;
        } finally {
          _isAuthLoading = false;
          notifyListeners();
        }
      } else {
         debugPrint('Auth listener: User model already loaded.');
         // Nếu đã có model rồi (ví dụ: sau khi sign-in), không cần làm gì
         if(_isAuthLoading) {
           _isAuthLoading = false;
           notifyListeners();
         }
      }
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    String userType = 'consumer',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // _userModel sẽ được tự động gán bởi _onAuthStateChanged
      await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
        userType: userType,
      );
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // _userModel sẽ được tự động gán bởi _onAuthStateChanged
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = await _authService.signInWithGoogle();
      _isLoading = false;
      return model != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      // _userModel sẽ tự động bị clear bởi _onAuthStateChanged
      _isLoading = false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}