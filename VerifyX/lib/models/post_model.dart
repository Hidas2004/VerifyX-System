import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho bài viết
/// Quản lý cấu trúc dữ liệu của một bài post trong hệ thống
class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final List<String> imageUrls;
  final String postType; // 'community', 'brand', 'alert'
  final bool isOfficial; // 🟢 MỚI: Đánh dấu bài viết chính chủ của Brand
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

 PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    this.imageUrls = const [],
    required this.postType,
    this.isOfficial = false, // Mặc định false
    this.likes = const [],
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo PostModel từ Firestore document
factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorId: data['authorId'] ?? data['userId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      imageUrls: _extractImageUrls(data),
      postType: data['postType'] ?? 'community',
      isOfficial: data['isOfficial'] ?? false, // 🟢 Map từ Firestore
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Tạo PostModel từ Map
  factory PostModel.fromMap(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
  authorId: data['authorId'] ?? data['userId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
  imageUrls: _extractImageUrls(data),
      postType: data['postType'] ?? 'community',
      likes: List<String>.from(data['likes'] ?? []),
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'imageUrls': imageUrls,
      'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
      'userId': authorId,
      'postType': postType,
      'isOfficial': isOfficial, // 🟢 Lưu vào Firestore
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copy with method
  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPhotoUrl,
    String? content,
    List<String>? imageUrls,
    String? postType,
    List<String>? likes,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      postType: postType ?? this.postType,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Kiểm tra user đã like chưa
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  /// Lấy số lượng likes
  int get likesCount => likes.length;

  static List<String> _extractImageUrls(Map<String, dynamic> data) {
    final raw = data['imageUrls'];
    if (raw is Iterable) {
      return raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    final single = data['imageUrl'];
    if (single is String && single.isNotEmpty) {
      return [single];
    }
    return const [];
  }
}
