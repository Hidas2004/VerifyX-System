/// ═══════════════════════════════════════════════════════════════════════════
/// APP STRINGS - Tất cả text constants trong app
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Lợi ích:
/// - Dễ đa ngôn ngữ (i18n) sau này
/// - Tránh typo
/// - Quản lý tập trung
class AppStrings {
  AppStrings._();

  // ==================== APP INFO ====================
  static const String appName = 'VerifyX';
  static const String appVersion = 'v1.0.0';
  static const String appSlogan = 'Xác thực sản phẩm chính hãng';
  static const String appDescription =
      'Hệ thống xác thực sản phẩm chính hãng\nỨng dụng AI và Blockchain';
  static const String copyright = '© 2025 VerifyX Team';

  // ==================== AUTH ====================
  static const String login = 'Đăng nhập';
  static const String signUp = 'Đăng ký';
  static const String signUpNow = 'Đăng ký ngay';
  static const String logout = 'Đăng xuất';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String dontHaveAccount = 'Chưa có tài khoản? ';
  static const String alreadyHaveAccount = 'Đã có tài khoản? ';
  static const String loginNow = 'Đăng nhập ngay';

  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String displayName = 'Họ và tên';

  static const String loginWithGoogle = 'Đăng nhập bằng Google';
  static const String or = 'hoặc';

  // ==================== VALIDATION ====================
  static const String emailRequired = 'Vui lòng nhập email';
  static const String emailInvalid = 'Email không hợp lệ';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static const String passwordTooShort = 'Mật khẩu phải có ít nhất 6 ký tự';
  static const String passwordNotMatch = 'Mật khẩu không khớp';
  static const String nameRequired = 'Vui lòng nhập họ và tên';
  static const String nameTooShort = 'Tên phải có ít nhất 2 ký tự';

  // ==================== MESSAGES ====================
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String signUpSuccess = 'Đăng ký thành công!';
  static const String logoutSuccess = 'Đã đăng xuất';
  static const String featureInDevelopment = 'Tính năng đang phát triển';
  static const String somethingWentWrong = 'Đã có lỗi xảy ra';
  static const String noInternet = 'Không có kết nối mạng';
  static const String loading = 'Đang tải...';

  // ==================== COMMENTS ====================
  static const String commentsTitle = 'Bình luận';
  static const String commentHint = 'Viết bình luận...';
  static const String commentEmptyTitle = 'Chưa có bình luận nào';
  static const String commentEmptySubtitle = 'Hãy là người đầu tiên bình luận!';
  static const String commentSend = 'Gửi';

  // ==================== NAVIGATION ====================
  static const String home = 'Trang chủ';
  static const String search = 'Tìm kiếm';
  static const String scan = 'Quét mã';
  static const String messages = 'Tin nhắn';
  static const String menu = 'Menu';

  // ==================== USER TYPES ====================
  static const String userTypeConsumer = 'Người dùng';
  static const String userTypeBrand = 'Thương hiệu';
  static const String userTypeAdmin = 'Quản trị viên';
  static const String accountType = 'Loại tài khoản:';
  static const String regularAccount = 'Tài khoản thường';
  static const String businessAccount = 'Tài khoản doanh nghiệp';

  // ==================== ADMIN ====================
  static const String adminDashboard = 'Admin Dashboard';
  static const String statistics = 'Thống kê';
  static const String totalUsers = 'Tổng người dùng';
  static const String refresh = 'Làm mới';

  // ==================== PROFILE ====================
  static const String profile = 'Thông tin cá nhân';
  static const String history = 'Lịch sử kiểm tra';
  static const String favorites = 'Sản phẩm yêu thích';
  static const String settings = 'Cài đặt';
  static const String helpSupport = 'Trợ giúp & Hỗ trợ';
  static const String about = 'Về VerifyX';

  // ==================== CHAT ====================
  static const String supportChatTitle = 'Hỗ trợ VerifyX';
  static const String chatInputHint = 'Nhập tin nhắn...';
  static const String chatEmptyTitle = 'Chưa có cuộc trò chuyện';
  static const String chatEmptySubtitle =
      'Tin nhắn của bạn với đội ngũ VerifyX sẽ hiển thị tại đây.';
  static const String adminInbox = 'Hộp thư hỗ trợ';
  static const String lastActivity = 'Hoạt động cuối';

  // ==================== COMMON ====================
  static const String save = 'Lưu';
  static const String cancel = 'Hủy';
  static const String delete = 'Xóa';
  static const String edit = 'Sửa';
  static const String confirm = 'Xác nhận';
  static const String close = 'Đóng';
  static const String yes = 'Có';
  static const String no = 'Không';
  static const String ok = 'OK';
}
