import 'package:flutter/material.dart';

class WebRightSidebar extends StatelessWidget {
  const WebRightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Chiều rộng cố định
      // 💡 THAY ĐỔI: Chỉ padding chiều dọc, vì padding ngang đã có ở layout chính
      padding: const EdgeInsets.symmetric(vertical: 24),
      
      // 💡 THAY ĐỔI: Bỏ decoration (màu nền) của cả cột
      // color: Colors.white, // XÓA DÒNG NÀY
      // border: ... // XÓA LUÔN

      // 💡 THAY ĐỔI: Dùng ListView để nội dung có thể cuộn
      child: ListView(
        padding: const EdgeInsets.only(right: 24), // Thêm padding phải
        children: [
          // 💡 THAY ĐỔI: Bọc nội dung trong Card
          _buildInfoCard(
            title: "Friend Suggestions",
            child: Column(
              children: [
                _buildUserTile("Julia Smith", "@juliasmith"),
                _buildUserTile("Vermilion D. Gray", "@vermiliongray"),
                _buildUserTile("Mai Senpai", "@maisenpai"),
                _buildUserTile("Azunyan U. Wu", "@azunyandesu"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 💡 THAY ĐỔI: Bọc nội dung trong Card
          _buildInfoCard(
            title: "Profile Activity",
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "+1,158 Followers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "You gained a substantial amount of followers this month!",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                )
                // ... thêm nội dung placeholder khác
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💡 THAY ĐỔI: Widget con để build user tile
  Widget _buildUserTile(String name, String handle) {
    return ListTile(
      leading: CircleAvatar(child: Text(name.substring(0, 1))),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(handle),
      trailing:
          Icon(Icons.add_circle_outline, color: const Color(0xFF4A4DE6)),
      contentPadding: EdgeInsets.zero,
    );
  }

  // 💡 THAY ĐỔI: Widget helper để tạo Card giống ảnh mẫu
  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header của Card (ví dụ: Friend Suggestions)
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Nội dung của Card
          child,
        ],
      ),
    );
  }
}