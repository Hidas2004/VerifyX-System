import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../models/brand/batch_model.dart';
import '../../../services/base/batch_service.dart';
import '../../../providers/auth_provider.dart';

class BatchTrackingPage extends StatefulWidget {
  const BatchTrackingPage({super.key});

  @override
  State<BatchTrackingPage> createState() => _BatchTrackingPageState();
}

class _BatchTrackingPageState extends State<BatchTrackingPage> {
  final BatchService _batchService = BatchService();
  bool _isLoading = false;
  List<BatchModel> _batches = [];

  // Controllers cho form tạo mới
  final TextEditingController _batchCodeController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  
  DateTime? _selectedMfgDate;
  DateTime? _selectedExpDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBatches();
    });
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

  // --- [MỚI] HÀM XỬ LÝ CẬP NHẬT TRẠNG THÁI ---
  Future<void> _showStatusUpdateDialog(BatchModel batch) async {
    String? selectedStatus;
    final locationController = TextEditingController(text: "Kho nhà máy"); // Mặc định

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật Lô: ${batch.batchNumber}'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Chọn trạng thái mới để ghi lên Blockchain:"),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sync_alt),
                ),
                items: const [
                  DropdownMenuItem(value: 'Xuat kho', child: Text('🚚 Xuất kho')),
                  DropdownMenuItem(value: 'Van chuyen', child: Text('🚢 Đang vận chuyển')),
                  DropdownMenuItem(value: 'Nhap kho Daily', child: Text('🏭 Nhập kho Đại lý')),
                  DropdownMenuItem(value: 'Hoan tat', child: Text('✅ Hoàn tất')),
                ],
                onChanged: (val) => setStateDialog(() => selectedStatus = val),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Vị trí hiện tại',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus == null) return;
              Navigator.pop(context); // Đóng dialog nhập
              _processUpdateStatus(batch, selectedStatus!, locationController.text);
            },
            child: const Text('Cập nhật Blockchain'),
          ),
        ],
      ),
    );
  }

  Future<void> _processUpdateStatus(BatchModel batch, String status, String location) async {
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Lấy Blockchain ID của lô hàng
      final int blockchainId = batch.blockchainData?['id'] ?? 0;
      if (blockchainId == 0) throw Exception("Lô hàng chưa được đồng bộ Blockchain");

      // GỌI SERVICE
      final result = await _batchService.updateBatchStatus(
        blockchainId: blockchainId,
        status: status,
        location: location,
      );

      if (mounted) Navigator.pop(context); // Tắt loading

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cập nhật trạng thái thành công!'), backgroundColor: Colors.green),
        );
        // Tải lại danh sách để thấy cập nhật mới (nếu backend có update field status)
        _loadBatches(); 
      } else {
        throw Exception("Lỗi server");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  // ... (Các hàm tạo lô hàng _showCreateBatchDialog, _handleCreateBatch giữ nguyên như cũ) ...
  void _showCreateBatchDialog() {
    _batchCodeController.clear(); _productNameController.clear(); _quantityController.clear();
    _selectedMfgDate = DateTime.now(); _selectedExpDate = DateTime.now().add(const Duration(days: 365)); 

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
          ElevatedButton(onPressed: () => _handleCreateBatch(context), child: const Text('Xác nhận')),
        ],
      ),
    );
  }

  Future<void> _handleCreateBatch(BuildContext dialogContext) async {
     final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    Navigator.pop(dialogContext);
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => const Center(child: CircularProgressIndicator()));

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
      if (mounted) Navigator.pop(context);
      if (result != null) { _loadBatches(); }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  // --- GIAO DIỆN CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Quản lý Lô hàng'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBatches)]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
              ? const Center(child: Text('Chưa có lô hàng nào'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  itemCount: _batches.length,
                  itemBuilder: (context, index) => _buildBatchCard(_batches[index]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBatchDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tạo lô hàng'),
      ),
    );
  }

  // --- [CẬP NHẬT] GIAO DIỆN THẺ LÔ HÀNG ---
  Widget _buildBatchCard(BatchModel batch) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(batch.batchNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Text('${batch.quantity} SP', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Sản phẩm: ${batch.productName}", style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 4),
            if (batch.blockchainData != null)
              Row(
                children: [
                  const Icon(Icons.lock, size: 14, color: Colors.purple),
                  const SizedBox(width: 4),
                  Text("Blockchain ID: ${batch.blockchainData!['id']}", style: const TextStyle(color: Colors.purple, fontSize: 12)),
                ],
              ),
            const Divider(),
            // Nút bấm chức năng
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showStatusUpdateDialog(batch),
                icon: const Icon(Icons.update, size: 18),
                label: const Text("Cập nhật trạng thái"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  side: BorderSide(color: Colors.blue[200]!),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget phụ chọn ngày
  Widget _buildDatePickerField({required String label, required DateTime? selectedDate, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: InputDecorator(decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(selectedDate != null ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}' : 'Chọn'), const Icon(Icons.calendar_today, size: 16, color: Colors.grey)])));
  }
  Future<DateTime?> _pickDate(BuildContext context, DateTime? initialDate) { return showDatePicker(context: context, initialDate: initialDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030)); }
}