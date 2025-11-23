import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/post_model.dart';
import '../../../providers/post_provider.dart';

// Import 2 file quan trọng từ app của User
import '../../home/widgets/post_card.dart';
import '../../home/widgets/comment_bottom_sheet.dart';

class AdminPostsTab extends StatefulWidget {
  const AdminPostsTab({super.key});

  @override
  State<AdminPostsTab> createState() => _AdminPostsTabState();
}

class _AdminPostsTabState extends State<AdminPostsTab> {
  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    return StreamBuilder<List<PostModel>>(
      // Lấy tất cả bài viết, sắp xếp mới nhất
      stream: postProvider.postService.getPostsStream(
        postType: 'community', // Lấy bài 'community'. Bạn có thể đổi thành 'brand' hoặc null để lấy tất cả
        sortBy: 'newest',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return const Center(
            child: Text("Chưa có bài viết nào", style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }

        // Dùng Center + Container để giới hạn chiều rộng trên Web cho đẹp
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600), // Giới hạn chiều rộng
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: posts.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 20), // Khoảng cách giữa các bài
              itemBuilder: (context, index) {
                final post = posts[index];

                // Dùng Stack để đè nút Xóa lên PostCard gốc
                return Stack(
                  clipBehavior: Clip.none, // Cho phép nút Xóa tràn ra ngoài
                  children: [
                    // 1. PostCard gốc (y hệt bên User)
                    PostCard(post: post),

                    // 2. Nút Xóa (Quyền Admin)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildDeleteButton(post.id),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Nút Xóa của Admin
  Widget _buildDeleteButton(String postId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
          )
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.delete_forever, color: Colors.red),
        tooltip: 'Xóa bài viết này (Admin)',
        onPressed: () => _confirmDeletePost(postId),
      ),
    );
  }

  // Dialog xác nhận Xóa
  void _confirmDeletePost(String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa bài viết?"),
        content: const Text("Bạn có chắc chắn muốn xóa vĩnh viễn bài viết này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog
              
              // Gọi hàm xóa từ Provider
              final success = await Provider.of<PostProvider>(context, listen: false).deletePost(postId);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "Đã xóa bài viết" : "Lỗi khi xóa"),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }
}