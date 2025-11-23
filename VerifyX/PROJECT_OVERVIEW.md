# 📱 VerifyX - Tổng Quan Chức Năng

## 🎯 Mục Đích Dự Án
**VerifyX** là ứng dụng xác thực sản phẩm chính hãng sử dụng Firebase, AI và Blockchain.

---

## 👥 Phân Quyền User

### 1. **Consumer (Người dùng thường)**
- Quét mã QR để kiểm tra sản phẩm
- Xem lịch sử kiểm tra
- Tìm kiếm sản phẩm/thương hiệu
- Nhắn tin với support
- Yêu thích sản phẩm

### 2. **Manufacturer/Brand (Thương hiệu)**
- Tất cả quyền của Consumer
- Đăng bài về sản phẩm
- Quản lý sản phẩm của mình

### 3. **Admin (Quản trị viên)**
- Xem thống kê hệ thống
- Quản lý users
- Kiểm duyệt nội dung

---

## 🔐 Module Authentication (Auth)

### Screens:
1. **LoginScreen** (`lib/screens/auth/login_screen.dart`)
   - Đăng nhập email/password
   - Đăng nhập Google
   - Quên mật khẩu
   - Animation fade in/slide
   - Gradient background (Instagram/TikTok style)

2. **SignUpScreen** (`lib/screens/auth/signup_screen.dart`)
   - Đăng ký tài khoản mới
   - Chọn loại tài khoản (Consumer/Brand)
   - Validation form
   - Radio button cho user type

3. **ForgotPasswordScreen** (`lib/screens/auth/forgot_password_screen.dart`)
   - Reset mật khẩu qua email
   - Firebase Auth reset password

### Services:
- **AuthService** (`lib/services/auth_service.dart`)
  - `signIn()` - Đăng nhập
  - `signUp()` - Đăng ký
  - `signInWithGoogle()` - Đăng nhập Google
  - `signOut()` - Đăng xuất
  - `resetPassword()` - Reset mật khẩu

### Providers:
- **AuthProvider** (`lib/providers/auth_provider.dart`)
  - Quản lý auth state
  - Loading state
  - Error handling

---

## 🏠 Module Home (User Dashboard)

### HomeScreen (`lib/screens/home/home_screen.dart`)
Bottom Navigation với 5 tabs:

### 1. **HomePage** (Tab 1) - Trang chủ
📍 `lib/screens/home/pages/home_page.dart`

**Chức năng:**
- Header với avatar + notification
- Banner slider (Giảm giá, Khuyến mãi)
- Search bar
- 4 Feature cards:
  - 🔍 Scan QR - Quét mã sản phẩm
  - 📜 History - Lịch sử kiểm tra
  - ❤️ Favorite - Sản phẩm yêu thích
  - 📱 Support - Hỗ trợ khách hàng
- Recent products section
- Product verification results

### 2. **SearchPage** (Tab 2) - Tìm kiếm
📍 `lib/screens/home/pages/search_page.dart`

**Chức năng:**
- Search bar với icon
- Filter options (Loại sản phẩm, Thương hiệu, Giá)
- Popular searches
- Search history
- Product results grid

### 3. **ScanPage** (Tab 3) - Quét mã
📍 `lib/screens/home/pages/scan_page.dart`

**Chức năng:**
- Camera view để quét QR code
- Scan animation
- Verification result popup
- Product details sau khi scan
- Lưu lịch sử scan

### 4. **MessagesPage** (Tab 4) - Tin nhắn
📍 `lib/screens/home/pages/messages_page.dart`

**Chức năng:**
- Danh sách conversations
- Chat với support/brands
- Notification badge
- Real-time messaging (Firebase Realtime Database)

### 5. **MenuPage** (Tab 5) - Menu
📍 `lib/screens/home/pages/menu_page.dart`

**Chức năng:**
- Profile section (Avatar, Name, Email)
- Settings options:
  - 👤 Thông tin cá nhân
  - 📜 Lịch sử kiểm tra
  - ❤️ Sản phẩm yêu thích
  - ⚙️ Cài đặt
  - 💬 Trợ giúp & Hỗ trợ
  - ℹ️ Về VerifyX
  - 🚪 Đăng xuất

---

## 🔐 Module Admin

### AdminScreen (`lib/screens/admin/admin_screen.dart`)

**Chức năng:**
- 📊 Dashboard với thống kê:
  - Tổng số users
  - Consumer users
  - Manufacturer users
  - Admin users
- 📈 Biểu đồ thống kê
- 👥 Quản lý users:
  - Xem danh sách users
  - Lọc theo user type
  - Xem chi tiết user
  - Cấp/thu hồi quyền admin
- 📝 Quản lý posts
- 🔔 Notification management
- ⚙️ System settings

---

## 📝 Module Post

### CreatePostScreen (`lib/screens/post/create_post_screen.dart`)

**Chức năng:**
- Text editor cho content
- Upload ảnh (multiple)
- Image preview
- Chọn post type (Community/Brand)
- Publish/Draft
- Firestore storage

### Services:
- **PostService** (`lib/services/post_service.dart`)
  - `createPost()` - Tạo bài viết
  - `getPosts()` - Lấy danh sách posts
  - `likePost()` - Like bài viết
  - `commentPost()` - Comment bài viết
  - `deletePost()` - Xóa bài viết

---

## 📦 Data Models

### 1. **UserModel** (`lib/models/user_model.dart`)
```dart
{
  uid: String
  email: String
  displayName: String?
  photoURL: String?
  phoneNumber: String?
  createdAt: DateTime
  lastLogin: DateTime
  userType: 'consumer' | 'manufacturer' | 'admin'
}
```

### 2. **PostModel** (`lib/models/post_model.dart`)
```dart
{
  id: String
  authorId: String
  authorName: String
  authorPhotoUrl: String?
  content: String
  imageUrls: List<String>
  postType: 'community' | 'brand'
  likes: List<String>
  commentsCount: int
  createdAt: DateTime
  updatedAt: DateTime
}
```

### 3. **CommentModel** (`lib/models/comment_model.dart`)
```dart
{
  id: String
  postId: String
  authorId: String
  authorName: String
  content: String
  createdAt: DateTime
}
```

---

## 🎨 UI Components (Clean Architecture)

### Custom Widgets (`lib/widgets/common/`)

1. **CustomButton** - Gradient button với loading state
2. **CustomTextField** - Text input nhất quán
3. **PasswordTextField** - Password field với show/hide
4. **LoadingIndicator** - Loading spinner
5. **LoadingOverlay** - Full screen loading
6. **ErrorDisplay** - Error screen với retry
7. **ErrorCard** - Inline error card
8. **NetworkError** - Network error screen
9. **EmptyState** - Empty data state
10. **EmptyList** - Empty list variant
11. **EmptySearchResults** - No search results
12. **EmptyNotifications** - No notifications
13. **EmptyFavorites** - No favorites
14. **EmptyHistory** - No history
15. **EmptyMessages** - No messages

### Feature Widgets (`lib/screens/home/widgets/`)

1. **FeatureCard** - Card cho 4 features chính
2. **RecentProductCard** - Card sản phẩm gần đây
3. **BannerSlider** - Slider banner khuyến mãi

---

## 🏗️ Architecture & Infrastructure

### Core Modules (`lib/core/`)

#### 1. **Constants** (`lib/core/constants/`)
- **AppColors** - 15+ color constants, gradients
- **AppStrings** - 50+ text constants (tiếng Việt)
- **AppSizes** - padding, margin, font sizes
- **ApiConstants** - API endpoints, base URLs

#### 2. **Theme** (`lib/core/theme/`)
- **AppTheme** - Centralized theme configuration
  - Material 3 design
  - Light theme
  - Dark theme support

#### 3. **Routes** (`lib/core/routes/`)
- **AppRoutes** - Centralized navigation
  - Named routes
  - Route generator
  - Navigation helpers
  - Type-safe routing

#### 4. **Error Handling** (`lib/core/error/`)
- **ErrorHandler** - Centralized error handling
  - 20+ Firebase Auth error messages
  - Network error detection
  - Custom exceptions
  - User-friendly messages (tiếng Việt)

#### 5. **Auth** (`lib/core/auth/`)
- **AuthWrapper** - Auto auth check
  - StreamBuilder auth state
  - Role-based routing
  - Loading states

---

## 🔧 Services Layer

### Base Service (`lib/services/base/`)
- **ApiService** - Base HTTP client
  - GET, POST, PUT, PATCH, DELETE
  - Token management
  - Timeout configuration
  - Error handling
  - ApiException custom

### Domain Services (`lib/services/`)
1. **AuthService** - Authentication
2. **UserService** - User management
3. **PostService** - Post CRUD operations

---

## 🧪 Utils & Helpers (`lib/utils/`)

### 1. **Validators**
- `email()` - Email validation
- `password()` - Password validation (min 6 chars)
- `confirmPassword()` - Confirm password match
- `displayName()` - Name validation (min 2 chars)
- `phoneNumber()` - Vietnam phone format
- `required()` - Generic required field
- `minLength()` - Min length validation
- `maxLength()` - Max length validation

### 2. **Formatters**
- `formatDate()` - Format DateTime
- `formatCurrency()` - Format VND
- `formatNumber()` - Format numbers

### 3. **Extensions**
- **String extensions:**
  - `isValidEmail`
  - `isValidPhone`
  - `capitalize()`
  - `toSlug()`

- **DateTime extensions:**
  - `timeAgo()`
  - `isToday()`
  - `isTomorrow()`

- **BuildContext extensions:**
  - `showSnackBar()`
  - `showLoadingDialog()`
  - `hideDialog()`

- **Int/Double extensions:**
  - `toCurrency()`
  - `toPercentage()`

---

## 🔥 Firebase Integration

### Services Used:
1. **Firebase Authentication**
   - Email/Password
   - Google Sign-In
   - Password reset

2. **Cloud Firestore**
   - Collections:
     - `users` - User profiles
     - `posts` - User posts
     - `comments` - Post comments
     - `products` - Product database
     - `verifications` - Scan history

3. **Firebase Realtime Database**
   - Real-time messaging
   - Online presence

4. **Firebase Storage** (Planned)
   - User avatars
   - Post images
   - Product images

---

## 📊 State Management

**Provider Pattern:**
- `AuthProvider` - Authentication state
- `UserProvider` - User data
- `PostProvider` - Posts data

---

## 🎨 Design System

### Colors:
- Primary: Cyan (#00BCD4)
- Secondary: Light blue (#4DD0E1)
- Success: Green (#4CAF50)
- Warning: Orange (#FF9800)
- Error: Red (#F44336)
- Gradients: Primary, Light, Dark

### Typography:
- Font sizes: XS (12), SM (14), MD (16), LG (18), XL (24)
- Font weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Spacing:
- XS: 4px, SM: 8px, MD: 16px, LG: 24px, XL: 32px

---

## 📈 Features Roadmap

### ✅ Implemented:
- [x] Authentication (Login, Signup, Google Sign-in)
- [x] User roles (Consumer, Brand, Admin)
- [x] Home dashboard with 5 tabs
- [x] Post creation
- [x] Admin dashboard
- [x] Clean Architecture setup
- [x] Custom UI components
- [x] Error handling
- [x] Form validation

### 🚧 In Progress:
- [ ] QR code scanning
- [ ] Product verification
- [ ] Real-time messaging
- [ ] Search functionality

### 📋 Planned:
- [ ] Push notifications
- [ ] Product favorites
- [ ] Scan history
- [ ] Analytics dashboard
- [ ] Blockchain integration
- [ ] AI verification
- [ ] Multi-language support (i18n)
- [ ] Dark mode
- [ ] Offline support

---

## 📁 Project Structure

```
lib/
├── core/                    # Core modules
│   ├── auth/               # Auth wrapper
│   ├── constants/          # App constants
│   ├── error/              # Error handling
│   ├── routes/             # Navigation
│   └── theme/              # Theme config
├── models/                  # Data models
├── providers/               # State management
├── screens/                 # UI screens
│   ├── admin/              # Admin screens
│   ├── auth/               # Auth screens
│   ├── home/               # Home screens
│   └── post/               # Post screens
├── services/                # Business logic
│   └── base/               # Base services
├── utils/                   # Utilities
│   ├── validators.dart
│   ├── formatters.dart
│   └── extensions.dart
├── widgets/                 # Reusable widgets
│   └── common/             # Common widgets
└── main.dart               # App entry point
```

---

## 🔢 Statistics

- **Total Screens:** 10+
- **Custom Widgets:** 15+
- **Services:** 4
- **Models:** 3
- **Providers:** 3
- **Utilities:** 30+ functions
- **Lines of Code:** ~5000+

---

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build for production
flutter build apk
flutter build ios
```

---

**Version:** 1.0.0  
**Last Updated:** November 9, 2025
