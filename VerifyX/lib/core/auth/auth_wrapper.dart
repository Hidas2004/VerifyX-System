import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/common/common_widgets.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/admin/admin_screen.dart';
import '../../screens/brand/brand_home_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AUTH WRAPPER - Kiểm tra authentication và điều hướng
/// ═══════════════════════════════════════════════════════════════════════════
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: LoadingIndicator(message: 'Đang kiểm tra đăng nhập...'),
          );
        }
        
        // Chưa đăng nhập
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        
        // Đã đăng nhập → Kiểm tra role
        return _RoleChecker(user: snapshot.data!);
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// ROLE CHECKER - Kiểm tra role và điều hướng
/// ═══════════════════════════════════════════════════════════════════════════
class _RoleChecker extends StatelessWidget {
  final User user;

  const _RoleChecker({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: LoadingIndicator(message: 'Đang tải thông tin...'),
          );
        }
        
        // Error hoặc không có data → Về login
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          debugPrint('⚠️ Error loading user data: ${snapshot.error}');
          return const LoginScreen();
        }
        
        // Lấy userType
        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final userType = (userData?['userType'] ?? 'consumer').toString().toLowerCase();
        
        // Debug logging
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('🔐 AUTH WRAPPER - ROLE CHECKING');
        debugPrint('User ID: ${user.uid}');
        debugPrint('Email: ${user.email}');
        debugPrint('UserType: $userType');
        debugPrint('═══════════════════════════════════════════════════════════');
        
        // Điều hướng theo role (case-insensitive)
        switch (userType) {
          case 'admin':
            debugPrint('✅ Routing to AdminScreen');
            return const AdminScreen();
          case 'brand':
            debugPrint('✅ Routing to BrandHomeScreen');
            return const BrandHomeScreen();
          case 'consumer':
            debugPrint('✅ Routing to HomeScreen (Consumer)');
            return const HomeScreen();
          default:
            debugPrint('⚠️ Unknown userType: $userType, defaulting to HomeScreen');
            return const HomeScreen();
        }
      },
    );
  }
}
