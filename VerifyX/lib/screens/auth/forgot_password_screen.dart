import 'package:flutter/foundation.dart'; // 💡 Thêm import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/utils.dart'; // 💡 Thêm import
import '../../widgets/common/common_widgets.dart'; // 💡 Thêm import

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // 💡 Thêm màu chủ đạo
  static const Color primaryColor = Color(0xFF4A4DE6);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success =
        await authProvider.resetPassword(_emailController.text.trim());

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Email đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư của bạn.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============ BUILD UI CHÍNH (RESPONSIVE) ============
  @override
  Widget build(BuildContext context) {
    // 💡 THAY ĐỔI: Bỏ Scaffold cũ
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Nền xám
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // 💡 THAY ĐỔI: Thêm LayoutBuilder
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
      BuildContext context, AuthProvider authProvider) {
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
              // 1. CỘT TRÁI (LOGO)
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
  // (Copy y hệt trang Login)
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
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
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Xác thực sản phẩm chính hãng',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // ... (Các icon trang trí)
          Positioned(
            top: 20, left: 20,
            child: Icon(Icons.qr_code_scanner, color: Colors.white.withOpacity(0.3), size: 50),
          ),
          Positioned(
            bottom: 30, right: 20,
            child: Icon(Icons.verified_user, color: Colors.white.withOpacity(0.3), size: 50),
          ),
        ],
      ),
    );
  }

  // ============ WIDGET: PANEL FORM (DESKTOP) ============
  Widget _buildDesktopFormPanel(AuthProvider authProvider) {
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
                  'Quên mật khẩu?', // 💡 THAY ĐỔI: Tiêu đề
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập email của bạn và chúng tôi sẽ gửi liên kết để đặt lại mật khẩu.', // 💡 THAY ĐỔI: Mô tả
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 40),

                // 💡 THAY ĐỔI: Dùng CustomTextField
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email, // Giả sử bạn có Validators.email
                ),
                const SizedBox(height: 32),

                // 💡 THAY ĐỔI: Dùng nút gradient
                _buildResetButton(authProvider),
                
                const SizedBox(height: 24),
                _buildLoginLink(), // Link quay lại
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ LAYOUT CHO MOBILE (1 CỘT) ============
  Widget _buildMobileLayout(BuildContext context, AuthProvider authProvider) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMobileHeader(context), // Header logo
                  const SizedBox(height: 32),
                  const Text(
                    'Quên mật khẩu?', // 💡 THAY ĐỔI: Tiêu đề
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhập email của bạn và chúng tôi sẽ gửi liên kết để đặt lại mật khẩu.', // 💡 THAY ĐỔI: Mô tả
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 💡 THAY ĐỔI: Dùng CustomTextField
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 32),
                  
                  // 💡 THAY ĐỔI: Dùng nút gradient
                  _buildResetButton(authProvider),

                  const SizedBox(height: 24),
                  _buildLoginLink(), // Link quay lại
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============ WIDGET: HEADER (MOBILE) ============
  // (Copy y hệt trang Login)
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
            color: Colors.black87,
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

  // ============ WIDGET: NÚT GỬI EMAIL ============
  Widget _buildResetButton(AuthProvider authProvider) {
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
        onPressed: authProvider.isLoading ? null : _handleResetPassword,
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
                'Gửi email đặt lại',
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

  // ============ WIDGET: LINK QUAY LẠI ============
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã nhớ mật khẩu? ',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: const Text(
            'Quay lại đăng nhập',
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