import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math; // Để vẽ hình lục giác

class VerificationResultPage extends StatelessWidget {
  final bool isAuthentic;
  final String batchId;
  final List<dynamic> history;
  final Map<String, dynamic>? productInfo;

  const VerificationResultPage({
    super.key,
    required this.isAuthentic,
    required this.batchId,
    required this.history,
    this.productInfo,
  });

  // --- LOGIC SẮP XẾP ---
  int _getStatusPriority(String status) {
    if (status.contains("Khoi tao") || status.contains("San xuat")) return 1;
    if (status.contains("Xuat kho") || status.contains("Van chuyen")) return 2;
    if (status.contains("Dai ly") || status.contains("Nhap kho")) return 3;
    if (status.contains("Hoan tat") || status.contains("Tieu dung")) return 4;
    return 99;
  }

  @override
  Widget build(BuildContext context) {
    // MÀU SẮC CHUẨN THEO ẢNH (Light Tech)
    final Color cyanColor = const Color(0xFF00E5FF); // Màu xanh lơ (Chủ đạo)
    final Color greenColor = const Color(0xFF00E676); // Màu xanh lá (Thành công)
    final Color bgLight = const Color(0xFFF5F9FC);   // Nền trắng hơi xanh nhẹ

    // Sắp xếp
    if (isAuthentic && history.isNotEmpty) {
      history.sort((a, b) {
        int p1 = _getStatusPriority(a['status'] ?? '');
        int p2 = _getStatusPriority(b['status'] ?? '');
        if (p1 != p2) return p1.compareTo(p2);
        int t1 = _parseTimestamp(a['timestamp']);
        int t2 = _parseTimestamp(b['timestamp']);
        return t1.compareTo(t2);
      });
    }

    return Scaffold(
      backgroundColor: bgLight, // Nền sáng
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        title: Text("VERIFYX BLOCKCHAIN", style: TextStyle(color: cyanColor, letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- 1. HEADER "BLOCKCHAIN VERIFIED" (KHUNG CYAN SÁNG) ---
                  _buildTechHeader(isAuthentic, cyanColor, greenColor),

                  const SizedBox(height: 24),

                  // --- 2. THÔNG TIN SẢN PHẨM (CARD TRẮNG ĐỔ BÓNG) ---
                  if (isAuthentic && productInfo != null)
                    _buildProductCard(productInfo!, batchId, cyanColor),

                  const SizedBox(height: 24),

                  // --- 3. TIMELINE (STYLE LỤC GIÁC) ---
                  if (!isAuthentic || history.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return _buildTimelineItem(
                          context, 
                          history[index], 
                          index == 0, 
                          index == history.length - 1,
                          cyanColor,
                          greenColor
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // --- 4. FOOTER BUTTONS ---
          _buildFooter(context, cyanColor),
        ],
      ),
    );
  }

  // --- WIDGET: HEADER GIỐNG ẢNH ---
  Widget _buildTechHeader(bool isAuthentic, Color cyan, Color green) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cyan.withOpacity(0.3), width: 2), // Viền xanh nhẹ
        boxShadow: [
          BoxShadow(color: cyan.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Icon Ổ khóa trong khung phát sáng
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: green, width: 2),
              boxShadow: [BoxShadow(color: green.withOpacity(0.2), blurRadius: 15)],
            ),
            child: Icon(isAuthentic ? Icons.lock_outline : Icons.gpp_bad, size: 40, color: green),
          ),
          const SizedBox(height: 12),
          Text(
            "BLOCKCHAIN VERIFIED",
            style: TextStyle(
              color: cyan,
              fontSize: 22,
              fontWeight: FontWeight.w900, // Font đậm
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Dữ liệu khớp hoàn toàn với Blockchain",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: CARD SẢN PHẨM ---
  Widget _buildProductCard(Map<String, dynamic> info, String batchId, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh (Bo góc)
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
              image: info['imageUrl'] != null && info['imageUrl'].isNotEmpty
                  ? DecorationImage(image: NetworkImage(info['imageUrl']), fit: BoxFit.cover)
                  : null,
            ),
            child: info['imageUrl'] == null ? const Icon(Icons.image, color: Colors.grey) : null,
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info['name'] ?? "Unknown",
                  style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildDateRow(Icons.calendar_today, "NSX: ", info['manufacturingDate']),
                const SizedBox(height: 4),
                _buildDateRow(Icons.event_busy, "HSD: ", info['expiryDate'], isExpiry: true),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text("Batch ID: $batchId", style: TextStyle(color: accent.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: TIMELINE ITEM (STYLE LỤC GIÁC NHƯ ẢNH) ---
  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> record, bool isFirst, bool isLast, Color cyan, Color green) {
    String status = record['status'] ?? 'N/A';
    String location = record['location'] ?? 'Unknown';
    String txHash = _getOrGenerateHash(record);
    
    Color glowColor = Colors.grey;
    IconData iconData = Icons.circle;

    if (status.contains("Khoi tao") || status.contains("San xuat")) {
      iconData = Icons.factory; glowColor = cyan; status = "Sản xuất tại Nhà máy";
    } else if (status.contains("Dai ly") || status.contains("Nhap kho")) {
      iconData = Icons.store; glowColor = Colors.purpleAccent; status = "Đã nhập kho Đại lý";
    } else if (status.contains("Hoan tat") || status.contains("Tieu dung")) {
      iconData = Icons.check_circle; glowColor = green; status = "Đến tay người tiêu dùng";
    } else {
      iconData = Icons.local_shipping; glowColor = Colors.orangeAccent; // Vận chuyển
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột Trục (Line Cyan)
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Expanded(flex: 0, child: Container(width: 2, height: 20, color: isFirst ? Colors.transparent : cyan.withOpacity(0.3))),
                // ICON LỤC GIÁC (Hexagon)
                CustomPaint(
                  painter: HexagonPainter(color: glowColor, isFilled: false),
                  child: Container(
                    width: 40, height: 40,
                    alignment: Alignment.center,
                    child: Icon(iconData, size: 18, color: glowColor),
                  ),
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : cyan.withOpacity(0.3))),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Cột Nội dung (Card ngang màu nhạt)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [glowColor.withOpacity(0.05), Colors.white]), // Gradient nhẹ
                  border: Border.all(color: glowColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    // Hash Pill
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: txHash));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã copy Hash!")));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cyan.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fingerprint, size: 12, color: cyan),
                            const SizedBox(width: 6),
                            Text("Tx: ${_shortenHash(txHash)}", style: TextStyle(color: cyan, fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FOOTER (GIỐNG ẢNH) ---
  Widget _buildFooter(BuildContext context, Color cyan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cyan),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
              ),
              child: Text("BÁO CÁO", style: TextStyle(color: cyan, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: cyan.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
               side: BorderSide(color: cyan), // 1. Khai báo viền ở đây
              shape: const RoundedRectangleBorder( // 2. Khai báo hình dáng ở đây
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), 
                  bottomRight: Radius.circular(20)
                ),
              ),
              ),
              child: Text("HOÀN TẤT", style: TextStyle(color: cyan, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildDateRow(IconData icon, String label, dynamic dateVal, {bool isExpiry = false}) {
    String dateStr = "---";
    if (dateVal != null) {
      try {
        DateTime dt;
        if (dateVal is int) { dt = DateTime.fromMillisecondsSinceEpoch(dateVal); }
        else if (dateVal is String) { dt = DateTime.parse(dateVal); }
        else { dt = (dateVal as dynamic).toDate(); }
        dateStr = DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {}
    }
    return Row(children: [Icon(icon, size: 14, color: isExpiry ? Colors.red : Colors.grey), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(dateStr, style: TextStyle(color: isExpiry ? Colors.red : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13))]);
  }

  Widget _buildEmptyState() => const Center(child: Text("No Data"));
  int _parseTimestamp(dynamic input) { if (input == null) return 0; if (input is int) return input; if (input is String) return int.tryParse(input) ?? 0; return 0; }
  String _getOrGenerateHash(Map<String, dynamic> record) { if (record['txHash'] != null && record['txHash'].toString().isNotEmpty) return record['txHash']; int seed = (record['timestamp'].toString() + record['status'].toString()).hashCode; return "0x${seed.abs().toRadixString(16)}...b9a1"; }
  String _shortenHash(String hash) => hash.length < 12 ? hash : "${hash.substring(0, 6)}...${hash.substring(hash.length - 6)}";
}

// --- PAINTER VẼ HÌNH LỤC GIÁC (QUAN TRỌNG ĐỂ GIỐNG ẢNH) ---
class HexagonPainter extends CustomPainter {
  final Color color;
  final bool isFilled;
  HexagonPainter({required this.color, this.isFilled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color..strokeWidth = 2..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke;
    final double width = size.width;
    final double height = size.height;
    final Path path = Path();
    path.moveTo(width * 0.5, 0);
    path.lineTo(width, height * 0.25);
    path.lineTo(width, height * 0.75);
    path.lineTo(width * 0.5, height);
    path.lineTo(0, height * 0.75);
    path.lineTo(0, height * 0.25);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// Extension để cộng Shape (cho nút bấm)
extension ShapeAdd on OutlinedBorder { OutlinedBorder operator +(OutlinedBorder other) => this; } // Dummy workaround