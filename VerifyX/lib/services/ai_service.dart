import 'package:flutter/foundation.dart'; // Để kiểm tra kDebugMode
import 'base/api_service.dart'; // Import lớp ApiService của bạn
import '../core/constants/api_constants.dart'; // Import hằng số mới

// Lớp Message đơn giản để chứa dữ liệu chat
class ChatMessage {
  final String text;
  final bool isFromUser;
  ChatMessage({required this.text, required this.isFromUser});
}

class AiService {
  // Tạo một instance CỦA RIÊNG MÌNH từ ApiService,
  // nhưng trỏ đến baseUrl của AI
  final ApiService _apiService = ApiService(
    // Tự động chọn URL AI local nếu đang ở chế độ debug
    // TODO: Sau này bạn cần đổi 'ApiConstants.baseUrl' thành URL AI production của bạn
    
    // --- SỬA LỖI Ở ĐÂY ---
    // Đổi 'baseUrlAi' thành 'baseUrlAiLocal'
    baseUrl: kDebugMode ? ApiConstants.baseUrlAiLocal : ApiConstants.baseUrl,
  );

  /// Gửi tin nhắn đến AI server và nhận phản hồi
  Future<String> getAiResponse(String prompt) async {
    try {
      // Dùng phương thức .post() có sẵn của ApiService
      final response = await _apiService.post(
        '/api/ai/chat', // Endpoint trên ai-server.js
        body: {'prompt': prompt},
      );

      // response đã được ApiService xử lý và decode JSON
      // Chúng ta chỉ cần lấy nội dung 'reply'
      if (response != null && response['reply'] != null) {
        return response['reply'];
      } else {
        return "Lỗi: Không nhận được phản hồi hợp lệ.";
      }
    } on ApiException catch (e) {
      // Tận dụng lớp ApiException của bạn
      return "Lỗi AI: ${e.message}";
    } catch (e) {
      return "Lỗi không xác định: ${e.toString()}";
    }
  }
}