import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class BrandProfilePage extends StatefulWidget {
  const BrandProfilePage({super.key});

  @override
  State<BrandProfilePage> createState() => _BrandProfilePageState();
}

class _BrandProfilePageState extends State<BrandProfilePage> {
  // Controller form
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load dữ liệu user vào form
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? "";
      // Các trường khác nếu chưa có trong model thì để trống hoặc giả lập
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userModel;
    final width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return Container(
      color: AppColors.adminBackground,
      padding: const EdgeInsets.all(24),
      child: isDesktop 
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildLeftColumn(user)),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: _buildRightColumn()),
            ],
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildLeftColumn(user),
                const SizedBox(height: 24),
                _buildRightColumn(),
              ],
            ),
          ),
    );
  }

  // CỘT TRÁI: Logo & Blockchain Info
  Widget _buildLeftColumn(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.kpiBlue,
            child: Icon(Icons.business, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? "Tên Doanh Nghiệp",
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text("Verified Brand", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 40),
          
          // Ví Blockchain
          Align(alignment: Alignment.centerLeft, child: Text("Ví Blockchain:", style: GoogleFonts.inter(color: Colors.grey))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "0x71C...b9a", // Thay bằng user.walletAddress thật
                    style: GoogleFonts.robotoMono(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: "0x71C7656EC7ab88b098defB751B7401B5f6d89b9a"));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép địa chỉ ví")));
                  },
                  child: const Icon(Icons.copy, size: 18, color: Colors.grey),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // CỘT PHẢI: Form thông tin
  Widget _buildRightColumn() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thông tin chi tiết", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          _buildInputGroup("Email Liên hệ", _emailController, Icons.email),
          _buildInputGroup("Số điện thoại", _phoneController, Icons.phone),
          Row(
            children: [
              Expanded(child: _buildInputGroup("Mã số thuế", _taxController, Icons.assignment)),
              const SizedBox(width: 16),
              Expanded(child: _buildInputGroup("Website", TextEditingController(text: "https://verifyx.com"), Icons.language)),
            ],
          ),
          _buildInputGroup("Địa chỉ Trụ sở", _addressController, Icons.location_city),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kpiBlue),
              child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}