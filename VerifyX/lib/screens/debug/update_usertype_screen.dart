import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Màn hình Debug - Cập nhật UserType
/// CHỈ dùng để fix dữ liệu, không dùng trong production
class UpdateUserTypeScreen extends StatefulWidget {
  const UpdateUserTypeScreen({super.key});

  @override
  State<UpdateUserTypeScreen> createState() => _UpdateUserTypeScreenState();
}

class _UpdateUserTypeScreenState extends State<UpdateUserTypeScreen> {
  String? _currentUserType;
  String _selectedUserType = 'consumer';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserType();
  }

  Future<void> _loadCurrentUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        setState(() {
          _currentUserType = doc.data()?['userType'] ?? 'không xác định';
          _selectedUserType = _currentUserType == 'brand' || _currentUserType == 'admin' 
              ? _currentUserType! 
              : 'consumer';
        });
      }
    }
  }

  Future<void> _updateUserType() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'userType': _selectedUserType});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật thành công! userType = $_selectedUserType'),
              backgroundColor: Colors.green,
            ),
          );

          // Reload để kiểm tra
          await _loadCurrentUserType();

          // Sau 2 giây, restart app
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng đăng xuất và đăng nhập lại để áp dụng thay đổi'),
                  duration: Duration(seconds: 5),
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug: Cập nhật User Type'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ CHÚ Ý: Màn hình này chỉ để DEBUG',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            
            // Hiển thị User ID
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin hiện tại:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('User ID: ${FirebaseAuth.instance.currentUser?.uid ?? "N/A"}'),
                    Text('Email: ${FirebaseAuth.instance.currentUser?.email ?? "N/A"}'),
                    Text('UserType hiện tại: ${_currentUserType ?? "Đang tải..."}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Chọn User Type mới:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            // Radio buttons
            RadioListTile<String>(
              title: const Text('Consumer (Người dùng thường)'),
              value: 'consumer',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() => _selectedUserType = value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Brand (Thương hiệu)'),
              value: 'brand',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() => _selectedUserType = value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Admin (Quản trị viên)'),
              value: 'admin',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() => _selectedUserType = value!);
              },
            ),
            
            const SizedBox(height: 32),
            
            // Update button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateUserType,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CẬP NHẬT USER TYPE',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              '📌 Sau khi cập nhật, hãy đăng xuất và đăng nhập lại để áp dụng thay đổi.',
              style: TextStyle(
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
