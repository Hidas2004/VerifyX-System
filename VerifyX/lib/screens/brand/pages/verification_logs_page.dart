import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Import đúng đường dẫn của bạn
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/verification_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/brand/verification_log_model.dart';

class VerificationLogsPage extends StatefulWidget {
  const VerificationLogsPage({super.key});

  @override
  State<VerificationLogsPage> createState() => _VerificationLogsPageState();
}

class _VerificationLogsPageState extends State<VerificationLogsPage> {
  // State cho Thống kê
  int _totalScans = 0;
  int _fakeCount = 0;
  String _topLocation = "Chưa có";

  // State cho Bộ lọc (Filter)
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Tất cả'; // Tất cả, Chính hãng, Giả mạo, Cảnh báo
  String _filterDate = 'Tất cả';   // Tất cả, Hôm nay, Tuần này

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    
    if (user != null) {
      await Provider.of<VerificationProvider>(context, listen: false)
          .loadBrandLogs(user.uid);
      _calculateMetrics();
    }
  }

  void _calculateMetrics() {
    final provider = Provider.of<VerificationProvider>(context, listen: false);
    final logs = provider.brandLogs;

    if (logs.isEmpty) return;

    int fakes = 0;
    Map<String, int> locationCount = {};

    for (var log in logs) {
      if (log.result == 'fake' || log.result == 'suspicious') {
        fakes++;
      }
      if (log.location.isNotEmpty) {
        locationCount[log.location] = (locationCount[log.location] ?? 0) + 1;
      }
    }

    String topLoc = "N/A";
    if (locationCount.isNotEmpty) {
      var sortedKeys = locationCount.keys.toList()
        ..sort((k1, k2) => locationCount[k2]!.compareTo(locationCount[k1]!));
      topLoc = sortedKeys.first;
    }

    if (mounted) {
      setState(() {
        _totalScans = logs.length;
        _fakeCount = fakes;
        _topLocation = topLoc;
      });
    }
  }

  // --- LOGIC LỌC DỮ LIỆU ---
  List<VerificationLogModel> _getFilteredLogs(List<VerificationLogModel> allLogs) {
    return allLogs.where((log) {
      // 1. Lọc theo Search (Serial hoặc Tên SP)
      final searchText = _searchController.text.toLowerCase();
      final matchesSearch = searchText.isEmpty || 
                            log.serialNumber.toLowerCase().contains(searchText) || 
                            log.productName.toLowerCase().contains(searchText);

      // 2. Lọc theo Trạng thái
      bool matchesStatus = true;
      if (_filterStatus == 'Chính hãng') matchesStatus = log.result == 'authentic';
      if (_filterStatus == 'Giả mạo') matchesStatus = log.result == 'fake';
      if (_filterStatus == 'Cảnh báo') matchesStatus = log.result == 'suspicious';

      // 3. Lọc theo Ngày
      bool matchesDate = true;
      final now = DateTime.now();
      if (_filterDate == 'Hôm nay') {
        matchesDate = log.verifiedAt.year == now.year && 
                      log.verifiedAt.month == now.month && 
                      log.verifiedAt.day == now.day;
      } else if (_filterDate == 'Tuần này') {
        final difference = now.difference(log.verifiedAt).inDays;
        matchesDate = difference <= 7;
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VerificationProvider>(context);
    // Lấy list đã lọc
    final filteredLogs = _getFilteredLogs(provider.brandLogs);

    return Scaffold( // Dùng Scaffold để đảm bảo không bị lỗi layout
      backgroundColor: Colors.transparent, // Trong suốt để ăn theo nền BrandHome
      body: SingleChildScrollView( // Cho phép cuộn cả trang
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. THỐNG KÊ MINI DASHBOARD
            Row(
              children: [
                Expanded(child: _buildMetricCard("Tổng lượt quét", "$_totalScans", Icons.qr_code_scanner, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard("Cảnh báo giả", "$_fakeCount", Icons.warning_amber_rounded, Colors.red)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetricCard("Khu vực Hot", _topLocation, Icons.location_on, Colors.orange)),
              ],
            ),
            
            const SizedBox(height: 24),

            // 2. THANH CÔNG CỤ LỌC (FILTER BAR)
            _buildFilterBar(),

            const SizedBox(height: 16),

            // 3. BẢNG DỮ LIỆU CHI TIẾT
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: provider.isLoading 
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                : filteredLogs.isEmpty 
                  ? _buildEmptyState()
                  : Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.grey[200]),
                      child: DataTable(
                        horizontalMargin: 24,
                        columnSpacing: 20,
                        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                        dataRowMinHeight: 70, // Tăng chiều cao dòng để chứa ảnh
                        dataRowMaxHeight: 80,
                        columns: const [
                          DataColumn(label: Text("Thời gian", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Sản phẩm / Serial", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Vị trí & User", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Kết quả", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Hành động", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredLogs.map((log) => _buildDataRow(log)).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: THANH LỌC ---
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text("Bộ lọc tìm kiếm", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Làm mới dữ liệu"),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Tìm kiếm
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}), // Refresh UI khi gõ
                  decoration: InputDecoration(
                    hintText: "Nhập Serial hoặc Tên sản phẩm...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Dropdown Trạng thái
              Expanded(
                child: _buildDropdown(
                  value: _filterStatus,
                  items: ['Tất cả', 'Chính hãng', 'Giả mạo', 'Cảnh báo'],
                  onChanged: (val) => setState(() => _filterStatus = val!),
                  icon: Icons.verified_user_outlined,
                ),
              ),
              const SizedBox(width: 16),

              // Dropdown Ngày
              Expanded(
                child: _buildDropdown(
                  value: _filterDate,
                  items: ['Tất cả', 'Hôm nay', 'Tuần này'],
                  onChanged: (val) => setState(() => _filterDate = val!),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DATA ROW BUILDER (GỘP CỘT) ---
  DataRow _buildDataRow(VerificationLogModel log) {
    return DataRow(
      cells: [
        // Cột 1: Thời gian
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(log.verifiedAt), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(DateFormat('HH:mm').format(log.verifiedAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),

        // Cột 2: Sản phẩm + Serial + Ảnh
        DataCell(
          Row(
            children: [
              // Ảnh thumbnail (Dùng placeholder nếu null)
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey[100],
                  image: log.imageUrl != null 
                    ? DecorationImage(image: NetworkImage(log.imageUrl!), fit: BoxFit.cover)
                    : null,
                ),
                child: log.imageUrl == null ? const Icon(Icons.image_not_supported, size: 16, color: Colors.grey) : null,
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(2)),
                    child: Text(log.serialNumber, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black87)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cột 3: Vị trí & User (Có Map Icon)
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Flexible(child: Text(log.location.isNotEmpty ? log.location : 'Không xác định', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                  // Thêm nút Map nhỏ nếu muốn
                  if (log.location.isNotEmpty)
                    InkWell(
                      onTap: () {
                         // TODO: Mở Google Map Dialog hoặc Url
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng mở bản đồ đang phát triển")));
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.map_outlined, size: 14, color: Colors.blue),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(log.userName.isNotEmpty ? log.userName : 'Khách vãng lai', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),

        // Cột 4: Kết quả (Badges)
        DataCell(_buildResultBadge(log.result)),

        // Cột 5: Hành động (Menu 3 chấm)
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'detail') {
                 // Logic xem chi tiết
              } else if (value == 'lock') {
                 // Logic khóa mã
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'detail',
                child: Row(children: [Icon(Icons.visibility, size: 18, color: Colors.blue), SizedBox(width: 8), Text('Xem chi tiết')]),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(children: [Icon(Icons.flag, size: 18, color: Colors.orange), SizedBox(width: 8), Text('Báo cáo')]),
              ),
              if (log.result == 'fake' || log.result == 'suspicious')
                const PopupMenuItem(
                  value: 'lock',
                  child: Row(children: [Icon(Icons.lock, size: 18, color: Colors.red), SizedBox(width: 8), Text('Khóa mã này')]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildDropdown({required String value, required List<String> items, required Function(String?) onChanged, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(icon, size: 18, color: Colors.grey),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResultBadge(String result) {
    Color color = Colors.green;
    String text = "Chính hãng";
    IconData icon = Icons.check_circle;

    if (result == 'fake') { 
      color = Colors.red; 
      text = "Giả mạo"; 
      icon = Icons.cancel;
    }
    if (result == 'suspicious') { 
      color = Colors.orange; 
      text = "Cảnh báo"; 
      icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Không tìm thấy dữ liệu phù hợp", style: GoogleFonts.inter(color: Colors.grey[600])),
          const SizedBox(height: 8),
          const Text("Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}