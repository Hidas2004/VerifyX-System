import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

/// Provider quản lý state của User
/// Tách biệt với AuthProvider - chỉ xử lý user data, không xử lý auth
class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  // ==================== STATE ====================
  
  UserModel? _currentUserModel;
  Map<String, int> _userStatistics = {};
  bool _isLoading = false;
  String? _errorMessage;

  // ==================== GETTERS ====================
  
  UserModel? get currentUserModel => _currentUserModel;
  Map<String, int> get userStatistics => _userStatistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserService get userService => _userService;

  // ==================== USER OPERATIONS ====================

  /// Load current user model
  Future<void> loadCurrentUser() async {
    final currentUser = _userService.currentUser;
    if (currentUser == null) {
      _currentUserModel = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _currentUserModel = await _userService.getUserModel(currentUser.uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Listen to current user changes
  void listenToCurrentUser() {
    final currentUser = _userService.currentUser;
    if (currentUser == null) return;

    _userService.getUserModelStream(currentUser.uid).listen((userModel) {
      _currentUserModel = userModel;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    final currentUser = _userService.currentUser;
    if (currentUser == null) {
      _errorMessage = 'Bạn phải đăng nhập';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.updateUserProfile(
        uid: currentUser.uid,
        displayName: displayName,
        photoURL: photoURL,
        phoneNumber: phoneNumber,
      );

      // Reload user model
      await loadCurrentUser();
      
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

  // ==================== ADMIN OPERATIONS ====================

  /// Load user statistics (Admin only)
  Future<void> loadUserStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userStatistics = await _userService.getUserStatistics();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final currentUser = _userService.currentUser;
    if (currentUser == null) return false;

    try {
      return await _userService.isAdmin(currentUser.uid);
    } catch (e) {
      return false;
    }
  }

  /// Update user type (Admin only)
  Future<bool> updateUserType({
    required String uid,
    required String userType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.updateUserType(uid: uid, userType: userType);
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

  /// Delete user (Admin only)
  Future<bool> deleteUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userService.deleteUser(uid);
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

  // ==================== UTILITY ====================

  /// Clear current user (sau khi logout)
  void clearUser() {
    _currentUserModel = null;
    _userStatistics = {};
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
