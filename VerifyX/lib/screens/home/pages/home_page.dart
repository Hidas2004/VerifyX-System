import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../../post/create_post_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            // Logo chữ V cách điệu
            const Icon(Icons.shield_moon, color: Color(0xFF00BCD4)), // Đổi icon khiên cho uy tín
            const SizedBox(width: 8),
            const Text("VerifyX Portal", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.black87, size: 28), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF00BCD4),
        onRefresh: () async {
          await Provider.of<PostProvider>(context, listen: false).loadPosts();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // 1. PHẦN CÔNG CỤ TRA CỨU (Thay đổi giao diện để giống Tool hơn)
              _buildToolSection(context),

              const SizedBox(height: 16),
              // Tiêu đề danh sách
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Nhật ký cộng đồng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                ),
              ),
              const SizedBox(height: 10),

              // 2. DANH SÁCH BÀI VIẾT
              _buildPostsFeed(),

              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  // Widget Thanh công cụ xác thực (Thay vì nút đăng bài kiểu FB)
  Widget _buildToolSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
           // Giả lập bấm vào ô tìm kiếm thì mở trang tạo bài hoặc trang scan
           Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen(openImagePicker: false)));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
            ],
            border: Border.all(color: Colors.blue.withOpacity(0.1))
          ),
          child: Row(
            children: [
              // Avatar người dùng
              CircleAvatar(
                backgroundColor: const Color(0xFFE0F7FA),
                child: const Icon(Icons.person, color: Color(0xFF00BCD4)),
              ),
              const SizedBox(width: 12),
              
              // Text giả input - ĐỔI NỘI DUNG Ở ĐÂY
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tra cứu nguồn gốc...",
                      style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Nhập mã sản phẩm hoặc quét QR",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Nút Scan nổi bật
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Row(
                  children: const [
                    Icon(Icons.qr_code_2, color: Color(0xFF00BCD4), size: 20),
                    SizedBox(width: 4),
                    Text("SCAN", style: TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsFeed() {
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        return StreamBuilder(
          stream: provider.postService.getPostsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00BCD4)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.verified_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text("Chưa có dữ liệu xác thực", style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                ),
              );
            }

            final posts = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: posts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => PostCard(post: posts[i]),
            );
          },
        );
      },
    );
  }
}