import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/admin/admin_screen.dart';
import '../../screens/post/create_post_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP ROUTES - Centralized navigation management
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Lợi ích:
/// - Quản lý routes tập trung
/// - Type-safe navigation
/// - Dễ debug và maintain
/// - Support deep linking
class AppRoutes {
  AppRoutes._();

  // ==================== ROUTE NAMES ====================
  
  /// Auth routes
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  
  /// Main routes
  static const String home = '/home';
  static const String admin = '/admin';
  
  /// Post routes
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  
  /// Profile routes
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  
  /// Search routes
  static const String search = '/search';
  static const String searchResults = '/search-results';
  
  /// Settings routes
  static const String settings = '/settings';
  static const String about = '/about';
  static const String help = '/help';

  // ==================== INITIAL ROUTE ====================
  
  /// Route đầu tiên khi mở app
  static const String initial = login;

  // ==================== ROUTE GENERATOR ====================
  
  /// Generate routes từ route name
  /// 
  /// Sử dụng trong MaterialApp:
  /// ```dart
  /// MaterialApp(
  ///   onGenerateRoute: AppRoutes.onGenerateRoute,
  ///   initialRoute: AppRoutes.initial,
  /// )
  /// ```
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==================== AUTH ====================
      case login:
        return _buildRoute(
          const LoginScreen(),
          settings: settings,
        );
      
      case signUp:
        return _buildRoute(
          const SignUpScreen(),
          settings: settings,
        );
      
      case forgotPassword:
        return _buildRoute(
          const ForgotPasswordScreen(),
          settings: settings,
        );

      // ==================== MAIN ====================
      case home:
        return _buildRoute(
          const HomeScreen(),
          settings: settings,
        );
      
      case admin:
        return _buildRoute(
          const AdminScreen(),
          settings: settings,
        );

      // ==================== POST ====================
      case createPost:
        return _buildRoute(
          const CreatePostScreen(),
          settings: settings,
        );

      // ==================== DEFAULT ====================
      default:
        return _buildRoute(
          _ErrorScreen(routeName: settings.name ?? 'Unknown'),
          settings: settings,
        );
    }
  }

  // ==================== HELPER METHODS ====================
  
  /// Build route với transition animation
  static MaterialPageRoute _buildRoute(
    Widget page, {
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  // ==================== NAVIGATION HELPERS ====================
  
  /// Navigate to route (push)
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and replace current route
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  /// Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ERROR SCREEN - Hiển thị khi route không tồn tại
/// ═══════════════════════════════════════════════════════════════════════════
class _ErrorScreen extends StatelessWidget {
  final String routeName;

  const _ErrorScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lỗi'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Không tìm thấy trang',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Route: $routeName',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
