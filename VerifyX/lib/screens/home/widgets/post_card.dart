import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../models/post_model.dart';
import '../../../providers/post_provider.dart';
import 'comment_bottom_sheet.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isAdminView;

  const PostCard({super.key, required this.post, this.isAdminView = false});

  @override
  Widget build(BuildContext context) {
    // Nếu là Admin View thì dùng layout riêng (đơn giản hóa cho Admin)
    if (isAdminView) {
      return _buildAdminLayout(context);
    }
    // Consumer/Brand View: Giao diện Atomic Style đẹp
    return _buildStandardLayout(context);
  }

  // ===========================================================================
  // 🎨 GIAO DIỆN CHUẨN (ATOMIC STYLE) - CHO USER & BRAND
  // ===========================================================================
  Widget _buildStandardLayout(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = post.isLikedBy(currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // 💡 Bo góc cực lớn (30px)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Bóng mờ rất nhẹ tinh tế
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER: Avatar + Tên + Menu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(2), // Viền trắng nhỏ quanh avatar
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: post.authorPhotoUrl != null 
                        ? NetworkImage(post.authorPhotoUrl!) 
                        : null,
                    child: post.authorPhotoUrl == null 
                        ? Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : 'U') 
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Tên & Thời gian
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.authorName, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (post.isOfficial) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.blue, size: 14)
                          ]
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(post.createdAt), 
                        style: TextStyle(color: Colors.grey[500], fontSize: 11)
                      ),
                    ],
                  ),
                ),

                // Nút Menu (3 chấm)
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () => _showPostMenu(context),
                ),
              ],
            ),
          ),

          // 2. HÌNH ẢNH (Điểm nhấn chính)
          if (post.imageUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24), // Bo góc ảnh mềm mại
                child: AspectRatio(
                  aspectRatio: 1, // Tỷ lệ vuông (Instagram style) hoặc 4/3
                  child: Image.network(
                    post.imageUrls[0],
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, loading) {
                      if (loading == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (ctx, _, __) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

          // 3. THANH TƯƠNG TÁC (Dạng viên thuốc - Pill Shape)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Nút Like
                InkWell(
                  onTap: () => _handleLike(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isLiked ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey[700],
                          size: 20,
                        ),
                        if (post.likesCount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            "${post.likesCount}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isLiked ? Colors.red : Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),

                // Nút Comment
                InkWell(
                  onTap: () => _handleComment(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Colors.grey[700], size: 20),
                        if (post.commentsCount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            "${post.commentsCount}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: 13,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),

                const Spacer(),
                
                // Nút Share
                IconButton(
                  onPressed: () => _handleShare(context),
                  icon: Icon(Icons.share_outlined, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // 4. NỘI DUNG TEXT (Caption)
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Text(
                post.content,
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.4,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 🛠 GIAO DIỆN ADMIN (GIỮ NGUYÊN LOGIC CŨ CỦA BẠN)
  // ===========================================================================
  Widget _buildAdminLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              image: post.imageUrls.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(post.imageUrls[0]), fit: BoxFit.cover)
                  : null
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(post.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDeletePost(context, post.id),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ⚡ LOGIC XỬ LÝ (FUNCTIONALITIES)
  // ===========================================================================

  void _handleLike(BuildContext context) {
    // Gọi Provider để xử lý like
    Provider.of<PostProvider>(context, listen: false).toggleLike(post.id);
  }

  void _handleComment(BuildContext context) {
    // Mở BottomSheet bình luận
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để thấy được bo góc của BottomSheet
      builder: (_) => ChangeNotifierProvider.value(
        value: postProvider,
        child: CommentBottomSheet(post: post),
      ),
    );
  }

  void _handleShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng chia sẻ đang phát triển')),
    );
  }

  void _showPostMenu(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Chỉ chủ bài viết mới có quyền xóa
    if (post.authorId != currentUserId) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa bài viết', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePost(context, post.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa bài viết?"),
        content: const Text("Hành động này không thể hoàn tác."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<PostProvider>(context, listen: false).deletePost(postId);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
    
    return '${time.day}/${time.month}/${time.year}';
  }
}