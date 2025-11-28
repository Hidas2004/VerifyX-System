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
    // Lấy kích thước màn hình để tính toán cho chuẩn
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: const BackButton(color: Colors.black), 
      ),
      // [FIX] Thêm SingleChildScrollView để không bị lỗi khi bàn phím hiện lên
      body: Container(
        width: double.infinity,
        height: size.height, // Chiếm toàn bộ chiều cao
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA), 
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Frame Scan
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 280, height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: const Color(0xFF00BCD4).withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
                      ),
                    ),
                    const Icon(Icons.qr_code_scanner_rounded, size: 150, color: Color(0xFF00BCD4)),
                  ],
                ),
                
                const SizedBox(height: 50),
                
                const Text("Quét mã sản phẩm", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Di chuyển camera đến mã QR trên sản phẩm\nđể kiểm tra thông tin chính hãng.", 
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], height: 1.5)),
                
                const SizedBox(height: 40),

                // Nút bấm bo tròn
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () => _startScanning(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                      shadowColor: const Color(0xFF00BCD4).withOpacity(0.5),
                    ),
                    child: const Text('Bắt đầu quét', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _showManualInputDialog(context),
                  child: const Text('Nhập mã thủ công', style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.w600)),
                ),
                
                // Khoảng trống dự phòng cho bàn phím
                const SizedBox(height: 20),
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
            autofocus: true // Tự động bật bàn phím
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
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
          // [LOGIC QUAN TRỌNG]: Truyền đầy đủ dữ liệu để trang kết quả hiển thị đẹp
          productInfo = {
            'name': product.name,
            'imageUrl': product.imageUrl, 
            'serialNumber': code,
            'brandName': product.brandName,
            'manufacturingDate': product.manufacturingDate.toString(), 
            'expiryDate': product.expiryDate.toString(),
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