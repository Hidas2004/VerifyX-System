import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../post/create_post_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CREATE POST BUTTON - Nút tạo bài viết (Header giống Facebook)
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Widget hiển thị:
/// - Avatar người dùng bên trái với dấu + để tạo bài
/// - Nút filter "Cộng đồng" / "Brand"
/// - Icon lọc bài viết
/// 
/// Callback:
/// - onFilterChanged: Khi user chọn tab khác (community/brand)
/// - onSortChanged: Khi user chọn cách sắp xếp
/// ═══════════════════════════════════════════════════════════════════════════
class CreatePostButton extends StatefulWidget {
  /// Callback khi thay đổi filter (community/brand)
  final Function(String filterType) onFilterChanged;
  
  /// Callback khi thay đổi cách sắp xếp
  final Function(String sortType) onSortChanged;
  
  const CreatePostButton({
    super.key,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  State<CreatePostButton> createState() => _CreatePostButtonState();
}

class _CreatePostButtonState extends State<CreatePostButton> {
  /// Tab đang được chọn: 'community' hoặc 'brand'
  String _selectedFilter = 'community';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final photoURL = userData?['photoURL'];
        final displayName = userData?['displayName'] ?? 'User';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              // Avatar với dấu + (giống Instagram Story)
              Stack(
                children: [
                  // Avatar người dùng
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF00BCD4),
                    backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                    child: photoURL == null
                        ? Text(
                            displayName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                  // Dấu + ở góc phải dưới - Nhấn vào để tạo bài
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Nhấn vào dấu + để tạo bài viết
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreatePostScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Nút "Cộng đồng"
              _buildFilterButton(
                context,
                label: 'Cộng đồng',
                isSelected: _selectedFilter == 'community',
                onTap: () {
                  setState(() {
                    _selectedFilter = 'community';
                  });
                  widget.onFilterChanged('community');
                },
              ),
              
              const SizedBox(width: 8),
              
              // Nút "Brand"
              _buildFilterButton(
                context,
                label: 'Brand',
                isSelected: _selectedFilter == 'brand',
                onTap: () {
                  setState(() {
                    _selectedFilter = 'brand';
                  });
                  widget.onFilterChanged('brand');
                },
              ),
              
              const Spacer(),
              
              // Icon Lọc
              IconButton(
                icon: const Icon(Icons.filter_list, color: Color(0xFF00BCD4)),
                onPressed: () {
                  _showFilterBottomSheet(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Nút filter (Cộng đồng / Brand)
  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Bottom Sheet Lọc bài viết
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Text(
                  'Lọc bài viết',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lọc theo tương tác
            const Text(
              'Sắp xếp theo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            
            // Mới nhất
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF00BCD4)),
              title: const Text('Mới nhất'),
              onTap: () {
                Navigator.pop(context);
                widget.onSortChanged('newest');
              },
            ),
            
            // Cũ nhất
            ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: const Text('Cũ nhất'),
              onTap: () {
                Navigator.pop(context);
                widget.onSortChanged('oldest');
              },
            ),
            
            const Divider(),
            
            // Nhiều tim nhất
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text('Nhiều tim nhất'),
              onTap: () {
                Navigator.pop(context);
                widget.onSortChanged('mostLiked');
              },
            ),
            
            // Nhiều bình luận nhất
            ListTile(
              leading: const Icon(Icons.comment, color: Colors.blue),
              title: const Text('Nhiều bình luận nhất'),
              onTap: () {
                Navigator.pop(context);
                widget.onSortChanged('mostCommented');
              },
            ),
          ],
        ),
      ),
    );
  }
}
