// [ĐÃ THÊM] - import cho Cloudinary
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// [ĐÃ XÓA] - import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/post_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CREATE POST SCREEN - Màn hình tạo bài viết mới
/// ═══════════════════════════════════════════════════════════════════════════
class CreatePostScreen extends StatefulWidget {
  /// Có tự động mở image picker khi vào màn hình không
  /// (Khi user nhấn nút ảnh từ trang chủ)
  final bool openImagePicker;
  
  const CreatePostScreen({
    super.key,
    this.openImagePicker = false,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  /// Controller cho TextField nhập nội dung
  final TextEditingController _contentController = TextEditingController();
  
  /// Ảnh đã chọn (XFile) và dữ liệu bytes để preview/upload
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _selectedImageMimeType;

  /// Công cụ chọn ảnh và service đăng bài
  final ImagePicker _imagePicker = ImagePicker();
  final PostService _postService = PostService();
  
  /// Đang trong quá trình đăng bài hay không
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    if (widget.openImagePicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickImage());
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo bài viết'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
            ),
          ),
        ),
        actions: [
          // Nút Đăng (disable khi đang posting)
          TextButton(
            onPressed: _isPosting ? null : _handlePost,
            child: Text(
              'Đăng',
              style: TextStyle(
                color: _isPosting ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Tên user
            _buildUserHeader(currentUser),
            
            const SizedBox(height: 16),
            
            // TextField nhập nội dung
            TextField(
              controller: _contentController,
              maxLines: 8,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Bạn đang nghĩ gì?',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 18),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            
            // Preview ảnh đã chọn (nếu có)
            if (_selectedImageBytes != null)
              _buildImagePreview(),
            
            const SizedBox(height: 16),
            
            // Nút thêm ảnh
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, color: Color(0xFF00BCD4)),
              label: const Text('Thêm ảnh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00BCD4),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// Header: Avatar + Tên người dùng
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildUserHeader(User? currentUser) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final displayName = userData?['displayName'] ?? 'User';
        final photoURL = userData?['photoURL'];

        return Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF00BCD4),
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null
                  ? Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// Preview ảnh đã chọn với nút xóa
  /// ───────────────────────────────────────────────────────────────────────
  Widget _buildImagePreview() {
    if (_selectedImageBytes == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            _selectedImageBytes!,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Nút xóa ảnh (X ở góc phải trên)
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _selectedImageFile = null;
                _selectedImageBytes = null;
                _selectedImageMimeType = null;
              });
            },
          ),
        ),
      ],
    );
  }

  /// ───────────────────────────────────────────────────────────────────────
  /// Chọn ảnh từ thư viện và lưu bytes để preview/upload
  /// ───────────────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: kIsWeb ? null : 85,
      );

      if (pickedFile == null) {
        return;
      }

      final imageBytes = await pickedFile.readAsBytes();
      final mimeType = pickedFile.mimeType ??
          _guessMimeType(kIsWeb ? pickedFile.name : pickedFile.path);

      if (!mounted) return;

      setState(() {
        _selectedImageFile = pickedFile;
        _selectedImageBytes = imageBytes;
        _selectedImageMimeType = mimeType;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $error')),
      );
    }
  }

  String _guessMimeType(String? input) {
    final value = input?.toLowerCase() ?? '';
    if (value.endsWith('.png')) return 'image/png';
    if (value.endsWith('.gif')) return 'image/gif';
    if (value.endsWith('.webp')) return 'image/webp';
    if (value.endsWith('.bmp')) return 'image/bmp';
    if (value.endsWith('.heic') || value.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  String _resolveFileExtension() {
    final fallbackMimeType = _selectedImageMimeType ?? 'image/jpeg';

    String? candidate = _selectedImageFile?.name;
    if (candidate == null || candidate.isEmpty) {
      candidate = _selectedImageFile?.path ?? '';
    }

    final lower = candidate.toLowerCase();
    final dotIndex = lower.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < lower.length - 1) {
      final ext = lower.substring(dotIndex + 1);
      if (ext.isNotEmpty && ext.length <= 5) {
        return ext;
      }
    }

    if (fallbackMimeType.startsWith('image/')) {
      return fallbackMimeType.split('/').last;
    }

    return 'jpg';
  }

  // [ĐÃ SỬA] - TOÀN BỘ HÀM NÀY ĐÃ ĐƯỢC THAY BẰNG CODE CLOUDINARY
  // [ĐÃ SỬA] - TOÀN BỘ HÀM NÀY ĐÃ ĐƯỢC THAY BẰNG CODE CLOUDINARY
Future<String> _uploadImage(String userId) async {
  if (_selectedImageBytes == null) {
    throw Exception('Không có ảnh để tải lên');
  }

  // --- Thông tin Cloudinary của bạn (Đã kiểm tra kỹ) ---
const String cloudName = "dopm7cxdp";
  const String uploadPreset = "verifyx_preset";
  // --------------------------------------------------

  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  // Tạo một multipart request
  final request = http.MultipartRequest('POST', url);

  // Thêm các trường cần thiết cho Cloudinary
  request.fields['upload_preset'] = uploadPreset;
  
  // Lấy tên file
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final extension = _resolveFileExtension(); // Dùng lại hàm cũ của bạn
  final filename = '$userId-$timestamp.$extension';

  // Thêm file ảnh từ bytes
  request.files.add(
    http.MultipartFile.fromBytes(
      'file', // Tên trường 'file' là bắt buộc
      _selectedImageBytes!,
      filename: filename,
    ),
  );

  // Gửi request
  debugPrint('[Cloudinary] Đang tải ảnh lên...');
  final streamedResponse = await request.send();

  // Đọc response
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    // Upload thành công
    final responseData = jsonDecode(response.body);
    final imageUrl = responseData['secure_url'] as String?;

    if (imageUrl == null) {
      throw Exception('Không thể lấy "secure_url" từ Cloudinary');
    }

    debugPrint('[Cloudinary] Tải ảnh thành công: $imageUrl');
    return imageUrl;
  } else {
    // Upload thất bại
    debugPrint('[Cloudinary] Lỗi tải ảnh: ${response.body}');
    throw Exception('Upload ảnh thất bại: ${response.statusCode}');
  }
}

  /// ───────────────────────────────────────────────────────────────────────
  /// Đăng bài viết lên Firestore
  /// Validate: Phải có nội dung hoặc ảnh
  /// ───────────────────────────────────────────────────────────────────────
  Future<void> _handlePost() async {
    final content = _contentController.text.trim();
    
    // Validate: Phải có nội dung hoặc ảnh
    if (content.isEmpty && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung hoặc chọn ảnh')),
      );
      return;
    }

    // Bắt đầu posting
    setState(() {
      _isPosting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Bạn phải đăng nhập để đăng bài');
      }

      debugPrint('[CreatePost] Start posting for user ${currentUser.uid}');

      // Lấy userType của người đăng để phân loại bài viết
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userTypeRaw = userDoc.data()?['userType'] as String?;
      final userType = userTypeRaw?.toLowerCase() ?? 'consumer';
      
      // Xác định postType: consumer → 'community', brand → 'brand'
      final postType = (userType == 'brand') ? 'brand' : 'community';

      debugPrint('[CreatePost] userType=$userType postType=$postType');

      String? imageUrl;
      if (_selectedImageBytes != null) {
        debugPrint('[CreatePost] Uploading image...');
        // [KHÔNG ĐỔI] - Dòng này sẽ tự động gọi hàm _uploadImage của Cloudinary
        imageUrl = await _uploadImage(currentUser.uid);
        if (imageUrl.length > 32) {
          debugPrint('[CreatePost] Image uploaded: ${imageUrl.substring(0, 32)}...');
        } else {
          debugPrint('[CreatePost] Image uploaded: $imageUrl');
        }
      }

      final postId = await _postService.createPost(
        content: content,
        postType: postType,
        imageUrls: imageUrl != null ? <String>[imageUrl] : const <String>[],
      );

      debugPrint('[CreatePost] Post created: $postId');

      if (mounted) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop(true);
          // [ĐÃ SỬA] - Đã xóa dòng chữ rác ở đây
        }
        Future.microtask(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng bài thành công!')),
          );
        });
      }
    } catch (e) {
      // Lỗi: Hiển thị thông báo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      // Kết thúc posting
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }
}