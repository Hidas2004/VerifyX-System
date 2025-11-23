import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// EMPTY STATE - Hiển thị empty data state
/// ═══════════════════════════════════════════════════════════════════════════
class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final Widget? action;
  final String? imagePath;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon hoặc Image
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 200,
                height: 200,
              )
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 100,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            
            const SizedBox(height: AppSizes.paddingXL),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: AppSizes.fontXL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (message != null) ...[
              const SizedBox(height: AppSizes.paddingMD),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: AppSizes.fontMD,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Action button
            if (action != null) ...[
              const SizedBox(height: AppSizes.paddingXL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// EMPTY STATE VARIANTS - Các biến thể phổ biến
/// ═══════════════════════════════════════════════════════════════════════════

/// Empty list
class EmptyList extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const EmptyList({
    super.key,
    this.message,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Không có dữ liệu',
      message: message ?? 'Danh sách trống',
      icon: Icons.list_alt_outlined,
      action: onRefresh != null
          ? ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Làm mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            )
          : null,
    );
  }
}

/// Empty search results
class EmptySearchResults extends StatelessWidget {
  final String? query;

  const EmptySearchResults({
    super.key,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Không tìm thấy kết quả',
      message: query != null
          ? 'Không có kết quả cho "$query"'
          : 'Thử tìm kiếm với từ khóa khác',
      icon: Icons.search_off,
    );
  }
}

/// No notifications
class EmptyNotifications extends StatelessWidget {
  const EmptyNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Không có thông báo',
      message: 'Bạn chưa có thông báo nào',
      icon: Icons.notifications_none,
    );
  }
}

/// No favorites
class EmptyFavorites extends StatelessWidget {
  final VoidCallback? onBrowse;

  const EmptyFavorites({
    super.key,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'Chưa có yêu thích',
      message: 'Bạn chưa thêm sản phẩm nào vào danh sách yêu thích',
      icon: Icons.favorite_border,
      action: onBrowse != null
          ? ElevatedButton(
              onPressed: onBrowse,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Khám phá ngay'),
            )
          : null,
    );
  }
}

/// No history
class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Chưa có lịch sử',
      message: 'Bạn chưa thực hiện thao tác nào',
      icon: Icons.history,
    );
  }
}

/// No messages
class EmptyMessages extends StatelessWidget {
  const EmptyMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      title: 'Chưa có tin nhắn',
      message: 'Bắt đầu trò chuyện với bạn bè',
      icon: Icons.chat_bubble_outline,
    );
  }
}
