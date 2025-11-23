import 'package:flutter/foundation.dart'; // Import để kiểm tra kIsWeb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/utils.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/auth_provider.dart' as custom_auth;
import '../../core/auth/auth_wrapper.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ============ CONTROLLERS & KEYS ============
  final _formKey = GlobalKey<FormState>(); // Key để validate form
  final _emailController = TextEditingController(); // Controller cho input email
  final _passwordController =
      TextEditingController(); // Controller cho input password

  // ============ STATE VARIABLES ============
  late AnimationController _animationController; // Controller cho animation
  late Animation<double> _fadeAnimation; // Animation fade in
  late Animation<Offset> _slideAnimation; // Animation slide từ dưới lên

  static const Color primaryColor = Color(0xFF4A4DE6);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============ XỬ LÝ ĐĂNG NHẬP ============
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider =
        Provider.of<custom_auth.AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    _handleAuthResult(success, authProvider.errorMessage);
  }

  // ============ XỬ LÝ ĐĂNG NHẬP GOOGLE ============
  Future<void> _handleGoogleSignIn() async {
    final authProvider =
        Provider.of<custom_auth.AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();
    if (!mounted) return;
    _handleAuthResult(success, authProvider.errorMessage);
  }

  // ============ HÀM HELPER XỬ LÝ KẾT QUẢ AUTH ============
  void _handleAuthResult(bool success, String? errorMessage) {
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    } else if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ============ BUILD UI CHÍNH (RESPONSIVE) ============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Nền xám nhạt cho toàn bộ trang
      body: Consumer<custom_auth.AuthProvider>(
        builder: (context, authProvider, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 850 && kIsWeb) {
                return _buildDesktopLayout(context, authProvider);
              } else {
                return _buildMobileLayout(context, authProvider);
              }
            },
          );
        },
      ),
    );
  }

  // ============ LAYOUT CHO DESKTOP/WEB (2 CỘT) ============
  Widget _buildDesktopLayout(
      BuildContext context, custom_auth.AuthProvider authProvider) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 1000, maxHeight: 700), // Giới hạn card
        child: Card(
          elevation: 8.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // 1. CỘT TRÁI (LOGO & HÌNH MINH HỌA)
              Expanded(
                flex: 1,
                child: _buildDesktopIllustrationPanel(),
              ),
              // 2. CỘT PHẢI (FORM)
              Expanded(
                flex: 1,
                child: _buildDesktopFormPanel(authProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ WIDGET: PANEL MINH HỌA (DESKTOP) ============
  Widget _buildDesktopIllustrationPanel() {
    return Container(
      color: primaryColor, // Nền màu xanh đậm
      padding: const EdgeInsets.all(48.0),
      child: Stack( 
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // Dùng logo của bạn
                ClipRRect(
                  borderRadius: BorderRadius.circular(24), // Bo góc cho logo
                  child: Image.asset(
                    'assets/images/logo.png', // Dùng logo của bạn
                    width: 150,
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'VerifyX',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white, // Chữ VerifyX màu trắng
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Xác thực sản phẩm chính hãng',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.8), // Slogan màu trắng nhạt
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Các hình minh họa nhỏ
          Positioned(
            top: 20,
            left: 20,
            child: Icon(Icons.qr_code_scanner, color: Colors.white.withOpacity(0.3), size: 50),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: Icon(Icons.verified_user, color: Colors.white.withOpacity(0.3), size: 50),
          ),
          Positioned(
            top: 100,
            right: 50,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15)
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 40,),
            )
          ),
           Positioned(
            bottom: 150,
            // 💡 SỬA LỖI: Đổi left: 50 -> 20
            left: 20,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: const Icon(Icons.settings_overscan, color: Colors.white, size: 30,),
            )
          )
        ],
      ),
    );
  }

  // ============ WIDGET: PANEL FORM (DESKTOP) ============
  Widget _buildDesktopFormPanel(custom_auth.AuthProvider authProvider) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Hello Again!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chào mừng trở lại! Vui lòng nhập thông tin của bạn để đăng nhập.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 40),

                _buildLoginForm(authProvider),
                const SizedBox(height: 16),
                _buildForgotPassword(),
                const SizedBox(height: 24),
                _buildLoginButton(authProvider),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 24),
                _buildGoogleButton(authProvider),
                const SizedBox(height: 32),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ LAYOUT CHO MOBILE (1 CỘT) ============
  Widget _buildMobileLayout(
      BuildContext context, custom_auth.AuthProvider authProvider) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white, // Nền trắng cho mobile
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMobileHeader(context), // Header riêng cho mobile
                      SizedBox(height: size.height * 0.05),
                      _buildLoginForm(authProvider),
                      const SizedBox(height: 16),
                      _buildForgotPassword(),
                      const SizedBox(height: 24),
                      _buildLoginButton(authProvider),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildGoogleButton(authProvider),
                      const SizedBox(height: 32),
                      _buildSignUpLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============ WIDGET: HEADER (MOBILE) ============
  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png', // Logo màu gốc cho mobile
          height: 80,
        ),
        const SizedBox(height: 24),
        const Text(
          'VerifyX',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.black87, // Màu đen cho mobile
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Xác thực sản phẩm chính hãng',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============ WIDGET: FORM ĐĂNG NHẬP (TÁI SỬ DỤNG) ============
  Widget _buildLoginForm(custom_auth.AuthProvider authProvider) {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          labelText: AppStrings.email,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        PasswordTextField(
          controller: _passwordController,
          labelText: AppStrings.password,
          validator: Validators.password,
        ),
      ],
    );
  }

  // ============ WIDGET: QUÊN MẬT KHẨU (TÁI SỬ DỤNG) ============
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          AppRoutes.push(context, AppRoutes.forgotPassword);
        },
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
        child: const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ============ WIDGET: NÚT ĐĂNG NHẬP (TÁI SỬ DỤNG) ============
  Widget _buildLoginButton(custom_auth.AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  // ============ WIDGET: DIVIDER (TÁI SỬ DỤNG) ============
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'hoặc',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  // ============ WIDGET: NÚT GOOGLE (TÁI SỬ DỤNG) ============
  Widget _buildGoogleButton(custom_auth.AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: authProvider.isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Đăng nhập bằng Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ WIDGET: LINK ĐĂNG KÝ (TÁI SỬ DỤNG) ============
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản? ',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () {
            AppRoutes.push(context, AppRoutes.signUp);
          },
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: const Text(
            'Đăng ký ngay',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}