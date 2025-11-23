import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../models/post_model.dart';
import '../../../providers/post_provider.dart';
import 'comment_bottom_sheet.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = post.isLikedBy(currentUserId);

    // 💡 THAY ĐỔI: Đây là phần quan trọng nhất để tạo giao diện Card
    return Container(
      // 💡 THÊM: Khoảng cách (margin) bên dưới mỗi card
      margin: const EdgeInsets.only(bottom: 24),
      // 💡 THÊM: Để bo góc các widget con bên trong (như hình ảnh)
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        // 💡 THÊM: Bo góc
        borderRadius: BorderRadius.circular(12),
        // 💡 THÊM: Đổ bóng
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // 💡 THAY ĐỔI: Bỏ padding dọc, để các widget con tự padding
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💡 THAY ĐỔI: Thêm padding cho header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _buildPostHeader(context),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(post.content, style: const TextStyle(fontSize: 15)),
            ),
          
          // 💡 THAY ĐỔI: Thêm khoảng cách nếu có ảnh
          if (post.imageUrls.isNotEmpty) const SizedBox(height: 8),
          if (post.imageUrls.isNotEmpty) _buildImages(),

          // 💡 THAY ĐỔI: Thêm padding cho stats
          Padding(
             padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: _buildStats(),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'Thích',
                  color: isLiked ? Colors.red : Colors.grey[600]!,
                  onTap: () => _handleLike(context),
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  label: 'Bình luận',
                  color: Colors.grey[600]!,
                  onTap: () => _handleComment(context),
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.share_outlined,
                  label: 'Chia sẻ',
                  color: Colors.grey[600]!,
                  onTap: () => _handleShare(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    // 💡 THAY ĐỔI: Bỏ Padding (đã thêm ở widget cha)
    // padding: const EdgeInsets.symmetric(horizontal: 12),
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF00BCD4),
          backgroundImage: post.authorPhotoUrl != null
              ? NetworkImage(post.authorPhotoUrl!)
              : null,
          child: post.authorPhotoUrl == null
              ? Text(
                  post.authorName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatTime(post.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => _showPostMenu(context),
        ),
      ],
    );
  }

  Widget _buildImages() {
    if (post.imageUrls.length == 1) {
      // 💡 THAY ĐỔI: Bỏ ClipRRect, vì 'clipBehavior' ở Container cha đã xử lý
      return Image.network(
        post.imageUrls[0],
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStats() {
    // 💡 THAY ĐỔI: Bỏ Padding (đã thêm ở widget cha)
    // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '${post.likesCount} lượt thích',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const Spacer(),
          Text(
            '${post.commentsCount} bình luận',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

 // ... (Phần còn lại của file giữ nguyên) ...
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLike(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.toggleLike(post.id);
  }

  void _handleComment(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ChangeNotifierProvider<PostProvider>.value(
          value: postProvider,
          child: CommentBottomSheet(post: post),
        );
      },
    );
  }

  void _handleShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng chia sẻ đang phát triển')),
    );
  }

  void _showPostMenu(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (post.authorId != currentUserId) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Xóa bài viết',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa bài viết?'),
          content: const Text('Bạn có chắc chắn muốn xóa bài viết này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final postProvider = Provider.of<PostProvider>(
                  context,
                  listen: false,
                );
                postProvider.deletePost(post.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}