import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/verification_service.dart'; 
import '../../../providers/auth_provider.dart';
import 'verification_result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isLoading = false;
  late final VerificationService _verificationService;
  
  @override
  void initState() {
    super.initState();
    _verificationService = VerificationService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã QR', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)]),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator(color: Color(0xFF00BCD4))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 250, height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00BCD4), width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Icon(Icons.qr_code_scanner, size: 120, color: Color(0xFF00BCD4)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text('Quét mã QR trên sản phẩm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Đặt mã QR vào giữa khung để quét', style: TextStyle(fontSize: 15, color: Colors.grey[600]), textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _startScanning(context),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Bắt đầu quét'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BCD4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _showManualInputDialog(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('Nhập mã thủ công'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00BCD4),
                          side: const BorderSide(color: Color(0xFF00BCD4)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _startScanning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng quét camera đang cập nhật')));
  }

  void _showManualInputDialog(BuildContext parentContext) {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nhập mã sản phẩm'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: 'Nhập Serial Number...', border: OutlineInputBorder()),
          keyboardType: TextInputType.text,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy')
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(dialogContext);
                _verifyProduct(parentContext, code); 
              }
            },
            child: const Text('Xác thực'),
          ),
        ],
      ),
    );
  }

  void _verifyProduct(BuildContext context, String code) async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.userModel;
      
      final userId = user?.uid ?? 'guest_unknown';
      final userName = user?.displayName ?? 'Khách vãng lai';

      final result = await _verificationService.verifyProduct(
        serialNumber: code,
        userId: userId,
        userName: userName,
        verificationMethod: 'manual',
        location: 'Hồ Chí Minh',
        deviceInfo: 'Mobile App',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final product = result['product']; 
        Map<String, dynamic>? productInfo;
        
        if (product != null) {
          productInfo = {
            'name': product.name,
            
            // 👇 ĐÃ SỬA: Để trống ảnh để không bị lỗi 'images' not found
            'imageUrl': '', 
            
            'serialNumber': code,
          };
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationResultPage(
              isAuthentic: result['isAuthentic'] ?? false,
              batchId: code,
              history: result['blockchainHistory'] ?? [],
              productInfo: productInfo,
            ),
          ),
        );
      } else {
        throw Exception(result['message']);
      }

    } catch (e) {
      debugPrint("❌ Lỗi xác thực: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        )
      );
    }
  }
}