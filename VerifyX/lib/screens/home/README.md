# Cấu trúc thư mục screens/home

## 📁 Tổ chức file

```
screens/home/
├── home_screen.dart          # Main screen với BottomNavigationBar
├── pages/                    # Các trang con (5 tabs)
│   ├── home_page.dart       # Tab 1: News Feed (giống Facebook)
│   ├── search_page.dart     # Tab 2: Tìm kiếm
│   ├── scan_page.dart       # Tab 3: Quét mã QR
│   ├── messages_page.dart   # Tab 4: Tin nhắn
│   └── menu_page.dart       # Tab 5: Menu & Cài đặt
└── widgets/                  # Widgets tái sử dụng
    ├── create_post_button.dart   # Header tạo bài viết
    ├── post_card.dart            # Card hiển thị bài viết
    ├── feature_card.dart         # Card tính năng (cũ - có thể xóa)
    └── recent_product_card.dart  # Card sản phẩm (cũ - có thể xóa)
```

## 🎯 Mục đích phân chia

### 1. **home_screen.dart** - Màn hình chính
- Quản lý BottomNavigationBar với 5 tabs
- Điều hướng giữa các pages
- **Không chứa logic UI phức tạp**

### 2. **pages/** - Các trang độc lập
Mỗi tab là một file riêng, dễ bảo trì và phát triển:

#### **home_page.dart** - News Feed (UPDATED ✨)
- Header với nút "Bạn đang nghĩ gì?" (giống Facebook)
- Feed hiển thị bài viết từ Firestore
- Realtime updates với StreamBuilder
- **Import widgets:** `create_post_button.dart`, `post_card.dart`

#### **search_page.dart**  
- TextField tìm kiếm
- Các tag tìm kiếm phổ biến
- Kết quả tìm kiếm (TODO)

#### **scan_page.dart**
- UI quét QR code
- Nhập mã thủ công
- Xác thực sản phẩm (TODO)

#### **messages_page.dart**
- Danh sách tin nhắn
- Chat với support (TODO)

#### **menu_page.dart**
- Profile user
- Các menu settings
- Đăng xuất

### 3. **widgets/** - Components tái sử dụng (UPDATED ✨)

#### **create_post_button.dart** - NEW
Header giống Facebook với:
- Avatar user bên trái
- Nút "Bạn đang nghĩ gì?" ở giữa
- Icon ảnh bên phải
- Navigation đến `CreatePostScreen`

```dart
// Usage
const CreatePostButton()
```

#### **post_card.dart** - NEW
Card hiển thị bài viết với:
- Header: Avatar + Tên + Thời gian + Menu
- Nội dung text
- Ảnh (nếu có)
- Số lượt like
- Buttons: Like ❤️, Comment 💬, Share 🔗

```dart
// Usage
PostCard(
  postId: 'post123',
  postData: {
    'userId': 'user456',
    'content': 'Hello world',
    'imageUrl': 'https://...',
    'likes': ['user1', 'user2'],
    'createdAt': Timestamp.now(),
  },
)
```

#### **feature_card.dart** - Cũ (có thể xóa)
```dart
FeatureCard(
  icon: Icons.qr_code_scanner,
  title: 'Quét QR',
  color: Colors.blue,
  onTap: () {},
)
```

#### **recent_product_card.dart** - Cũ (có thể xóa)
```dart
RecentProductCard(
  productName: 'iPhone 15',
  brand: 'Apple',
  status: 'Chính hãng',
  statusColor: Colors.green,
  onTap: () {},
)
```

## ✅ Ưu điểm của cấu trúc này

1. **Dễ bảo trì**: Mỗi feature trong 1 file riêng
2. **Tái sử dụng**: Widgets có thể dùng ở nhiều nơi
3. **Scalable**: Dễ thêm tính năng mới
4. **Clean Code**: Code ngắn gọn, dễ đọc
5. **Team Work**: Nhiều người code cùng lúc không conflict
6. **Modular**: Tách biệt logic giữa Screen, Widget, Service

## � Liên kết với Modules khác

### Post Module (screens/post/)
- `create_post_screen.dart` - Màn hình tạo bài viết
- Được navigate từ `create_post_button.dart`

## �🚀 Cách phát triển tiếp

### Thêm tính năng mới cho tab:
1. Mở file page tương ứng (vd: `scan_page.dart`)
2. Thêm logic vào file đó
3. Không ảnh hưởng các page khác

### Tạo widget mới:
1. Tạo file trong `widgets/`
2. Export và sử dụng ở bất kỳ page nào
3. Đặt tên rõ ràng: `<tên>_<loại>.dart` (vd: `post_card.dart`)

### Thêm tab mới:
1. Tạo file page mới trong `pages/`
2. Thêm vào list `_pages` trong `home_screen.dart`
3. Thêm item vào `BottomNavigationBar`

## 📝 Ví dụ thêm tính năng

### Thêm chức năng Comment cho Post:
```dart
// 1. Tạo file widgets/comment_section.dart
class CommentSection extends StatelessWidget {
  final String postId;
  // ... code
}

// 2. Import vào post_card.dart
import 'comment_section.dart';

// 3. Thêm vào PostCard
CommentSection(postId: postId)
```

## 🎨 Coding Convention

- File name: `snake_case.dart`
- Class name: `PascalCase`
- Widget nhỏ: Tách thành method `_buildXxx()`
- Widget lớn/tái sử dụng: Tách thành file riêng trong `widgets/`
- State management: Sử dụng Provider (đã có)
- Comments: Tiếng Việt cho dễ hiểu
- Modular: 1 file = 1 responsibility

## 🔧 TODO - Các tính năng cần phát triển

### Home Page (News Feed)
- [ ] Implement image_picker cho upload ảnh
- [ ] Upload ảnh lên Firebase Storage
- [ ] Comment section
- [ ] Edit/Delete post
- [ ] Share post
- [ ] Pull-to-refresh
- [ ] Infinite scroll pagination

### Other Pages
- [ ] Implement QR Scanner (scan_page.dart)
- [ ] Implement Search functionality (search_page.dart)  
- [ ] Implement Chat/Messages (messages_page.dart)
- [ ] Add Product Detail Screen
- [ ] Add History Screen
- [ ] Add Favorites Screen
- [ ] Add Settings Screen

### Integration
- [ ] Integrate Blockchain verification
- [ ] Integrate AI image recognition
