import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ⚠️ LƯU Ý: Kiểm tra lại đường dẫn import này cho đúng với cấu trúc thư mục của bạn
import '../../models/post_model.dart'; 
import '../../models/comment_model.dart'; 

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== POSTS ====================

  /// Lấy stream posts theo filter
  /// Đã sửa: postType là tùy chọn (String?) để Admin lấy được tất cả bài
  Stream<List<PostModel>> getPostsStream({
    String? postType, 
    String sortBy = 'newest',
  }) {
    Query query = _firestore.collection('posts');

    // Chỉ lọc nếu postType khác null và khác 'all'
    if (postType != null && postType != 'all') {
      query = query.where('postType', isEqualTo: postType);
    }

    return query.snapshots().map((snapshot) {
      List<PostModel> posts = snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();

      // Sort thủ công ở client
      switch (sortBy) {
        case 'oldest':
          posts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'mostLiked':
          posts.sort((a, b) => b.likesCount.compareTo(a.likesCount));
          break;
        case 'mostCommented':
          posts.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
          break;
        case 'newest':
        default:
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      return posts;
    });
  }

  /// Lấy một post theo ID
  Future<PostModel?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return PostModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy bài viết: $e');
    }
  }

  /// Tạo post mới
  /// 🟢 ĐÃ SỬA: Thêm tham số isOfficial cho Brand
  Future<String> createPost({
    required String content,
    required String postType,
    List<String> imageUrls = const [],
    bool isOfficial = false, // Mặc định là false (User thường)
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Bạn phải đăng nhập để đăng bài');
      }

      // Lấy thông tin user từ Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data();

      final authorName =
          userData?['displayName'] ?? currentUser.displayName ?? 'Unknown';
      final authorPhotoUrl = userData?['photoURL'] ?? currentUser.photoURL;
      final nowServer = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('posts').add({
        'authorId': currentUser.uid,
        'userId': currentUser.uid, 
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'imageUrls': imageUrls,
        'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : null,
        'postType': postType,
        'isOfficial': isOfficial, // Lưu trạng thái tích xanh
        'likes': <String>[],
        'commentsCount': 0,
        'createdAt': nowServer,
        'updatedAt': nowServer,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Không thể tạo bài viết: $e');
    }
  }

  /// Cập nhật post
  Future<void> updatePost({
    required String postId,
    required String content,
    List<String>? imageUrls,
  }) async {
    try {
      final updateData = {'content': content, 'updatedAt': Timestamp.now()};

      if (imageUrls != null) {
        updateData['imageUrls'] = imageUrls;
      }

      await _firestore.collection('posts').doc(postId).update(updateData);
    } catch (e) {
      throw Exception('Không thể cập nhật bài viết: $e');
    }
  }

  /// Xóa post
  Future<void> deletePost(String postId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      // Xóa comments
      final commentsSnapshot = await postRef.collection('comments').get();
      final batch = _firestore.batch();
      for (var doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(postRef);
      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi xóa bài: $e');
    }
  }

  // ==================== LIKES ====================

  /// Like/Unlike post
  Future<void> toggleLike(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Bạn phải đăng nhập để like');
      }

      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();

      if (!postDoc.exists) {
        throw Exception('Bài viết không tồn tại');
      }

      final data = postDoc.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      if (likes.contains(currentUser.uid)) {
        likes.remove(currentUser.uid);
      } else {
        likes.add(currentUser.uid);
      }

      await postRef.update({'likes': likes});
    } catch (e) {
      throw Exception('Không thể like/unlike: $e');
    }
  }

  /// Kiểm tra user đã like post chưa
  Future<bool> isPostLikedByUser(String postId, String userId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        final post = PostModel.fromFirestore(doc);
        return post.isLikedBy(userId);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== COMMENTS ====================

  /// Lấy stream comments của post
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList();
        });
  }

  /// Thêm comment
  Future<String> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Bạn phải đăng nhập để comment');
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data();

      final comment = CommentModel(
        id: '',
        postId: postId,
        authorId: currentUser.uid,
        authorName:
            userData?['displayName'] ?? currentUser.displayName ?? 'Unknown',
        authorPhotoUrl: userData?['photoURL'] ?? currentUser.photoURL,
        content: content,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(comment.toMap());

      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Không thể thêm comment: $e');
    }
  }

  /// Xóa comment
  Future<void> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Không thể xóa comment: $e');
    }
  }

  // ==================== STATISTICS ====================

  Future<int> getTotalPostsCount() async {
    try {
      final snapshot = await _firestore.collection('posts').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _firestore
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PostModel.fromFirestore(doc))
              .toList();
        });
  }
}