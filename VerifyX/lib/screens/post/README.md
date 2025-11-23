# 📝 Post Module - Quản lý Bài Viết

Module chứa các màn hình và widget liên quan đến tính năng đăng bài (giống Facebook/Instagram).

## 📁 Cấu trúc Folder

```
lib/screens/post/
├── create_post_screen.dart   # Màn hình tạo bài viết mới
└── README.md                  # File này
```

## 📄 Chi tiết Files

### `create_post_screen.dart`
**Màn hình tạo bài viết mới**

**Mục đích:**
- Cho phép người dùng tạo bài viết mới
- Nhập nội dung text
- Upload ảnh (TODO: cần image_picker)
- Lưu bài viết vào Firestore

**Widgets:**
- `CreatePostScreen` - StatefulWidget chính
- `_CreatePostScreenState` - State quản lý form

**Dependencies:**
- `firebase_auth` - Lấy thông tin user hiện tại
- `cloud_firestore` - Lưu bài viết vào database

**Firestore Structure:**
```dart
posts/ {
  userId: string,
  content: string,
  imageUrl: string?,
  likes: array<string>,
  createdAt: timestamp
}
```

**Usage Example:**
```dart
// Navigation từ home page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CreatePostScreen(),
  ),
);

// Mở với image picker
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const CreatePostScreen(openImagePicker: true),
  ),
);
```

## 🔗 Liên kết với Modules khác

### Home Module
- `lib/screens/home/widgets/create_post_button.dart` → Nút mở màn hình này
- `lib/screens/home/widgets/post_card.dart` → Hiển thị bài viết đã tạo
- `lib/screens/home/pages/home_page.dart` → News feed chính

## ✅ TODO List

- [ ] Implement image_picker để chọn ảnh từ thư viện
- [ ] Upload ảnh lên Firebase Storage
- [ ] Thêm tính năng tag người dùng
- [ ] Thêm tính năng chọn privacy (public/private)
- [ ] Thêm emoji picker
- [ ] Validation nội dung (max length, spam filter)
- [ ] Draft auto-save
- [ ] Chỉnh sửa bài viết đã đăng
- [ ] Xóa bài viết

## 🎨 Design Pattern

**Modular Architecture:**
- Tách riêng screen vào folder `post/`
- Dễ mở rộng thêm tính năng (edit, delete, draft)
- Tách biệt logic với UI

**State Management:**
- Sử dụng StatefulWidget cho form
- Local state với `setState()`
- Loading state cho async operations

## 🔒 Security Rules (Firestore)

```javascript
// Chỉ user đã login mới được tạo bài
match /posts/{postId} {
  allow read: if true;
  allow create: if request.auth != null 
    && request.resource.data.userId == request.auth.uid;
  allow update, delete: if request.auth != null 
    && resource.data.userId == request.auth.uid;
}
```
