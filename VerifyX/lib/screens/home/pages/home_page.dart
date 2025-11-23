import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/post_provider.dart';
import '../widgets/create_post_button.dart';
import '../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Lấy PostProvider để access state & methods
    final postProvider = Provider.of<PostProvider>(context);

    // 💡 THAY ĐỔI: Bỏ Scaffold và AppBar
    // return Scaffold( ... appBar: ... body: ... )
    // Thay bằng Container đơn giản, vì Scaffold đã có ở 'web_home_layout.dart'
    return Container(
      color: Colors.transparent, // Nền trong suốt để lộ màu nền xám
      child: Column(
        children: [
          // 💡 THAY ĐỔI: Bọc CreatePostButton trong Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CreatePostButton(
              onFilterChanged: (filterType) {
                // Gọi Provider để thay đổi filter
                postProvider.setFilter(filterType);
              },
              onSortChanged: (sortType) {
                // Gọi Provider để thay đổi sort
                postProvider.setSort(sortType);
              },
            ),
          ),

          // 💡 THAY ĐỔI: Bỏ Divider và thay bằng khoảng cách
          // const Divider(height: 8, thickness: 8, color: Color(0xFFF0F2F5)),
          const SizedBox(height: 24),

          // Feed: Danh sách bài viết
          Expanded(
            child: _buildPostsFeed(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsFeed() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        // Lấy stream từ PostService thông qua Provider
        return StreamBuilder(
          stream: postProvider.postService.getPostsStream(
            postType: postProvider.currentFilter,
            sortBy: postProvider.currentSort,
          ),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
                ),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
            }

            // Empty state
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Chưa có bài viết nào.'));
            }

            // Data state - Có bài viết
            final posts = snapshot.data!;

            // 💡 THAY ĐỔI: Dùng ListView.builder thay vì Separated
            // Khoảng cách sẽ được thêm bằng 'margin' trong PostCard
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                
                // Sử dụng PostCard widget riêng - truyền PostModel
                return PostCard(post: post);
              },
            );
          },
        );
      },
    );
  }
}