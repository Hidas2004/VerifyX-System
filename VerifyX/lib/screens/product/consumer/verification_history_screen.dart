import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/verification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/verification_record_model.dart';
import '../../../core/constants/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VERIFICATION HISTORY SCREEN - Lịch sử xác thực của Consumer
/// ═══════════════════════════════════════════════════════════════════════════
class VerificationHistoryScreen extends StatefulWidget {
  const VerificationHistoryScreen({super.key});

  @override
  State<VerificationHistoryScreen> createState() =>
      _VerificationHistoryScreenState();
}

class _VerificationHistoryScreenState extends State<VerificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final verificationProvider =
        Provider.of<VerificationProvider>(context, listen: false);

    final userModel = authProvider.userModel;
    if (userModel != null) {
      await verificationProvider.loadUserHistory(userModel.uid);
      await verificationProvider.loadUserStatistics(userModel.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử xác thực'),
      ),
      body: Column(
        children: [
          // Statistics
          Consumer<VerificationProvider>(
            builder: (context, provider, child) {
              if (provider.statistics != null) {
                return _buildStatistics(provider.statistics!);
              }
              return const SizedBox.shrink();
            },
          ),

          // History List
          Expanded(
            child: Consumer<VerificationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.verificationHistory.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.verificationHistory.length,
                    itemBuilder: (context, index) {
                      final record = provider.verificationHistory[index];
                      return _buildHistoryCard(record);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Tổng số lần',
            '${stats['totalVerifications'] ?? 0}',
            Icons.check_circle,
          ),
          _buildStatItem(
            'Chính hãng',
            '${stats['authenticProducts'] ?? 0}',
            Icons.verified,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(VerificationRecordModel record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: record.isAuthentic
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    record.isAuthentic ? Icons.verified : Icons.warning,
                    color: record.isAuthentic ? AppColors.success : AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.isAuthentic ? 'Sản phẩm chính hãng' : 'Cảnh báo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: record.isAuthentic
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(record.verificationDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMethodBadge(record.verificationMethod),
              ],
            ),

            const SizedBox(height: 12),

            // Serial Number
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.serialNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Blockchain Status
            Row(
              children: [
                Icon(
                  record.blockchainVerified ? Icons.lock : Icons.lock_open,
                  size: 14,
                  color: record.blockchainVerified
                      ? AppColors.success
                      : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  record.blockchainVerified
                      ? 'Đã xác thực Blockchain'
                      : 'Chưa xác thực Blockchain',
                  style: TextStyle(
                    fontSize: 12,
                    color: record.blockchainVerified
                        ? AppColors.success
                        : Colors.orange,
                  ),
                ),
              ],
            ),

            if (record.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    record.location!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodBadge(String method) {
    final isQR = method == 'qr';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isQR
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isQR ? Icons.qr_code_scanner : Icons.keyboard,
            size: 12,
            color: isQR ? Colors.blue : Colors.purple,
          ),
          const SizedBox(width: 4),
          Text(
            isQR ? 'QR' : 'Serial',
            style: TextStyle(
              fontSize: 10,
              color: isQR ? Colors.blue : Colors.purple,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có lịch sử xác thực',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Xác thực sản phẩm để xem lịch sử',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${diff.inMinutes} phút trước';
      }
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
