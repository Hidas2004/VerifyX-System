import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/report_provider.dart';
import '../../../models/report_model.dart';
import '../../../core/constants/app_colors.dart';
import 'report_detail_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ADMIN REPORTS SCREEN - Admin quản lý báo cáo
/// ═══════════════════════════════════════════════════════════════════════════
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    await provider.loadAllReports();
    await provider.loadPendingReports();
    await provider.loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý báo cáo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ xử lý'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Đã xử lý'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Statistics
          Consumer<ReportProvider>(
            builder: (context, provider, child) {
              if (provider.statistics != null) {
                return _buildStatistics(provider.statistics!);
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Reports List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsList(null),
                _buildReportsList('pending'),
                _buildReportsList('reviewing'),
                _buildReportsList('resolved'),
              ],
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
          colors: [AppColors.error, AppColors.error.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Tổng',
                '${stats['total'] ?? 0}',
                Icons.report,
              ),
              _buildStatItem(
                'Chờ xử lý',
                '${stats['pending'] ?? 0}',
                Icons.pending,
              ),
              _buildStatItem(
                'Ưu tiên cao',
                '${stats['highPriority'] ?? 0}',
                Icons.priority_high,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
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

  Widget _buildReportsList(String? status) {
    return Consumer<ReportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<ReportModel> reports;
        if (status == null) {
          reports = provider.reports;
        } else if (status == 'pending') {
          reports = provider.pendingReports;
        } else {
          reports = provider.reports
              .where((r) => r.status == status)
              .toList();
        }

        if (reports.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: _loadReports,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportCard(report);
            },
          ),
        );
      },
    );
  }

  Widget _buildReportCard(ReportModel report) {
    Color statusColor;
    IconData statusIcon;
    
    switch (report.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'reviewing':
        statusColor = Colors.blue;
        statusIcon = Icons.rate_review;
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(report: report),
            ),
          ).then((_) => _loadReports());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getReportTypeLabel(report.reportType),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Báo cáo bởi ${report.userName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPriorityBadge(report.priority),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            report.serialNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (report.isVerifiedOnChain)
                    const Row(
                      children: [
                        Icon(Icons.verified, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Blockchain',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    String label;
    
    switch (priority) {
      case 'critical':
        color = Colors.red;
        label = 'Khẩn cấp';
        break;
      case 'high':
        color = Colors.orange;
        label = 'Cao';
        break;
      case 'medium':
        color = Colors.yellow[700]!;
        label = 'Trung bình';
        break;
      case 'low':
        color = Colors.green;
        label = 'Thấp';
        break;
      default:
        color = Colors.grey;
        label = priority;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? status) {
    String message = 'Chưa có báo cáo nào';
    if (status == 'pending') {
      message = 'Không có báo cáo chờ xử lý';
    } else if (status == 'reviewing') {
      message = 'Không có báo cáo đang xử lý';
    } else if (status == 'resolved') {
      message = 'Chưa có báo cáo nào được xử lý';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTypeLabel(String type) {
    switch (type) {
      case 'counterfeit':
        return 'Hàng giả';
      case 'damaged':
        return 'Hàng hỏng';
      case 'expired':
        return 'Hết hạn';
      case 'mislabeled':
        return 'Sai nhãn';
      default:
        return 'Khác';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
