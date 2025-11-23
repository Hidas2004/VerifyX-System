import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service xử lý tất cả logic liên quan đến Users
/// Tách biệt hoàn toàn với UI layer
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy current user
  User? get currentUser => _auth.currentUser;

  /// Lấy user model từ Firestore
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy thông tin user: $e');
    }
  }

  /// Lấy stream user model
  Stream<UserModel?> getUserModelStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Cập nhật user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) updateData['photoURL'] = photoURL;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);

        // Update Firebase Auth display name nếu có
        if (displayName != null) {
          await _auth.currentUser?.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await _auth.currentUser?.updatePhotoURL(photoURL);
        }
      }
    } catch (e) {
      throw Exception('Không thể cập nhật profile: $e');
    }
  }

  /// Lấy danh sách tất cả users (Admin only)
  Stream<List<UserModel>> getAllUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Lấy số lượng users theo type
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      
      int total = 0;
      int consumers = 0;
      int brands = 0;
      int admins = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userType = data['userType'] ?? 'consumer';
        
        total++;
        switch (userType) {
          case 'consumer':
            consumers++;
            break;
          case 'brand':
            brands++;
            break;
          case 'admin':
            admins++;
            break;
        }
      }

      return {
        'total': total,
        'consumer': consumers,
        'brand': brands,
        'admin': admins,
      };
    } catch (e) {
      return {
        'total': 0,
        'consumer': 0,
        'brand': 0,
        'admin': 0,
      };
    }
  }

  /// Kiểm tra user có phải admin không
  Future<bool> isAdmin(String uid) async {
    try {
      final userModel = await getUserModel(uid);
      return userModel?.userType == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Cập nhật userType (Admin only)
  Future<void> updateUserType({
    required String uid,
    required String userType,
  }) async {
    try {
      if (!['consumer', 'brand', 'admin'].contains(userType)) {
        throw Exception('UserType không hợp lệ');
      }

      await _firestore.collection('users').doc(uid).update({
        'userType': userType,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật userType: $e');
    }
  }

  /// Xóa user (Admin only)
  Future<void> deleteUser(String uid) async {
    try {
      // Xóa user document từ Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Note: Không thể xóa Firebase Auth user từ client side
      // Cần sử dụng Firebase Admin SDK hoặc Cloud Functions
    } catch (e) {
      throw Exception('Không thể xóa user: $e');
    }
  }
}
