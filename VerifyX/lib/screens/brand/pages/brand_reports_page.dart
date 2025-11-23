import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// BRAND REPORTS PAGE - Tab báo cáo
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Tab 3 của Brand - Báo cáo và thống kê
/// - Báo cáo doanh số
/// - Thống kê xác thực sản phẩm
/// - Phân tích xu hướng
/// - Báo cáo hàng giả
/// 
/// ═══════════════════════════════════════════════════════════════════════════
class BrandReportsPage extends StatefulWidget {
  const BrandReportsPage({super.key});

  @override
  State<BrandReportsPage> createState() => _BrandReportsPageState();
}

class _BrandReportsPageState extends State<BrandReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Báo cáo & Thống kê',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card: Thống kê tổng quan
          _buildOverviewCard(),
          
          const SizedBox(height: 16),
          
          // Card: Báo cáo xác thực
          _buildVerificationReportCard(),
          
          const SizedBox(height: 16),
          
          // Card: Báo cáo sản phẩm giả
          _buildFakeProductReportCard(),
          
          const SizedBox(height: 16),
          
          // Card: Phân tích xu hướng
          _buildTrendAnalysisCard(),
        ],
      ),
    );
  }

  /// Card tổng quan
  Widget _buildOverviewCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Thống kê tổng quan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Tổng sản phẩm', '0', Icons.inventory_2),
            const Divider(),
            _buildStatRow('Lượt xác thực', '0', Icons.verified_user),
            const Divider(),
            _buildStatRow('Sản phẩm giả phát hiện', '0', Icons.warning),
          ],
        ),
      ),
    );
  }

  /// Card báo cáo xác thực
  Widget _buildVerificationReportCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Báo cáo xác thực đang phát triển')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.verified_outlined, color: Colors.green[700], size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Báo cáo xác thực',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Xem chi tiết lượt quét mã sản phẩm',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// Card báo cáo sản phẩm giả
  Widget _buildFakeProductReportCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Báo cáo sản phẩm giả đang phát triển')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.report_problem_outlined, color: Colors.red[700], size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Báo cáo sản phẩm giả',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Danh sách sản phẩm bị báo cáo giả',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// Card phân tích xu hướng
  Widget _buildTrendAnalysisCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phân tích xu hướng đang phát triển')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.trending_up, color: Colors.purple[700], size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phân tích xu hướng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Xu hướng sử dụng và xác thực sản phẩm',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// Row hiển thị số liệu thống kê
  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BCD4),
            ),
          ),
        ],
      ),
    );
  }
}
