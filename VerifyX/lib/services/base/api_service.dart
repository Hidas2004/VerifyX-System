import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// API SERVICE - Base class cho HTTP requests
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Lợi ích:
/// - Centralized API calls
/// - Consistent error handling
/// - Easy to mock for testing
/// - Token management
/// 
/// Usage:
/// ```dart
/// class UserService extends ApiService {
///   Future<User> getUser(String id) async {
///     final response = await get('/users/$id');
///     return User.fromJson(response);
///   }
/// }
/// ```
class ApiService {
  // ==================== CONFIGURATION ====================
  
  /// Base URL cho API
  final String baseUrl;
  
  /// Timeout duration
  final Duration timeout;
  
  /// Headers mặc định
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Auth token (optional)
  String? _authToken;

  // ==================== CONSTRUCTOR ====================
  
  ApiService({
    this.baseUrl = ApiConstants.baseUrl,
    this.timeout = const Duration(seconds: 30),
  });

  // ==================== TOKEN MANAGEMENT ====================
  
  /// Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }
  
  /// Get headers with auth token
  Map<String, String> get _headers {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ==================== HTTP METHODS ====================
  
  /// GET request
  /// 
  /// Example:
  /// ```dart
  /// final data = await get('/users/123');
  /// ```
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      debugPrint('🌐 GET: $uri');
      
      final response = await http
          .get(
            uri,
            headers: {..._headers, ...?headers},
          )
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  /// 
  /// Example:
  /// ```dart
  /// final data = await post('/users', body: {'name': 'John'});
  /// ```
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      debugPrint('🌐 POST: $uri');
      debugPrint('📦 Body: $body');
      
      final response = await http
          .post(
            uri,
            headers: {..._headers, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  /// 
  /// Example:
  /// ```dart
  /// final data = await put('/users/123', body: {'name': 'Jane'});
  /// ```
  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      debugPrint('🌐 PUT: $uri');
      debugPrint('📦 Body: $body');
      
      final response = await http
          .put(
            uri,
            headers: {..._headers, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  /// 
  /// Example:
  /// ```dart
  /// final data = await patch('/users/123', body: {'email': 'new@email.com'});
  /// ```
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      debugPrint('🌐 PATCH: $uri');
      debugPrint('📦 Body: $body');
      
      final response = await http
          .patch(
            uri,
            headers: {..._headers, ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  /// 
  /// Example:
  /// ```dart
  /// await delete('/users/123');
  /// ```
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      debugPrint('🌐 DELETE: $uri');
      
      final response = await http
          .delete(
            uri,
            headers: {..._headers, ...?headers},
          )
          .timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== HELPER METHODS ====================
  
  /// Build URI từ endpoint và query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters,
    );
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    debugPrint('📥 Response [${response.statusCode}]: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Unauthorized
      throw ApiException(
        message: 'Phiên đăng nhập hết hạn',
        statusCode: response.statusCode,
      );
    } else if (response.statusCode == 403) {
      // Forbidden
      throw ApiException(
        message: 'Bạn không có quyền thực hiện thao tác này',
        statusCode: response.statusCode,
      );
    } else if (response.statusCode == 404) {
      // Not found
      throw ApiException(
        message: 'Không tìm thấy dữ liệu',
        statusCode: response.statusCode,
      );
    } else if (response.statusCode >= 500) {
      // Server error
      throw ApiException(
        message: 'Lỗi máy chủ, vui lòng thử lại sau',
        statusCode: response.statusCode,
      );
    } else {
      // Other errors
      final body = jsonDecode(response.body);
      throw ApiException(
        message: body['message'] ?? 'Đã có lỗi xảy ra',
        statusCode: response.statusCode,
      );
    }
  }

  /// Handle errors
  Exception _handleError(dynamic error) {
    debugPrint('❌ API Error: $error');
    
    if (error is ApiException) {
      return error;
    }
    
    return ApiException(
      message: 'Không thể kết nối đến máy chủ',
      statusCode: 0,
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// API EXCEPTION - Custom exception cho API errors
/// ═══════════════════════════════════════════════════════════════════════════
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
