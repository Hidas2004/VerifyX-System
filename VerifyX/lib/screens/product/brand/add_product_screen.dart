import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ADD PRODUCT SCREEN - Brand đăng ký sản phẩm mới
/// ═══════════════════════════════════════════════════════════════════════════
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _distributorController = TextEditingController();
  final _retailerController = TextEditingController();
  final _retailLocationController = TextEditingController();
  
  String _selectedCategory = 'electronics';
  DateTime _manufacturingDate = DateTime.now();
  DateTime _warehouseDate = DateTime.now();
  
  final List<Map<String, String>> _categories = [
    {'value': 'electronics', 'label': 'Điện tử', 'icon': '📱'},
    {'value': 'fashion', 'label': 'Thời trang', 'icon': '👕'},
    {'value': 'food', 'label': 'Thực phẩm', 'icon': '🍎'},
    {'value': 'cosmetics', 'label': 'Mỹ phẩm', 'icon': '💄'},
    {'value': 'pharmaceutical', 'label': 'Dược phẩm', 'icon': '💊'},
    {'value': 'jewelry', 'label': 'Trang sức', 'icon': '💎'},
    {'value': 'automotive', 'label': 'Ô tô', 'icon': '🚗'},
    {'value': 'other', 'label': 'Khác', 'icon': '📦'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    _distributorController.dispose();
    _retailerController.dispose();
    _retailLocationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isManufacturing) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isManufacturing ? _manufacturingDate : _warehouseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isManufacturing) {
          _manufacturingDate = picked;
        } else {
          _warehouseDate = picked;
        }
      });
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    final userModel = authProvider.userModel;
    if (userModel == null) return;

    final success = await productProvider.createProduct(
      brandId: userModel.uid,
      brandName: userModel.displayName ?? 'Brand',
      name: _nameController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      manufacturer: _manufacturerController.text.trim(),
      manufacturingDate: _manufacturingDate,
      warehouseDate: _warehouseDate,
      distributor: _distributorController.text.trim().isEmpty 
          ? null 
          : _distributorController.text.trim(),
      retailer: _retailerController.text.trim().isEmpty 
          ? null 
          : _retailerController.text.trim(),
      retailLocation: _retailLocationController.text.trim().isEmpty 
          ? null 
          : _retailLocationController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sản phẩm đã được tạo và ghi lên Blockchain'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.error ?? 'Không thể tạo sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký sản phẩm mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sản phẩm sẽ được mã hóa và ghi trên Blockchain',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Basic Info
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _nameController,
                labelText: 'Tên sản phẩm *',
                hintText: 'Ví dụ: iPhone 15 Pro Max',
                prefixIcon: Icons.inventory,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Mô tả *',
                hintText: 'Mô tả chi tiết về sản phẩm',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category
              const Text(
                'Danh mục *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['value'];
                  return ChoiceChip(
                    label: Text('${cat['icon']} ${cat['label']}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat['value']!;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.3),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Supply Chain
              _buildSectionTitle('Chuỗi cung ứng'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _manufacturerController,
                labelText: 'Nhà sản xuất *',
                hintText: 'Tên nhà máy sản xuất',
                prefixIcon: Icons.factory,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nhà sản xuất';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Manufacturing Date
              _buildDatePicker(
                label: 'Ngày sản xuất *',
                date: _manufacturingDate,
                onTap: () => _selectDate(context, true),
              ),
              
              const SizedBox(height: 16),
              
              // Warehouse Date
              _buildDatePicker(
                label: 'Ngày nhập kho *',
                date: _warehouseDate,
                onTap: () => _selectDate(context, false),
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _distributorController,
                labelText: 'Nhà phân phối',
                hintText: 'Tùy chọn',
                prefixIcon: Icons.local_shipping,
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _retailerController,
                labelText: 'Nhà bán lẻ',
                hintText: 'Tùy chọn',
                prefixIcon: Icons.store,
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _retailLocationController,
                labelText: 'Địa điểm bán lẻ',
                hintText: 'Ví dụ: Hà Nội, TP.HCM',
                prefixIcon: Icons.location_on,
              ),
              
              const SizedBox(height: 40),
              
              // Submit Button
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Tạo sản phẩm',
                    onPressed: provider.isLoading ? null : _submitProduct,
                    isLoading: provider.isLoading,
                    icon: Icons.add_circle,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
