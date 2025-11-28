import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart'; 
import 'dart:convert'; 
import 'package:url_launcher/url_launcher.dart'; // Đã fix lỗi import

import '../../../core/constants/constants.dart';
import '../../../models/brand/batch_model.dart';
import '../../../models/product_model.dart';
import '../../../services/base/batch_service.dart';
import '../../../services/product_service.dart'; // Chú ý đường dẫn này nếu bạn để khác
import '../../../providers/auth_provider.dart';

class BatchTrackingPage extends StatefulWidget {
  const BatchTrackingPage({super.key});

  @override
  State<BatchTrackingPage> createState() => _BatchTrackingPageState();
}

class _BatchTrackingPageState extends State<BatchTrackingPage> {
  final BatchService _batchService = BatchService();
  final ProductService _productService = ProductService();
  
  bool _isLoading = false;
  List<BatchModel> _batches = [];

  final TextEditingController _batchCodeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  DateTime? _selectedMfgDate;
  DateTime? _selectedExpDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBatches());
  }

  @override
  void dispose() {
    _batchCodeController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final batches = await _batchService.getBatches(user.uid);
      if (mounted) setState(() => _batches = batches);
    } catch (e) {
      debugPrint('❌ Lỗi load batch: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, int> get _stats {
    int total = _batches.length;
    int manufacturing = _batches.where((b) => b.status == 'Xuat kho' || b.status == 'active').length;
    int transporting = _batches.where((b) => b.status == 'Van chuyen').length;
    int completed = _batches.where((b) => b.status == 'Hoan tat' || b.status == 'Nhap kho Daily').length;

    return {
      "total": total,
      "manufacturing": manufacturing,
      "transporting": transporting,
      "completed": completed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Quản lý Lô hàng', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54), 
            onPressed: _loadBatches
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. STATS DASHBOARD
                      _buildStatsDashboard(),
                      const SizedBox(height: 24),
                      
                      // 2. HEADER BẢNG
                      Text("Danh sách Lô hàng", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // 3. TABLE
                      _batches.isEmpty 
                        ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("Chưa có lô hàng nào")))
                        : _buildBatchTable(constraints.maxWidth), 
                    ],
                  ),
                );
              }
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBatchDialog,
        icon: const Icon(Icons.add_box),
        label: const Text('Tạo Lô Hàng'),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildStatsDashboard() {
    final s = _stats;
    return Row(
      children: [
        _buildStatCard("Tổng lô", "${s['total']}", Icons.local_shipping, Colors.blue),
        const SizedBox(width: 10),
        _buildStatCard("SX/Xuất", "${s['manufacturing']}", Icons.factory, Colors.orange),
        const SizedBox(width: 10),
        _buildStatCard("Vận chuyển", "${s['transporting']}", Icons.directions_boat, Colors.purple),
        const SizedBox(width: 10),
        _buildStatCard("Hoàn tất", "${s['completed']}", Icons.store, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchTable(double screenWidth) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenWidth - 40),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
            columnSpacing: 20,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            columns: const [
              DataColumn(label: Text('Mã Batch', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Số lượng', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Blockchain', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _batches.map((batch) {
              return DataRow(cells: [
                DataCell(Text(batch.batchNumber, style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    width: 150, 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(batch.productName, style: const TextStyle(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(DateFormat('dd/MM/yyyy').format(batch.manufactureDate), style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                  )
                ),
                DataCell(Text("${batch.quantity}")),
                DataCell(_buildStatusBadge(batch.status)),
                
                // Blockchain Column
                DataCell(
                  batch.blockchainData != null 
                  ? InkWell(
                      onTap: () => _showBlockchainDetails(batch),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.link, size: 14, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              _shortenHash(batch.blockchainData?['txHash']),
                              style: GoogleFonts.robotoMono(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500)
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Text("-", style: TextStyle(color: Colors.grey)),
                ),

                // Action Column
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_location_alt_outlined, size: 20, color: Colors.orange),
                      tooltip: "Cập nhật lộ trình",
                      onPressed: () => _showStatusUpdateDialog(batch),
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, size: 20, color: Colors.black87),
                      tooltip: "In tem QR",
                      onPressed: () => _showQrPrintDialog(batch),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // --- CÁC HÀM HELPER VÀ DIALOG ---

  String _shortenHash(String? hash) {
    if (hash == null || hash.length < 10) return "Unknown";
    return "${hash.substring(0, 6)}...${hash.substring(hash.length - 4)}";
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    String text = status;
    Color bg = Colors.grey.shade100;

    if (status == 'Hoan tat' || status == 'Nhap kho Daily') {
      color = Colors.green; bg = Colors.green.shade50; text = "Hoàn tất";
    } else if (status == 'Van chuyen') {
      color = Colors.purple; bg = Colors.purple.shade50; text = "Vận chuyển";
    } else if (status == 'Xuat kho') {
      color = Colors.orange; bg = Colors.orange.shade50; text = "Xuất kho";
    } else {
      text = "Mới tạo";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
  
  // --- DIALOG: IN TEM QR ---
  Future<void> _showQrPrintDialog(BatchModel batch) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final products = await _productService.getProductsByBatch(batch.id);
    Navigator.pop(context); // Tắt loading

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lô hàng này chưa có sản phẩm nào!")));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[200],
        contentPadding: const EdgeInsets.all(20),
        content: Container(
           width: 800,
           height: 700,
           decoration: BoxDecoration(
             color: Colors.white,
             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
           ),
           child: Column(
             children: [
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text("TEM LÔ HÀNG: ${batch.batchNumber}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text("Số lượng: ${products.length}", style: const TextStyle(color: Colors.grey)),
                   ],
                 ),
               ),
               const Divider(height: 1),
               
               Expanded(
                 child: SingleChildScrollView(
                   padding: const EdgeInsets.all(24),
                   child: Wrap(
                     spacing: 10,
                     runSpacing: 10,
                     children: products.map((prod) => _buildQrSticker(prod)).toList(),
                   ),
                 ),
               ),
             ],
           ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng")),
          ElevatedButton.icon(
             icon: const Icon(Icons.print),
             label: const Text("IN NGAY (Chuẩn A4)"),
             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
             onPressed: () {
               _printViaHtml(products, batch.batchNumber);
             },
          )
        ],
      ),
    );
  }

  // Widget tạo 1 con tem
  Widget _buildQrSticker(ProductModel product) {
    return Container(
      width: 160,
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(4)
      ),
      child: Row(
        children: [
          QrImageView(
            data: product.serialNumber,
            version: QrVersions.auto,
            size: 80.0,
            gapless: false,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name, 
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 4),
                Text("S/N:", style: TextStyle(fontSize: 8, color: Colors.grey[600])),
                Text(
                  product.serialNumber, 
                  style: const TextStyle(fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                  maxLines: 1,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- HÀM MỞ TRÌNH DUYỆT ĐỂ IN (ĐÃ FIX LỖI 5 CHỖ) ---
  void _printViaHtml(List<ProductModel> products, String batchCode) {
    String htmlContent = """
      <html>
      <head>
        <title>In Tem - $batchCode</title>
        <style>
          body { font-family: sans-serif; padding: 20px; }
          .grid { display: flex; flex-wrap: wrap; gap: 10px; }
          .sticker { 
            width: 250px; height: 120px; 
            border: 1px dashed #333;
            padding: 10px; 
            display: flex; align-items: center;
            page-break-inside: avoid;
          }
          .qr-img { width: 90px; height: 90px; margin-right: 10px; }
          .info { flex: 1; font-size: 12px; }
          .name { font-weight: bold; margin-bottom: 5px; display: block; }
          .sn { font-family: monospace; font-size: 11px; color: #555; }
          @media print {
            .no-print { display: none; }
            body { margin: 0; padding: 0; }
          }
        </style>
      </head>
      <body>
        <div class="no-print" style="margin-bottom: 20px;">
          <h2>Lô: $batchCode</h2>
          <button onclick="window.print()" style="padding: 10px 20px; font-size: 16px; cursor: pointer;">🖨️ XÁC NHẬN IN NGAY</button>
        </div>
        
        <div class="grid">
          ${products.map((p) => """
            <div class="sticker">
              <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${p.serialNumber}" class="qr-img" />
              <div class="info">
                <span class="name">${p.name}</span>
                <br/>
                S/N: <span class="sn">${p.serialNumber}</span>
              </div>
            </div>
          """).join('')}
        </div>
      </body>
      </html>
    """;

    final Uri dataUri = Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
    _launchInBrowser(dataUri);
  }
  
  // [ĐÃ FIX] SỬ DỤNG HÀM MỚI CỦA URL_LAUNCHER
  Future<void> _launchInBrowser(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url); // Mở tab mới
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching print view: $e');
    }
  }

  void _showBlockchainDetails(BatchModel batch) {
    final String txHash = batch.blockchainData?['txHash'] ?? '';
    final String blockNum = "${batch.blockchainData?['blockNumber'] ?? '...'}";
    final bool isConfirmed = (batch.blockchainData != null && batch.blockchainData!['txHash'] != null);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.hub, color: Colors.blue),
            const SizedBox(width: 10),
            Text("Dữ liệu Blockchain", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isConfirmed ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isConfirmed ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    isConfirmed ? Icons.check_circle : Icons.hourglass_top,
                    size: 40,
                    color: isConfirmed ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isConfirmed ? "GIAO DỊCH THÀNH CÔNG" : "ĐANG CHỜ XÁC NHẬN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isConfirmed ? Colors.green[700] : Colors.orange[800],
                    ),
                  ),
                  if (isConfirmed)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("Đã lưu tại Block #$blockNum", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            _buildDetailRow("Batch ID:", "${batch.blockchainId}"),
            const SizedBox(height: 12),
            
            Align(alignment: Alignment.centerLeft, child: Text("Transaction Hash:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      txHash.isNotEmpty ? txHash : "Chưa có hash",
                      style: GoogleFonts.robotoMono(fontSize: 11, color: Colors.grey[800]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (txHash.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blue, size: 20),
                      tooltip: "Sao chép Hash",
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 8),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: txHash));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép mã Hash!'), backgroundColor: Colors.green)
                        );
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }

  Future<void> _showStatusUpdateDialog(BatchModel batch) async {
    String? selectedStatus;
    final locationController = TextEditingController(text: "Kho nhà máy");

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật: ${batch.batchNumber}', style: const TextStyle(fontSize: 16)),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Xuat kho', child: Text('🚚 Xuất kho')),
                  DropdownMenuItem(value: 'Van chuyen', child: Text('🚢 Vận chuyển')),
                  DropdownMenuItem(value: 'Nhap kho Daily', child: Text('🏭 Nhập kho ĐL')),
                  DropdownMenuItem(value: 'Hoan tat', child: Text('✅ Hoàn tất')),
                ],
                onChanged: (val) => setStateDialog(() => selectedStatus = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Vị trí hiện tại', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus == null) return;
              Navigator.pop(context);
              _processUpdateStatus(batch, selectedStatus!, locationController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  Future<void> _processUpdateStatus(BatchModel batch, String status, String location) async {
    try {
      final int blockchainId = batch.blockchainId;
      if (blockchainId == 0) throw Exception("Chưa có ID Blockchain");
      final result = await _batchService.updateBatchStatus(blockchainId: blockchainId, status: status, location: location);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Thành công!'), backgroundColor: Colors.green));
        _loadBatches();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  void _showCreateBatchDialog() {
     _batchCodeController.clear(); 
    _productNameController.clear(); 
    _quantityController.clear();
    _selectedMfgDate = DateTime.now(); 
    _selectedExpDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo Lô Hàng Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _batchCodeController, decoration: const InputDecoration(labelText: 'Mã lô', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _productNameController, decoration: const InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildDatePickerField(label: 'Ngày SX', selectedDate: _selectedMfgDate, onTap: () async { final d = await _pickDate(context, _selectedMfgDate); if(d!=null) setState(()=>_selectedMfgDate=d); })),
                const SizedBox(width: 10),
                Expanded(child: _buildDatePickerField(label: 'Hạn SD', selectedDate: _selectedExpDate, onTap: () async { final d = await _pickDate(context, _selectedExpDate); if(d!=null) setState(()=>_selectedExpDate=d); })),
              ]),
              const SizedBox(height: 12),
              TextField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Số lượng', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => _handleCreateBatch(context), 
            child: const Text('Xác nhận')
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateBatch(BuildContext dialogContext) async {
    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;
    Navigator.pop(dialogContext);
    
     try {
      final result = await _batchService.createBatch(
        brandId: user.uid,
        brandName: user.displayName ?? "Brand",
        batchNumber: _batchCodeController.text,
        productName: _productNameController.text,
        manufactureDate: _selectedMfgDate!,
        expiryDate: _selectedExpDate!,
        quantity: int.tryParse(_quantityController.text) ?? 0,
      );
      if (result != null) _loadBatches();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(
            width: 150,
            child: Text(value, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.blue), overflow: TextOverflow.ellipsis, textAlign: TextAlign.end)
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({required String label, required DateTime? selectedDate, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: InputDecorator(decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), child: Text(selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : 'Chọn')));
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime? initialDate) { 
    return showDatePicker(context: context, initialDate: initialDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); 
  }
}