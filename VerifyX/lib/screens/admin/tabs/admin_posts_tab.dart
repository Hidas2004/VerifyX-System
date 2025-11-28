import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/post_model.dart';
import '../../../providers/post_provider.dart';
import '../../home/widgets/post_card.dart';

class AdminPostsTab extends StatefulWidget {
  const AdminPostsTab({super.key});

  @override
  State<AdminPostsTab> createState() => _AdminPostsTabState();
}

class _AdminPostsTabState extends State<AdminPostsTab> {
  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    return Column(
      children: [
        // 1. HEADER (Tiêu đề bảng)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[100],
          child: Row(
            children: const [
              SizedBox(width: 66), // Khớp với khoảng cách ảnh (50px ảnh + 16px gap)
              Expanded(flex: 3, child: Text("NỘI DUNG", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 1, child: Text("THỜI GIAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 1, child: Text("TRẠNG THÁI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
              SizedBox(width: 48), // Chừa chỗ cho nút xóa
            ],
          ),
        ),

        // 2. DANH SÁCH BÀI VIẾT (Full Width)
        Expanded(
          child: StreamBuilder<List<PostModel>>(
            stream: postProvider.postService.getPostsStream(sortBy: 'newest'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) return const Center(child: Text("Không có dữ liệu"));

              return ListView.builder(
                // 🟢 ĐÃ SỬA: Không còn maxWidth: 800 nữa, sẽ full màn hình
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: posts[index], isAdminView: true);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}