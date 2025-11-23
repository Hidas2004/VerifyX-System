/// ═══════════════════════════════════════════════════════════════════════════
/// FORMATTERS - Các hàm format dữ liệu
/// ═══════════════════════════════════════════════════════════════════════════
class Formatters {
  Formatters._();

  // ==================== DATE & TIME ====================
  
  /// Format DateTime thành string dạng "dd/MM/yyyy"
  /// 
  /// Example: 08/11/2025
  static String date(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }
  
  /// Format DateTime thành string dạng "HH:mm dd/MM/yyyy"
  /// 
  /// Example: 14:30 08/11/2025
  static String dateTime(DateTime dateTime) {
    final timeStr = time(dateTime);
    final dateStr = date(dateTime);
    return '$timeStr $dateStr';
  }
  
  /// Format DateTime thành string dạng "HH:mm"
  /// 
  /// Example: 14:30
  static String time(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// Format DateTime thành relative time
  /// 
  /// Example: "Vừa xong", "5 phút trước", "2 giờ trước", "3 ngày trước"
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }

  // ==================== NUMBER ====================
  
  /// Format số thành string có dấu phẩy phân cách
  /// 
  /// Example: 1000000 → "1,000,000"
  static String number(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  
  /// Format số thành currency (VNĐ)
  /// 
  /// Example: 1000000 → "1,000,000 đ"
  static String currency(int amount) {
    return '${number(amount)} đ';
  }
  
  /// Format số thành percentage
  /// 
  /// Example: 0.85 → "85%"
  static String percentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  // ==================== STRING ====================
  
  /// Capitalize first letter
  /// 
  /// Example: "hello world" → "Hello world"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  /// Capitalize each word
  /// 
  /// Example: "hello world" → "Hello World"
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  /// Truncate text với ellipsis
  /// 
  /// Example: "This is a long text" → "This is a..."
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ==================== PHONE ====================
  
  /// Format phone number
  /// 
  /// Example: "0987654321" → "098 765 4321"
  static String phoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
  }

  // ==================== FILE SIZE ====================
  
  /// Format file size
  /// 
  /// Example: 1024 → "1 KB", 1048576 → "1 MB"
  static String fileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    }
  }
}
