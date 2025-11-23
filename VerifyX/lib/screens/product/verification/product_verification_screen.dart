import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/verification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/product_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import 'product_detail_screen.dart';
import 'qr_scanner_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT VERIFICATION SCREEN - Xác thực sản phẩm
/// ═══════════════════════════════════════════════════════════════════════════
class ProductVerificationScreen extends StatefulWidget {
  const ProductVerificationScreen({super.key});

  @override
  State<ProductVerificationScreen> createState() =>
      _ProductVerificationScreenState();
}

class _ProductVerificationScreenState extends State<ProductVerificationScreen> {
  final _serialController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  Future<void> _verifyBySerial() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final verificationProvider =
        Provider.of<VerificationProvider>(context, listen: false);

    final userModel = authProvider.userModel;
    if (userModel == null) return;

    final result = await verificationProvider.verifyProduct(
      serialNumber: _serialController.text.trim(),
      userId: userModel.uid,
      userName: userModel.displayName ?? 'User',
      verificationMethod: 'serial',
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final product = result['product'] as ProductModel;
      final blockchainVerified = result['blockchainVerified'] as bool;

      try {
        await verificationProvider.processScannedCode(
          _serialController.text.trim(),
          'Nguoi tieu dung',
        );
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loi blockchain: $error'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(
            product: product,
            blockchainVerified: blockchainVerified,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Xác thực thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openQRScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result != null && mounted) {
      _serialController.text = result;
      _verifyBySerial();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác thực sản phẩm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Xác thực sản phẩm chính hãng',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                'Nhập mã serial hoặc quét QR code để kiểm tra tính xác thực của sản phẩm',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Serial Input
              CustomTextField(
                controller: _serialController,
                labelText: 'Mã Serial',
                hintText: 'Nhập mã serial (VFX...)',
                prefixIcon: Icons.qr_code,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã serial';
                  }
                  if (!value.startsWith('VFX')) {
                    return 'Mã serial không hợp lệ';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Verify Button
              Consumer<VerificationProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Xác thực sản phẩm',
                    onPressed: provider.isLoading ? null : _verifyBySerial,
                    isLoading: provider.isLoading,
                    icon: Icons.check_circle,
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('HOẶC'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // QR Scanner Button
              OutlinedButton.icon(
                onPressed: _openQRScanner,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Quét mã QR'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Info cards
              _buildInfoCard(
                icon: Icons.shield,
                title: 'Bảo vệ người tiêu dùng',
                description: 'Kiểm tra ngay để tránh hàng giả',
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                icon: Icons.lock_clock,
                title: 'Công nghệ Blockchain',
                description: 'Đảm bảo tính minh bạch và không thể giả mạo',
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoCard(
                icon: Icons.history,
                title: 'Lịch sử truy xuất',
                description: 'Theo dõi nguồn gốc từ nhà máy đến tay bạn',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
