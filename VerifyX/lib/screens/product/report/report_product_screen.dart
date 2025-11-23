import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../providers/report_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// REPORT PRODUCT SCREEN - Báo cáo sản phẩm giả
/// ═══════════════════════════════════════════════════════════════════════════
class ReportProductScreen extends StatefulWidget {
  final ProductModel product;

  const ReportProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<ReportProductScreen> createState() => _ReportProductScreenState();
}

class _ReportProductScreenState extends State<ReportProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'counterfeit';
  
  final List<Map<String, String>> _reportTypes = [
    {'value': 'counterfeit', 'label': 'Hàng giả', 'icon': '🚫'},
    {'value': 'damaged', 'label': 'Hàng hỏng', 'icon': '💔'},
    {'value': 'expired', 'label': 'Hết hạn', 'icon': '⏰'},
    {'value': 'mislabeled', 'label': 'Sai nhãn', 'icon': '🏷️'},
    {'value': 'other', 'label': 'Khác', 'icon': '❓'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    final userModel = authProvider.userModel;
    if (userModel == null) return;

    final success = await reportProvider.createReport(
      productId: widget.product.id,
      serialNumber: widget.product.serialNumber,
      userId: userModel.uid,
      userName: userModel.displayName ?? 'User',
      reportType: _selectedType,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi báo cáo thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reportProvider.error ?? 'Không thể gửi báo cáo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo sản phẩm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Info Card
              _buildProductCard(),
              
              const SizedBox(height: 32),
              
              // Report Type
              const Text(
                'Loại báo cáo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              ...List.generate(_reportTypes.length, (index) {
                final type = _reportTypes[index];
                return _buildReportTypeOption(
                  value: type['value']!,
                  label: type['label']!,
                  icon: type['icon']!,
                );
              }),
              
              const SizedBox(height: 32),
              
              // Description
              const Text(
                'Mô tả chi tiết',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Mô tả vấn đề của sản phẩm...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  if (value.length < 20) {
                    return 'Mô tả phải có ít nhất 20 ký tự';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              Consumer<ReportProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Gửi báo cáo',
                    onPressed: provider.isLoading ? null : _submitReport,
                    isLoading: provider.isLoading,
                    icon: Icons.send,
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Báo cáo sẽ được ghi trên Blockchain và không thể xóa',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm báo cáo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.product.brandName,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.product.serialNumber,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeOption({
    required String value,
    required String label,
    required String icon,
  }) {
    final isSelected = _selectedType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
