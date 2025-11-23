import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Thư viện chọn ảnh
import 'package:dio/dio.dart'; // Thư viện upload ảnh
import '../../../core/constants/constants.dart';
import '../../../models/product_model.dart';
import '../../../models/brand/batch_model.dart';
import '../../../services/base/batch_service.dart';
import '../../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  final String brandId;
  final String brandName;

  const AddProductScreen({
    super.key,
    this.product,
    required this.brandId,
    required this.brandName,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Services
  final _batchService = BatchService();
  final _productService = ProductService();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _serialController = TextEditingController();
  
  // Controllers ngày tháng (chỉ hiển thị)
  final _mfgDateController = TextEditingController();
  final _expDateController = TextEditingController();

  // --- XỬ LÝ ẢNH CLOUDINARY ---
  Uint8List? _webImage; // Dữ liệu ảnh cho Web
  File? _pickedImage;   // File ảnh cho Mobile
  String? _imageUrl;    // URL ảnh
  bool _isUploadingImage = false;
  // ---------------------------

  bool _isLoading = false;
  
  // Dữ liệu lô hàng
  List<BatchModel> _batches = [];
  BatchModel? _selectedBatch;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _loadBatches();

    if (_isEditing) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _ingredientsController.text = widget.product!.ingredients;
      _categoryController.text = widget.product!.category;
      _serialController.text = widget.product!.serialNumber;
      _imageUrl = widget.product!.imageUrl;
    } else {
      _generateSerialNumber();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _ingredientsController.dispose();
    _serialController.dispose();
    _mfgDateController.dispose();
    _expDateController.dispose();
    super.dispose();
  }

  // Tải danh sách lô hàng
  Future<void> _loadBatches() async {
    final batches = await _batchService.getBatches(widget.brandId);
    if (mounted) setState(() => _batches = batches);
  }

  // Khi chọn lô hàng -> Tự điền ngày tháng
  void _onBatchSelected(BatchModel? batch) {
    setState(() {
      _selectedBatch = batch;
      if (batch != null) {
        _mfgDateController.text = "${batch.manufactureDate.day}/${batch.manufactureDate.month}/${batch.manufactureDate.year}";
        _expDateController.text = batch.expiryDate != null 
            ? "${batch.expiryDate!.day}/${batch.expiryDate!.month}/${batch.expiryDate!.year}" 
            : "Không có hạn";
      } else {
        _mfgDateController.clear();
        _expDateController.clear();
      }
    });
  }

  // 1. CHỌN ẢNH TỪ THƯ VIỆN
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
        _pickedImage = File(image.path);
        _imageUrl = null; // Xóa URL cũ để hiện ảnh mới chọn
      });
    }
  }

  // 2. UPLOAD LÊN CLOUDINARY (Đã điền thông tin của bạn)
  Future<String?> _uploadImageToCloudinary() async {
    // Nếu người dùng không chọn ảnh mới -> Trả về ảnh cũ (nếu đang edit)
    if (_webImage == null && _pickedImage == null) return _imageUrl;

    try {
      // --- CẤU HÌNH CỦA BẠN (ĐÃ ĐIỀN SẴN) ---
      const String cloudName = "dopm7cxdp"; 
      const String uploadPreset = "verifyx_preset"; 
      // -------------------------------------

      final dio = Dio();
      FormData formData = FormData.fromMap({
        "upload_preset": uploadPreset,
        "file": _webImage != null 
            ? MultipartFile.fromBytes(_webImage!, filename: "upload.jpg") // Dành cho Web
            : await MultipartFile.fromFile(_pickedImage!.path), // Dành cho Mobile
      });

      debugPrint("🚀 Đang upload ảnh lên Cloudinary ($cloudName)...");
      
      final response = await dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        final url = response.data['secure_url'];
        debugPrint("✅ Upload thành công: $url");
        return url;
      } else {
        debugPrint("❌ Upload thất bại: ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      debugPrint('❌ Lỗi kết nối Cloudinary: $e');
      return null;
    }
  }

  // 3. LƯU SẢN PHẨM (Quy trình: Upload Ảnh -> Lấy URL -> Gọi API Nodejs)
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Lô hàng'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploadingImage = true; // Bật trạng thái đang upload
    });

    try {
      // BƯỚC A: Upload ảnh lấy link
      String? finalImageUrl = await _uploadImageToCloudinary();
      
      setState(() => _isUploadingImage = false); // Tắt trạng thái upload

      // BƯỚC B: Gửi dữ liệu về Server (Kèm link ảnh)
      final success = await _productService.createProductApi(
        brandId: widget.brandId,
        brandName: widget.brandName,
        serialNumber: _serialController.text.trim(),
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: _ingredientsController.text.trim(),
        imageUrl: finalImageUrl, // URL từ Cloudinary
        batchId: _selectedBatch!.id,
        blockchainBatchId: _selectedBatch!.blockchainId, // Dùng getter mới
        manufacturingDate: _selectedBatch!.manufactureDate,
        expiryDate: _selectedBatch!.expiryDate ?? DateTime.now(),
      );

      if (success && mounted) {
        Navigator.pop(context, true); // Trả về true để màn hình danh sách biết mà reload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm sản phẩm thành công!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Sản phẩm' : 'Thêm Sản phẩm Mới'),
      ),
      body: (_isLoading && !_isUploadingImage) 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.paddingLG),
                children: [
                  _buildImageUpload(), // Widget chọn ảnh
                  const SizedBox(height: AppSizes.paddingLG),

                  // Dropdown Lô hàng
                  DropdownButtonFormField<BatchModel>(
                    decoration: const InputDecoration(
                      labelText: 'Chọn Lô hàng *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.layers),
                      filled: true,
                    ),
                    value: _selectedBatch,
                    isExpanded: true,
                    hint: const Text("Vui lòng chọn lô hàng"),
                    items: _batches.map((batch) {
                      return DropdownMenuItem(
                        value: batch,
                        child: Text("${batch.batchNumber} - ${batch.productName}"),
                      );
                    }).toList(),
                    onChanged: _isEditing ? null : _onBatchSelected,
                    validator: (val) => val == null ? 'Bắt buộc chọn lô hàng' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Các trường thông tin khác
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Tên sản phẩm *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Nhập tên sản phẩm' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Danh mục *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Nhập danh mục' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ingredientsController,
                    decoration: const InputDecoration(labelText: 'Thành phần', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _serialController,
                    decoration: InputDecoration(
                      labelText: 'Mã Serial *',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(icon: const Icon(Icons.refresh), onPressed: _generateSerialNumber),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),

                  // Nút Lưu
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveProduct,
                    icon: _isUploadingImage 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.cloud_upload),
                    label: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _isUploadingImage 
                            ? 'Đang tải ảnh lên Cloud...' 
                            : (_isLoading ? 'Đang xử lý Blockchain...' : 'Xác nhận & Đăng ký'),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget hiển thị khung ảnh
  Widget _buildImageUpload() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _webImage != null
            ? Image.memory(_webImage!, fit: BoxFit.cover) // Ảnh vừa chọn
            : (_imageUrl != null
                ? Image.network(_imageUrl!, fit: BoxFit.cover) // Ảnh cũ từ Cloudinary
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Chạm để tải ảnh lên Cloudinary"),
                    ],
                  )),
      ),
    );
  }

  void _generateSerialNumber() {
    setState(() {
      _serialController.text = "SN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    });
  }
}