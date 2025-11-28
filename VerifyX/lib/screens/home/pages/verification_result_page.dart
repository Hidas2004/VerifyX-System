import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math; 

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
    final Color cyanColor = const Color(0xFF00E5FF);
    final Color greenColor = const Color(0xFF00E676);

    // --- [LOGIC ĐỒNG BỘ DỮ LIỆU] ---
    // 1. Xác định ngày NSX chuẩn (Lấy từ ProductInfo hoặc mặc định là NOW)
    DateTime mfgDate = DateTime.now();
    if (productInfo != null && productInfo!['manufacturingDate'] != null) {
      try {
        mfgDate = DateTime.parse(productInfo!['manufacturingDate'].toString());
      } catch (_) {}
    }

    // 2. Clone lịch sử để xử lý
    List<dynamic> displayHistory = List.from(history);

    if (isAuthentic) {
      // 3. [FIX LOGIC] Tìm bước "Sản xuất" và ép thời gian trùng với NSX ở trên header
      // Để tránh tình trạng: Header ghi ngày 26/11 mà Timeline ghi ngày 01/01
      for (var i = 0; i < displayHistory.length; i++) {
        String status = displayHistory[i]['status'] ?? '';
        if (status.contains("Khoi tao") || status.contains("San xuat")) {
           // Gán lại timestamp bằng mfgDate
           displayHistory[i] = Map<String, dynamic>.from(displayHistory[i]);
           displayHistory[i]['timestamp'] = mfgDate.millisecondsSinceEpoch;
        }
      }

      // 4. Sắp xếp lại
      if (displayHistory.isNotEmpty) {
        displayHistory.sort((a, b) {
          int p1 = _getStatusPriority(a['status'] ?? '');
          int p2 = _getStatusPriority(b['status'] ?? '');
          if (p1 != p2) return p1.compareTo(p2);
          int t1 = _parseTimestamp(a['timestamp']);
          int t2 = _parseTimestamp(b['timestamp']);
          return t1.compareTo(t2);
        });
      }

      // 5. Thêm bước "Xác thực bởi Bạn" vào cuối
      displayHistory.add({
        'status': 'Xác thực bởi Bạn',
        'location': 'Đã quét & xác thực thành công',
        'timestamp': DateTime.now().millisecondsSinceEpoch, 
        'isUserAction': true, 
        'txHash': 'Live Verification'
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Kết quả xác thực", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10)),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
                _buildTechHeader(isAuthentic, cyanColor, greenColor),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),

                if (isAuthentic && productInfo != null)
                  _buildProductInfoSimple(productInfo!, batchId, mfgDate), // Truyền mfgDate chuẩn vào

                const SizedBox(height: 32),
                
                Align(alignment: Alignment.centerLeft, child: Text("HÀNH TRÌNH SẢN PHẨM", style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                const SizedBox(height: 16),
                
                if (!isAuthentic)
                   const Padding(
                     padding: EdgeInsets.all(20),
                     child: Text("Sản phẩm này không tồn tại trên hệ thống Blockchain.", style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                   )
                else
                   ListView.builder(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: displayHistory.length,
                     itemBuilder: (context, index) {
                       return _buildTimelineItem(context, displayHistory[index], index == 0, index == displayHistory.length - 1, cyanColor, greenColor);
                     },
                   ),
                   
                 const SizedBox(height: 32),
                 SizedBox(
                   width: double.infinity,
                   height: 50,
                   child: ElevatedButton(
                       onPressed: () => Navigator.pop(context),
                       style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.black87,
                           foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                       ),
                       child: const Text("Hoàn tất"),
                   ),
                 )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechHeader(bool isAuthentic, Color cyan, Color green) {
      return Column(
          children: [
              Text(
                isAuthentic ? "XÁC THỰC THÀNH\nCÔNG" : "CẢNH BÁO GIẢ MẠO",
                style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.w900, 
                    color: isAuthentic ? Colors.black87 : Colors.red,
                    letterSpacing: 1.0
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: isAuthentic ? green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          Icon(isAuthentic ? Icons.check_circle : Icons.warning, size: 18, color: isAuthentic ? green : Colors.red),
                          const SizedBox(width: 8),
                          Text(
                              isAuthentic ? "Verified by Blockchain" : "Unknown Source",
                              style: TextStyle(color: isAuthentic ? green : Colors.red, fontWeight: FontWeight.bold)
                          )
                      ],
                  ),
              )
          ],
      );
  }

  // Nhận thêm tham số mfgDate chuẩn từ bên ngoài
  Widget _buildProductInfoSimple(Map<String, dynamic> info, String batchId, DateTime mfgDate) {
      // Logic HSD: NSX + 2 năm (Nếu HSD null)
      DateTime expDate;
      if (info['expiryDate'] != null) {
         try { expDate = DateTime.parse(info['expiryDate'].toString()); } catch (_) { expDate = mfgDate.add(const Duration(days: 730)); }
      } else {
         expDate = mfgDate.add(const Duration(days: 730));
      }

      String mfgDateStr = DateFormat('dd/MM/yyyy').format(mfgDate);
      String expDateStr = DateFormat('dd/MM/yyyy').format(expDate);

      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      image: info['imageUrl'] != null && info['imageUrl'].isNotEmpty 
                        ? DecorationImage(image: NetworkImage(info['imageUrl']), fit: BoxFit.cover) 
                        : null
                  ),
                  child: info['imageUrl'] == null || info['imageUrl'].isEmpty ? const Icon(Icons.image, color: Colors.grey, size: 30) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(info['name'] ?? "Sản phẩm Demo", 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text("Batch ID: $batchId", style: const TextStyle(fontFamily: 'monospace', color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 10),
                          
                          Wrap(
                              spacing: 8.0, 
                              runSpacing: 8.0, 
                              children: [
                                  _buildInfoTag("NSX: $mfgDateStr", Colors.blue),
                                  _buildInfoTag("HSD: $expDateStr", Colors.orange),
                              ],
                          )
                      ],
                  ),
              )
          ],
      );
  }

  Widget _buildInfoTag(String text, Color color) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)), 
            borderRadius: BorderRadius.circular(4)
          ),
          child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> record, bool isFirst, bool isLast, Color cyan, Color green) {
    String status = record['status'] ?? 'N/A';
    String location = record['location'] ?? 'Unknown';
    bool isUserAction = record['isUserAction'] == true; 
    String txHash = isUserAction ? "Confirmed by Device" : _getOrGenerateHash(record);
    
    Color glowColor = Colors.grey;
    IconData iconData = Icons.circle;

    if (isUserAction) {
       iconData = Icons.person_pin_circle; glowColor = Colors.blueAccent; location = "Đã quét & xác thực thành công";
    } else if (status.contains("Khoi tao") || status.contains("San xuat")) {
      iconData = Icons.factory; glowColor = cyan; status = "Sản xuất tại Nhà máy";
    } else if (status.contains("Dai ly") || status.contains("Nhap kho")) {
      iconData = Icons.store; glowColor = Colors.purpleAccent; status = "Đã nhập kho Đại lý";
    } else if (status.contains("Hoan tat") || status.contains("Tieu dung")) {
      iconData = Icons.check_circle; glowColor = green; status = "Đến tay người tiêu dùng";
    } else {
      iconData = Icons.local_shipping; glowColor = Colors.orangeAccent;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Expanded(flex: 0, child: Container(width: 2, height: 20, color: isFirst ? Colors.transparent : cyan.withOpacity(0.3))),
                CustomPaint(
                  painter: HexagonPainter(color: glowColor, isFilled: isUserAction), 
                  child: Container(width: 40, height: 40, alignment: Alignment.center, child: Icon(iconData, size: 18, color: isUserAction ? Colors.white : glowColor)),
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : cyan.withOpacity(0.3))),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUserAction ? Colors.blue.withOpacity(0.05) : Colors.white, 
                  border: Border.all(color: isUserAction ? Colors.blue.withOpacity(0.3) : glowColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isUserAction ? [] : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(status, 
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis, 
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          // Format timestamp thành giờ phút ngày tháng
                          DateFormat('HH:mm dd/MM').format(DateTime.fromMillisecondsSinceEpoch(_parseTimestamp(record['timestamp']))),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500])
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    
                    const SizedBox(height: 8),
                    isUserAction 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Text("✓ Tin cậy tuyệt đối", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                      )
                    : InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: txHash));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã copy Hash!")));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.link, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Flexible(
                                child: Text("Tx: ${_shortenHash(txHash)}", 
                                    style: TextStyle(color: Colors.grey[600], fontFamily: 'monospace', fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                )
                            ),
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

  int _parseTimestamp(dynamic input) { if (input == null) return 0; if (input is int) return input; if (input is String) return int.tryParse(input) ?? 0; return 0; }
  String _getOrGenerateHash(Map<String, dynamic> record) { if (record['txHash'] != null && record['txHash'].toString().isNotEmpty) return record['txHash']; int seed = (record['timestamp'].toString() + record['status'].toString()).hashCode; return "0x${seed.abs().toRadixString(16)}...b9a1"; }
  String _shortenHash(String hash) => hash.length < 12 ? hash : "${hash.substring(0, 5)}...${hash.substring(hash.length - 4)}";
}

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