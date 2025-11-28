import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- KPI DATA ---
  int _totalProducts = 0;   
  int _totalBatches = 0;    
  int _totalScans = 0;      
  int _authenticScans = 0;   
  int _fakeScans = 0;        
  
  List<double> _weeklyScanData = List.filled(7, 0.0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      final productSnap = await _firestore.collection('products').count().get();
      final batchSnap = await _firestore.collection('batches').count().get();
      final scanSnap = await _firestore.collection('verifications').get();
      final scanDocs = scanSnap.docs;

      int authenticCount = 0;
      int fakeCount = 0;

      for (var doc in scanDocs) {
        final data = doc.data();
        if (data['isAuthentic'] == true) {
          authenticCount++;
        } else {
          fakeCount++;
        }
      }

      _processChartData(scanDocs);

      if (mounted) {
        setState(() {
          _totalProducts = productSnap.count ?? 0;
          _totalBatches = batchSnap.count ?? 0;
          _totalScans = scanDocs.length;
          _authenticScans = authenticCount;
          _fakeScans = fakeCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải Dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processChartData(List<QueryDocumentSnapshot> docs) {
    List<double> tempWeek = List.filled(7, 0.0);
    DateTime now = DateTime.now();
    
    for (var doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        DateTime? date;
        if (data['verifiedAt'] is Timestamp) {
          date = (data['verifiedAt'] as Timestamp).toDate();
        } else if (data['verifiedAt'] is String) {
          date = DateTime.tryParse(data['verifiedAt']);
        }

        if (date != null) {
          int diff = now.difference(date).inDays;
          if (diff >= 0 && diff < 7) {
            tempWeek[6 - diff] += 1;
          }
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    _weeklyScanData = tempWeek;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 700 && width < 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. KPI CARDS
          LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1); 
            double childAspectRatio = isDesktop ? 1.6 : (isTablet ? 2.2 : 2.0);
            
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              childAspectRatio: childAspectRatio,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildKPICard("Số Sản Phẩm", "$_totalProducts", Icons.inventory_2, AppColors.kpiBlue),
                _buildKPICard("Số Lô Hàng", "$_totalBatches", Icons.layers, AppColors.kpiOrange),
                _buildKPICard("Tổng Lượt Quét", "$_totalScans", Icons.qr_code_scanner, AppColors.kpiPurple),
                _buildKPICard("Quét Chính Hãng", "$_authenticScans", Icons.check_circle, AppColors.adminSuccess),
                _buildKPICard("Cảnh Báo Giả", "$_fakeScans", Icons.warning_amber_rounded, AppColors.kpiRed),
              ],
            );
          }),

          const SizedBox(height: 24),

          // 2. CHART & LOGS
          isDesktop 
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildChartSection()), // Giảm flex chart xuống 6
                  const SizedBox(width: 24),
                  Expanded(flex: 4, child: _buildBlockchainFeed()), // Tăng flex log lên 4 để hiển thị Badge đẹp hơn
                ],
              )
            : Column(
                children: [
                  _buildChartSection(),
                  const SizedBox(height: 24),
                  _buildBlockchainFeed(),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.adminTextPrimary)),
              Text(title, style: GoogleFonts.inter(fontSize: 14, color: AppColors.adminTextSecondary, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    double maxY = _weeklyScanData.reduce((a, b) => a > b ? a : b);
    maxY = maxY == 0 ? 10 : maxY + 5;

    return Container(
      height: 500, // Tăng chiều cao lên chút
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thống kê Lượt quét", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.adminTextPrimary)),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => AppColors.kpiBlue),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(DateFormat('dd/MM').format(date), style: GoogleFonts.inter(fontSize: 10, color: AppColors.adminTextSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.adminBorder, strokeWidth: 1)),
                barGroups: _weeklyScanData.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: AppColors.kpiBlue,
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: AppColors.adminBackground)
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PHẦN NÀY ĐÃ ĐƯỢC NÂNG CẤP MẠNH MẼ ---
  Widget _buildBlockchainFeed() {
    return Container(
      height: 500, // Khớp chiều cao với biểu đồ bên cạnh
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Giao dịch Blockchain", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.adminTextPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green)),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("REAL-TIME", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('verifications')
                  .orderBy('verifiedAt', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("Chưa có giao dịch"));

                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 24, thickness: 0.5, color: AppColors.adminBorder),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isAuthentic = data['isAuthentic'] == true;
                    
                    final String timeStr = data['verifiedAt'] != null 
                        ? DateFormat('HH:mm:ss').format((data['verifiedAt'] as Timestamp).toDate()) 
                        : 'Now';
                    
                    return Row(
                      children: [
                        // Icon dẫn đầu
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isAuthentic ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            shape: BoxShape.circle
                          ),
                          child: Icon(Icons.qr_code_2, size: 20, color: isAuthentic ? Colors.blue : Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        
                        // Thông tin User & Hash
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${data['productName'] ?? 'Sản phẩm'}",
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.adminTextPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 12, color: AppColors.adminTextSecondary),
                                  const SizedBox(width: 4),
                                  Text("${data['userName'] ?? 'Guest'} • $timeStr", style: GoogleFonts.inter(fontSize: 12, color: AppColors.adminTextSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // BADGE TRẠNG THÁI (PHẦN QUAN TRỌNG NHẤT BẠN YÊU CẦU)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isAuthentic ? AppColors.adminSuccess : AppColors.kpiRed, // Nền đặc
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(color: (isAuthentic ? AppColors.adminSuccess : AppColors.kpiRed).withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Text(
                            isAuthentic ? "HỢP LỆ" : "GIẢ MẠO",
                            style: GoogleFonts.inter(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 11
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}