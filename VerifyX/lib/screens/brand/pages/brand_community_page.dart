import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Giữ nguyên import
import '../../../models/post_model.dart';
import '../../../providers/post_provider.dart';
import '../../home/widgets/create_post_button.dart';
import '../../home/widgets/post_card.dart';

class BrandCommunityPage extends StatefulWidget {
  const BrandCommunityPage({super.key});

  @override
  State<BrandCommunityPage> createState() => _BrandCommunityPageState();
}

class _BrandCommunityPageState extends State<BrandCommunityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 SỬA ĐỔI: Không dùng Row chia cột nữa. 
    // Dùng Align để căn giữa toàn bộ giao diện.
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        // 🟢 CẤU HÌNH "TỈ LỆ VÀNG": Max Width 800px
        constraints: const BoxConstraints(maxWidth: 800),
        // Thêm padding ngang để khi thu nhỏ màn hình không bị dính sát mép
        padding: const EdgeInsets.symmetric(horizontal: 16), 
        
        child: Column(
          children: [
            // 1. THANH CÔNG CỤ (Header)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white, // Hoặc transparent nếu muốn nền xám chung
              child: Column(
                children: [
                  CreatePostButton(
                    onFilterChanged: (_) {}, 
                    onSortChanged: (_) {},
                    hintText: "Đăng thông báo chính thức...",
                  ),
                  const SizedBox(height: 16),
                  
                  // TabBar căn giữa đẹp mắt
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue[800],
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue[800],
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      tabs: const [
                        Tab(text: "Tất cả"),
                        Tab(text: "@Nhắc tên"), // Rút gọn text cho đỡ rườm rà
                        Tab(text: "Hỗ trợ"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. DANH SÁCH BÀI VIẾT (Feed)
            // Expanded để nó chiếm hết phần còn lại của chiều dọc
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeed("all"),
                  _buildFeed("mention"), 
                  _buildFeed("support"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(String filter) {
    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        return StreamBuilder<List<PostModel>>(
          stream: provider.postService.getPostsStream(
            postType: filter == 'all' ? null : filter, 
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
               return Center(child: Text("Lỗi: ${snapshot.error}"));
            }
            
            final posts = snapshot.data ?? [];
            if (posts.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.feed_outlined, size: 60, color: Colors.grey[300]),
                     const SizedBox(height: 12),
                     Text("Chưa có bài viết nào", style: TextStyle(color: Colors.grey[500])),
                   ],
                 ),
               );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16), // Padding trên dưới cho list
              itemCount: posts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 24), // Khoảng cách giữa các bài viết thoáng hơn
              itemBuilder: (ctx, i) => PostCard(post: posts[i]),
            );
          },
        );
      },
    );
  }
}