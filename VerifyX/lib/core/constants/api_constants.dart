/// ═══════════════════════════════════════════════════════════════════════════
/// API CONSTANTS - Cấu hình API
/// ═══════════════════════════════════════════════════════════════════════════
class ApiConstants {
  ApiConstants._();

  // ==================== BASE URL ====================
  
  /// Base URL cho API backend
  /// TODO: Thay đổi khi deploy production
  static const String baseUrl = 'https://api.verifyx.com';
  
  /// Base URL cho local development
  static const String baseUrlLocal = 'http://localhost:8080';

  /// Base URL cho AI server (local development)
  static const String baseUrlAiLocal = 'http://localhost:3001';

  // ==================== ENDPOINTS ====================
  
  /// Auth endpoints
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String logout = '/api/v1/auth/logout';
  static const String refreshToken = '/api/v1/auth/refresh';
  
  /// Product endpoints
  static const String verifyProduct = '/api/v1/products/verify';
  static const String getProduct = '/api/v1/products';
  static const String searchProduct = '/api/v1/products/search';
  
  /// User endpoints
  static const String getProfile = '/api/v1/users/profile';
  static const String updateProfile = '/api/v1/users/profile';
  
  /// Post endpoints
  static const String getPosts = '/api/v1/posts';
  static const String createPost = '/api/v1/posts';
  static const String likePost = '/api/v1/posts/:id/like';
  static const String commentPost = '/api/v1/posts/:id/comments';

  // ==================== TIMEOUTS ====================
  
  /// Timeout cho mỗi API request (15 giây)
  static const Duration timeout = Duration(seconds: 15);
  
  /// Timeout cho upload file (60 giây)
  static const Duration uploadTimeout = Duration(seconds: 60);

  // ==================== HEADERS ====================
  
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  static const String applicationJson = 'application/json';
}