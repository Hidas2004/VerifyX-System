import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/brand/verification_log_model.dart';
import '../../../../providers/verification_provider.dart';
import '../../../../providers/auth_provider.dart';

class VerificationLogsPage extends StatefulWidget {
  const VerificationLogsPage({super.key});

  @override
  State<VerificationLogsPage> createState() => _VerificationLogsPageState();
}

class _VerificationLogsPageState extends State<VerificationLogsPage> {
  String _filterResult = 'all'; // all, authentic, suspicious, fake

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // ✅ ĐÃ SỬA: Dùng đúng tên biến 'userModel' như trong AuthProvider của bạn
    final user = authProvider.userModel; 
    
    if (user != null) {
      // ✅ ĐÃ SỬA: Dùng 'uid' thay vì 'id'
      await Provider.of<VerificationProvider>(context, listen: false)
          .loadBrandLogs(user.uid); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Giám sát Xác thực'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterResult = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(value: 'authentic', child: Text('✅ Chính hãng')),
              const PopupMenuItem(value: 'suspicious', child: Text('⚠️ Nghi ngờ')),
              const PopupMenuItem(value: 'fake', child: Text('❌ Hàng giả')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<VerificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());

          List<VerificationLogModel> displayedLogs = provider.brandLogs;
          if (_filterResult != 'all') {
            displayedLogs = displayedLogs.where((log) => log.result == _filterResult).toList();
          }

          if (displayedLogs.isEmpty) return _buildEmptyState();

          // Responsive View
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildWebView(displayedLogs);
              }
              return _buildMobileView(displayedLogs);
            },
          );
        },
      ),
    );
  }

  // 📱 Mobile View (ListView)
  Widget _buildMobileView(List<VerificationLogModel> logs) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) => _buildLogCard(logs[index]),
      ),
    );
  }

  // 💻 Web View (DataTable)
  Widget _buildWebView(List<VerificationLogModel> logs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Danh sách quét gần đây', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Thời gian')),
                    DataColumn(label: Text('Sản phẩm')),
                    DataColumn(label: Text('Serial')),
                    DataColumn(label: Text('Người dùng')),
                    DataColumn(label: Text('Vị trí')),
                    DataColumn(label: Text('Kết quả')),
                    DataColumn(label: Text('Xem')),
                  ],
                  rows: logs.map((log) {
                    final color = _getResultColor(log.result);
                    return DataRow(cells: [
                      DataCell(Text(_formatDateTime(log.verifiedAt))),
                      DataCell(Text(log.productName, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(log.serialNumber)),
                      DataCell(Text(log.userName.isEmpty ? 'Khách' : log.userName)),
                      DataCell(Text(log.location, overflow: TextOverflow.ellipsis)),
                      DataCell(Text(_getResultText(log.result), style: TextStyle(color: color, fontWeight: FontWeight.bold))),
                      DataCell(IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _showLogDetails(log))),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildLogCard(VerificationLogModel log) {
    final resultColor = _getResultColor(log.result);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(_getResultIcon(log.result), color: resultColor, size: 32),
        title: Text(log.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serial: ${log.serialNumber}'),
            Text(_formatDateTime(log.verifiedAt), style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: resultColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: resultColor.withOpacity(0.5)),
          ),
          child: Text(_getResultText(log.result), style: TextStyle(color: resultColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        onTap: () => _showLogDetails(log),
      ),
    );
  }

  void _showLogDetails(VerificationLogModel log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, color: Colors.grey[300])),
              const SizedBox(height: 20),
              Text('Chi tiết xác thực', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              if (log.imageUrl != null)
                 Padding(
                   padding: const EdgeInsets.only(bottom: 16),
                   child: Image.network(log.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
                 ),
              _buildDetailRow('Sản phẩm', log.productName),
              _buildDetailRow('Serial', log.serialNumber),
              _buildDetailRow('Kết quả', _getResultText(log.result)),
              _buildDetailRow('Thời gian', _formatDateTime(log.verifiedAt)),
              _buildDetailRow('Vị trí', log.location),
              _buildDetailRow('AI Confidence', '${log.aiConfidence ?? 0}%'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'authentic': return Colors.green;
      case 'suspicious': return Colors.orange;
      case 'fake': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getResultIcon(String result) {
    switch (result.toLowerCase()) {
      case 'authentic': return Icons.check_circle;
      case 'suspicious': return Icons.warning;
      case 'fake': return Icons.error;
      default: return Icons.help;
    }
  }

  String _getResultText(String result) {
    switch (result.toLowerCase()) {
      case 'authentic': return 'Chính hãng';
      case 'suspicious': return 'Cảnh báo';
      case 'fake': return 'Giả mạo';
      default: return result;
    }
  }

  String _formatDateTime(DateTime d) {
    return '${d.day}/${d.month} ${d.hour}:${d.minute}';
  }
}