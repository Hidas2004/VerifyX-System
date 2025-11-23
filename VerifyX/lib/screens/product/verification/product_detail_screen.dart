import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../models/product_model.dart';
import '../../../core/constants/app_colors.dart';
import '../report/report_product_screen.dart';
import '../../../providers/verification_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT DETAIL SCREEN - Chi tiết sản phẩm đã xác thực
/// ═══════════════════════════════════════════════════════════════════════════
class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  final bool blockchainVerified;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.blockchainVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportProductScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            _buildStatusBanner(),
            
            // Product Image
            if (product.imageUrl != null) ...[
              const SizedBox(height: 16),
              _buildProductImage(),
            ],
            
            const SizedBox(height: 24),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 24),
                  _buildVerificationInfo(),
                  const SizedBox(height: 24),
                  _buildSupplyChainInfo(),
                  const SizedBox(height: 24),
                  _buildBlockchainInfo(),
                  const SizedBox(height: 24),
                  _buildBlockchainHistorySection(context),
                  const SizedBox(height: 24),
                  _buildQRCode(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: blockchainVerified ? AppColors.success : AppColors.warning,
      child: Row(
        children: [
          Icon(
            blockchainVerified ? Icons.verified : Icons.warning,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blockchainVerified ? 'SẢN PHẨM CHÍNH HÃNG' : 'CẢNH BÁO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  blockchainVerified
                      ? 'Đã xác thực qua Blockchain'
                      : 'Chưa xác thực được Blockchain',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(product.imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.brandName,
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationInfo() {
    return _buildSection(
      title: 'Thông tin xác thực',
      icon: Icons.verified_user,
      children: [
        _buildInfoRow('Mã serial', product.serialNumber),
        _buildInfoRow(
          'Số lần kiểm tra',
          '${product.verificationCount} lần',
        ),
        if (product.lastVerification != null)
          _buildInfoRow(
            'Kiểm tra gần nhất',
            _formatDate(product.lastVerification!),
          ),
      ],
    );
  }

  Widget _buildSupplyChainInfo() {
    return _buildSection(
      title: 'Truy xuất nguồn gốc',
      icon: Icons.account_tree,
      children: [
        _buildInfoRow('Nhà sản xuất', product.manufacturer),
        _buildInfoRow(
          'Ngày sản xuất',
          _formatDate(product.manufacturingDate),
        ),
        _buildInfoRow(
          'Ngày nhập kho',
          _formatDate(product.warehouseDate),
        ),
        if (product.distributor != null)
          _buildInfoRow('Nhà phân phối', product.distributor!),
        if (product.distributionDate != null)
          _buildInfoRow(
            'Ngày phân phối',
            _formatDate(product.distributionDate!),
          ),
        if (product.retailer != null)
          _buildInfoRow('Nhà bán lẻ', product.retailer!),
        if (product.retailLocation != null)
          _buildInfoRow('Địa điểm', product.retailLocation!),
      ],
    );
  }

  Widget _buildBlockchainInfo() {
    return _buildSection(
      title: 'Blockchain',
      icon: Icons.lock_clock,
      children: [
        _buildInfoRow(
          'Trạng thái',
          blockchainVerified ? 'Đã xác thực' : 'Chưa xác thực',
          valueColor: blockchainVerified ? AppColors.success : AppColors.error,
        ),
        _buildInfoRow('Hash', product.blockchainHash, isHash: true),
      ],
    );
  }

  Widget _buildQRCode() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Mã QR sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: product.qrCode,
              size: 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainHistorySection(BuildContext context) {
    return Consumer<VerificationProvider>(
      builder: (context, provider, child) {
        final history = provider.blockchainHistory;

        final entries = <Widget>[];
        if (history.isEmpty) {
          entries.add(
            const Text(
              'Chưa có lịch sử quét trên blockchain cho sản phẩm này.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          );
        } else {
          for (var i = 0; i < history.length; i++) {
            final item = history[i];
            if (item is Map<String, dynamic>) {
              entries.add(_buildHistoryItem(item, i));
            }
            if (i < history.length - 1) {
              entries.add(const Divider(height: 20));
            }
          }
        }

        return _buildSection(
          title: 'Lịch sử Blockchain',
          icon: Icons.alt_route,
          children: entries,
        );
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> record, int index) {
    final timestampRaw = record['timestamp'] as String? ?? '';
    DateTime? timestamp;
    if (timestampRaw.isNotEmpty) {
      try {
        timestamp = DateTime.parse(timestampRaw);
      } catch (_) {
        timestamp = null;
      }
    }

    final location = record['location'] as String? ?? 'Khong ro dia diem';
    final status = record['status'] as String? ?? 'Khong ro trang thai';
    final actor = record['actor'] as String? ?? 'Khong xac dinh';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bước ${index + 1}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          'Địa điểm: $location',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          'Thực hiện bởi: $actor',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        if (timestamp != null) ...[
          const SizedBox(height: 2),
          Text(
            'Thời gian: ${_formatDateTime(timestamp)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isHash = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isHash ? '${value.substring(0, 20)}...' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final datePart = _formatDate(dateTime);
    final timePart =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$datePart $timePart';
  }
}
