import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../models/report_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// REPORTS MANAGEMENT PAGE - ⚠️ Báo cáo & Phản hồi
/// ═══════════════════════════════════════════════════════════════════════════
/// Quản lý phản ánh của người tiêu dùng:
/// - Danh sách sản phẩm bị báo cáo là "nghi ngờ"
/// - Xem hình ảnh minh chứng
/// - Gửi phản hồi (trả lời hoặc xác nhận là hàng giả)
/// - Cập nhật tiến trình xử lý (ghi log lên Blockchain)
/// ═══════════════════════════════════════════════════════════════════════════
class ReportsManagementPage extends StatefulWidget {
  const ReportsManagementPage({super.key});

  @override
  State<ReportsManagementPage> createState() => _ReportsManagementPageState();
}

class _ReportsManagementPageState extends State<ReportsManagementPage> {
  bool _isLoading = false;
  List<ReportModel> _reports = [];
  String _filterStatus = 'all'; // all, pending, resolved, rejected

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    // TODO: Load from provider
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _reports = [];
      _isLoading = false;
    });
  }

  List<ReportModel> get _filteredReports {
    if (_filterStatus == 'all') return _reports;
    return _reports.where((r) => r.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Báo cáo'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(value: 'pending', child: Text('Chờ xử lý')),
              const PopupMenuItem(value: 'resolved', child: Text('Đã xử lý')),
              const PopupMenuItem(value: 'rejected', child: Text('Từ chối')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredReports.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    itemCount: _filteredReports.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(_filteredReports[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _filterStatus == 'all'
                ? 'Chưa có báo cáo nào'
                : 'Không tìm thấy báo cáo',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final statusColor = _getStatusColor(report.status);
    final severityColor = _getSeverityColor(report.reportType);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: severityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getReportTypeText(report.reportType),
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusText(report.status),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Báo cáo #${report.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                report.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    report.userName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSeverityColor(String type) {
    switch (type) {
      case 'fake':
        return Colors.red;
      case 'suspicious':
        return Colors.orange;
      case 'damaged':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'resolved':
        return 'Đã xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  String _getReportTypeText(String type) {
    switch (type) {
      case 'fake':
        return 'Hàng giả';
      case 'suspicious':
        return 'Nghi ngờ';
      case 'damaged':
        return 'Hư hỏng';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showReportDetails(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Báo cáo #${report.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (report.images.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    child: Image.network(
                      report.images.first,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _buildInfoRow('Loại:', _getReportTypeText(report.reportType)),
                _buildInfoRow('Trạng thái:', _getStatusText(report.status)),
                _buildInfoRow('Người báo cáo:', report.userName),
                _buildInfoRow('Thời gian:', '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}'),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(report.description, style: const TextStyle(height: 1.5)),
                const SizedBox(height: 24),
                if (report.status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _rejectReport(report);
                          },
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text('Từ chối'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _resolveReport(report);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Xử lý'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _resolveReport(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xử lý báo cáo'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Phản hồi',
            hintText: 'Nhập phản hồi cho người báo cáo...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xử lý báo cáo'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadReports();
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _rejectReport(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối báo cáo'),
        content: const Text('Bạn có chắc muốn từ chối báo cáo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã từ chối báo cáo'),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadReports();
            },
            child: const Text('Từ chối', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
