# 🏗️ Clean Architecture - VerifyX

## 📁 Cấu trúc mới đã tạo

```
lib/
├── core/                           # ✅ MỚI - Core components
│   ├── constants/
│   │   ├── app_colors.dart        # Màu sắc toàn app
│   │   ├── app_strings.dart       # Text constants
│   │   ├── app_sizes.dart         # Kích thước constants
│   │   ├── api_constants.dart     # API endpoints
│   │   └── constants.dart         # Barrel export
│   └── theme/
│       └── app_theme.dart         # Theme configuration
│
├── utils/                          # ✅ MỚI - Utilities
│   ├── validators.dart            # Validation functions
│   ├── formatters.dart            # Format dữ liệu
│   └── extensions.dart            # Extension methods
│
├── widgets/                        # ✅ MỚI - Shared widgets
│   └── common/
│       └── custom_button.dart     # Custom buttons
│
├── models/                         # ✅ ĐÃ CÓ
├── providers/                      # ✅ ĐÃ CÓ
├── services/                       # ✅ ĐÃ CÓ
├── screens/                        # ✅ ĐÃ CÓ
└── main.dart
```

---

## 🎯 Hướng dẫn sử dụng

### 1. **Constants - Sử dụng màu sắc & strings**

```dart
// ❌ TRƯỚC ĐÂY (Hard-coded)
Container(
  color: Color(0xFF00BCD4),
  child: Text('Đăng nhập'),
)

// ✅ BÂY GIỜ (Dùng constants)
import 'package:verifyx/core/constants/constants.dart';

Container(
  color: AppColors.primary,
  child: Text(AppStrings.login),
)
```

**Lợi ích:**
- ✅ Thay đổi màu/text 1 chỗ → áp dụng toàn app
- ✅ Dễ maintain & scale
- ✅ Tránh typo

---

### 2. **Theme - Cấu hình theme tập trung**

```dart
// Trong main.dart
import 'package:verifyx/core/theme/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,  // Dùng theme đã config sẵn
  // ...
)
```

**Bao gồm:**
- AppBar theme
- Button theme
- Input decoration theme
- Text theme
- Card theme

---

### 3. **Validators - Validate form input**

```dart
import 'package:verifyx/utils/validators.dart';

TextFormField(
  validator: Validators.email,  // Tự động validate email
)

TextFormField(
  validator: (value) => Validators.minLength(value, 6, 'Mật khẩu'),
)
```

**Các validator có sẵn:**
- `email()` - Validate email
- `password()` - Validate password
- `displayName()` - Validate tên
- `phoneNumber()` - Validate SĐT VN
- `required()` - Bắt buộc nhập
- `minLength()` / `maxLength()` - Độ dài

---

### 4. **Formatters - Format dữ liệu**

```dart
import 'package:verifyx/utils/formatters.dart';

// Format date
Formatters.date(DateTime.now());  // "08/11/2025"
Formatters.dateTime(DateTime.now());  // "14:30 08/11/2025"
Formatters.relativeTime(postDate);  // "5 phút trước"

// Format number
Formatters.number(1000000);  // "1,000,000"
Formatters.currency(1000000);  // "1,000,000 đ"

// Format string
Formatters.capitalize("hello");  // "Hello"
Formatters.truncate("Long text...", 10);  // "Long text..."
```

---

### 5. **Extensions - Mở rộng types có sẵn**

```dart
import 'package:verifyx/utils/extensions.dart';

// String extensions
"test@gmail.com".isValidEmail;  // true
"hello".capitalize;  // "Hello"

// DateTime extensions
DateTime.now().isToday;  // true
postDate.timeAgo;  // "2 giờ trước"
dateTime.formatted;  // "08/11/2025"

// BuildContext extensions
context.screenWidth;  // Lấy width màn hình
context.showSuccessSnackBar("Thành công!");
context.hideKeyboard();

// Int extensions
1000000.formatted;  // "1,000,000"
50000.toCurrency;  // "50,000 đ"
```

---

### 6. **Custom Widgets - Tái sử dụng widgets**

```dart
import 'package:verifyx/widgets/common/custom_button.dart';

// Nút gradient với loading
CustomButton(
  text: 'Đăng nhập',
  onPressed: _handleLogin,
  isLoading: isLoading,
  icon: Icons.login,
)

// Nút outline
CustomOutlineButton(
  text: 'Hủy',
  onPressed: () => Navigator.pop(context),
  borderColor: Colors.red,
)
```

---

## 🚀 Bước tiếp theo (TODO)

### 1. **Refactor main.dart**
- ✅ Tách theme sang AppTheme
- ⏳ Tạo AppRouter để quản lý routes
- ⏳ Di chuyển AuthWrapper sang file riêng

### 2. **Refactor screens**
- ⏳ Thay hard-coded colors → AppColors
- ⏳ Thay hard-coded strings → AppStrings
- ⏳ Dùng validators thay vì regex trực tiếp
- ⏳ Dùng extensions để code ngắn gọn hơn

### 3. **Tạo thêm widgets**
- ⏳ CustomTextField
- ⏳ LoadingIndicator
- ⏳ EmptyState
- ⏳ ErrorWidget

### 4. **API Service**
- ⏳ Tạo base ApiService để handle HTTP requests
- ⏳ Dùng ApiConstants cho endpoints
- ⏳ Error handling tập trung

### 5. **Routes & Navigation**
- ⏳ Tạo AppRoutes với named routes
- ⏳ Route guards cho auth

---

## 📝 Code Examples

### Example 1: Refactor Login Screen

```dart
// ❌ TRƯỚC
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color(0xFF00BCD4).withValues(alpha: 0.1),
        Colors.white,
      ],
    ),
  ),
)

// ✅ SAU
Container(
  decoration: BoxDecoration(
    gradient: AppColors.lightGradient,
  ),
)
```

### Example 2: Validation

```dart
// ❌ TRƯỚC
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Vui lòng nhập email';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Email không hợp lệ';
  }
  return null;
}

// ✅ SAU
validator: Validators.email
```

### Example 3: Show SnackBar

```dart
// ❌ TRƯỚC
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Thành công!'),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);

// ✅ SAU
context.showSuccessSnackBar('Thành công!');
```

---

## 🎨 Best Practices

1. **Constants** - Không hard-code giá trị
2. **Reusable** - Tạo widget tái sử dụng
3. **Clean Code** - Code ngắn gọn, dễ đọc
4. **Type Safety** - Dùng constants thay vì strings
5. **Maintainable** - Dễ bảo trì & mở rộng

---

## 📚 Tài liệu tham khảo

- `lib/core/constants/` - Tất cả constants
- `lib/utils/` - Helper functions
- `lib/widgets/common/` - Shared widgets
- `lib/core/theme/` - Theme configuration

---

**Tạo bởi:** VerifyX Clean Architecture Refactor
**Ngày:** 08/11/2025
