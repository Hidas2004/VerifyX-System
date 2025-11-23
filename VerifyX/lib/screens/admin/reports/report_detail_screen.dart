import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/report_model.dart';
import '../../../providers/report_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// REPORT DETAIL SCREEN - Chi tiết báo cáo và xử lý
/// ═══════════════════════════════════════════════════════════════════════════
class ReportDetailScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final _responseController = TextEditingController();
  String _selectedStatus = 'reviewing';
  String _selectedPriority = 'medium';

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.report.status;
    _selectedPriority = widget.report.priority;
    if (widget.report.adminResponse != null) {
      _responseController.text = widget.report.adminResponse!;
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _updateReport() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    final userModel = authProvider.userModel;
    if (userModel == null) return;

    final success = await reportProvider.updateReportStatus(
      reportId: widget.report.id,
      status: _selectedStatus,
      priority: _selectedPriority,
      adminResponse: _responseController.text.trim().isEmpty 
          ? null 
          : _responseController.text.trim(),
      resolvedBy: (_selectedStatus == 'resolved' || _selectedStatus == 'rejected')
          ? userModel.uid
          : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật báo cáo'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reportProvider.error ?? 'Không thể cập nhật'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết báo cáo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            _buildStatusBanner(),
            
            const SizedBox(height: 24),
            
            // Report Info
            _buildSection(
              title: 'Thông tin báo cáo',
              icon: Icons.report,
              children: [
                _buildInfoRow('Loại báo cáo', _getReportTypeLabel(widget.report.reportType)),
                _buildInfoRow('Mã serial', widget.report.serialNumber),
                _buildInfoRow('Người báo cáo', widget.report.userName),
                _buildInfoRow('Ngày báo cáo', _formatDate(widget.report.createdAt)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Description
            _buildSection(
              title: 'Mô tả',
              icon: Icons.description,
              children: [
                Text(
                  widget.report.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Blockchain Info
            _buildSection(
              title: 'Blockchain',
              icon: Icons.lock_clock,
              children: [
                _buildInfoRow(
                  'Trạng thái',
                  widget.report.isVerifiedOnChain ? 'Đã xác thực' : 'Chưa xác thực',
                ),
                _buildInfoRow('Hash', widget.report.blockchainHash, isHash: true),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Admin Actions
            const Text(
              'Xử lý báo cáo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Dropdown
            _buildDropdown(
              label: 'Trạng thái',
              value: _selectedStatus,
              items: const [
                {'value': 'pending', 'label': 'Chờ xử lý'},
                {'value': 'reviewing', 'label': 'Đang xử lý'},
                {'value': 'resolved', 'label': 'Đã xử lý'},
                {'value': 'rejected', 'label': 'Từ chối'},
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Priority Dropdown
            _buildDropdown(
              label: 'Độ ưu tiên',
              value: _selectedPriority,
              items: const [
                {'value': 'low', 'label': 'Thấp'},
                {'value': 'medium', 'label': 'Trung bình'},
                {'value': 'high', 'label': 'Cao'},
                {'value': 'critical', 'label': 'Khẩn cấp'},
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Response
            CustomTextField(
              controller: _responseController,
              labelText: 'Phản hồi của Admin',
              hintText: 'Nhập phản hồi...',
              maxLines: 5,
            ),
            
            const SizedBox(height: 24),
            
            // Submit Button
            Consumer<ReportProvider>(
              builder: (context, provider, child) {
                return CustomButton(
                  text: 'Cập nhật báo cáo',
                  onPressed: provider.isLoading ? null : _updateReport,
                  isLoading: provider.isLoading,
                  icon: Icons.save,
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Existing Response
            if (widget.report.adminResponse != null) ...[
              _buildSection(
                title: 'Phản hồi trước đó',
                icon: Icons.history,
                children: [
                  Text(widget.report.adminResponse!),
                ],
              ),
            ],
            
            if (widget.report.brandResponse != null) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Phản hồi từ Brand',
                icon: Icons.business,
                children: [
                  Text(widget.report.brandResponse!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color color;
    String status;
    
    switch (widget.report.status) {
      case 'pending':
        color = Colors.orange;
        status = 'CHỜ XỬ LÝ';
        break;
      case 'reviewing':
        color = Colors.blue;
        status = 'ĐANG XỬ LÝ';
        break;
      case 'resolved':
        color = Colors.green;
        status = 'ĐÃ XỬ LÝ';
        break;
      case 'rejected':
        color = Colors.red;
        status = 'ĐÃ TỪ CHỐI';
        break;
      default:
        color = Colors.grey;
        status = widget.report.status.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

  Widget _buildInfoRow(String label, String value, {bool isHash = false}) {
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: onChanged,
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
