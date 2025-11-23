import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/post_provider.dart';
import '../../home/widgets/create_post_button.dart';
import '../../home/widgets/post_card.dart';

class BrandCommunityPage extends StatefulWidget {
  const BrandCommunityPage({super.key});

  @override
  State<BrandCommunityPage> createState() => _BrandCommunityPageState();
}

class _BrandCommunityPageState extends State<BrandCommunityPage> {
  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    // 💡 THAY ĐỔI: Xóa Scaffold và AppBar
    // return Scaffold(
    //   appBar: AppBar( ... ),
    //   body: Column( ... )
    // );
    
    // 💡 THAY ĐỔI: Trả về trực tiếp nội dung
    return Column(
      children: [
        // 💡 THAY ĐỔI: Bọc CreatePostButton trong Card (giống HomePage)
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
              postProvider.setFilter(filterType);
            },
            onSortChanged: (sortType) {
              postProvider.setSort(sortType);
            },
          ),
        ),
        
        // 💡 THAY ĐỔI: Bỏ Divider và thay bằng khoảng cách
        // const Divider(height: 8, thickness: 8, color: Color(0xFFF0F2F5)),
        const SizedBox(height: 24),
        
        // Feed bài viết
        Expanded(
          child: _buildPostsFeed(),
        ),
      ],
    );
  }

  /// Feed bài viết
  Widget _buildPostsFeed() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        return StreamBuilder(
          stream: postProvider.postService.getPostsStream(
            postType: postProvider.currentFilter,
            sortBy: postProvider.currentSort,
          ),
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  // 💡 THAY ĐỔI: Màu cyan -> xanh đậm
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A4DE6)),
                ),
              );
            }

            // Error
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // Empty
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                // ... (giữ nguyên)
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.post_add, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài viết nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy là Brand đầu tiên đăng bài!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Data - Có bài viết
            final posts = snapshot.data!;
            
            // 💡 THAY ĐỔI: Dùng ListView.builder
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(post: post);
              },
            );
          },
        );
      },
    );
  }
}