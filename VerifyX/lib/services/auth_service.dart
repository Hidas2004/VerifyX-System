import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    String userType = 'consumer',
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(displayName);
        await user.reload();
        user = _auth.currentUser;

        // Create user document in Firestore
        UserModel userModel = UserModel(
          uid: user!.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          userType: userType,
        );

        // DEBUG: In ra console
        debugPrint('🔥 Đang lưu user vào Firestore...');
        debugPrint('User ID: ${user.uid}');
        debugPrint('Data: ${userModel.toMap()}');

        try {
          await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
          debugPrint('✅ Lưu Firestore THÀNH CÔNG!');
        } catch (e) {
          debugPrint('❌ LỖI khi lưu Firestore: $e');
          throw 'Không thể lưu thông tin người dùng: $e';
        }

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã có lỗi xảy ra: $e';
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': DateTime.now().toIso8601String(),
        });

        // Get user data from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã có lỗi xảy ra: $e';
    }
    return null;
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user document exists
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        
        UserModel userModel;
        if (!doc.exists) {
          // Create new user document
          userModel = UserModel(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName,
            photoURL: user.photoURL,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
            userType: 'consumer',
          );
          await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        } else {
          // Update last login
          await _firestore.collection('users').doc(user.uid).update({
            'lastLogin': DateTime.now().toIso8601String(),
          });
          userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã có lỗi xảy ra khi đăng nhập bằng Google: $e';
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw 'Đã có lỗi xảy ra khi đăng xuất: $e';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Đã có lỗi xảy ra: $e';
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw 'Không thể lấy thông tin người dùng: $e';
    }
    return null;
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng đăng nhập hoặc sử dụng email khác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt.';
      default:
        return 'Đã có lỗi xảy ra: ${e.message}';
    }
  }
}
