import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/post_service.dart';

/// Provider quản lý state của Posts
/// Sử dụng ChangeNotifier để notify listeners khi có thay đổi
class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  // ==================== STATE ====================
  
  List<PostModel> _posts = [];
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'community'; // 'community' hoặc 'brand'
  String _currentSort = 'newest'; // 'newest', 'oldest', 'mostLiked', 'mostCommented'

  // ==================== GETTERS ====================
  
  List<PostModel> get posts => _posts;
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  String get currentSort => _currentSort;

  // ==================== FILTER & SORT ====================

  /// Set filter (community/brand)
  void setFilter(String filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      notifyListeners();
    }
  }

  /// Set sort type
  void setSort(String sort) {
    if (_currentSort != sort) {
      _currentSort = sort;
      notifyListeners();
    }
  }

  // ==================== POSTS OPERATIONS ====================

  /// Load posts (không cần thiết nếu dùng StreamBuilder, nhưng để backup)
  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lắng nghe stream
      _postService
          .getPostsStream(
            postType: _currentFilter,
            sortBy: _currentSort,
          )
          .listen((posts) {
        _posts = posts;
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Không thể tải bài viết: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo post mới
  Future<bool> createPost({
    required String content,
    required String postType,
    List<String> imageUrls = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.createPost(
        content: content,
        postType: postType,
        imageUrls: imageUrls,
      );
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

  /// Cập nhật post
  Future<bool> updatePost({
    required String postId,
    required String content,
    List<String>? imageUrls,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.updatePost(
        postId: postId,
        content: content,
        imageUrls: imageUrls,
      );
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

  /// Xóa post
  Future<bool> deletePost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.deletePost(postId);
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

  // ==================== LIKES ====================

  /// Toggle like
  Future<void> toggleLike(String postId) async {
    try {
      await _postService.toggleLike(postId);
      // State sẽ tự cập nhật qua StreamBuilder
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ==================== COMMENTS ====================

  /// Load comments của post
  void loadComments(String postId) {
    _postService.getCommentsStream(postId).listen((comments) {
      _comments = comments;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      notifyListeners();
    });
  }

  /// Thêm comment
  Future<bool> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      await _postService.addComment(
        postId: postId,
        content: content,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Xóa comment
  Future<bool> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      await _postService.deleteComment(
        commentId: commentId,
        postId: postId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== UTILITY ====================

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get PostService (để UI có thể dùng StreamBuilder trực tiếp)
  PostService get postService => _postService;
}
