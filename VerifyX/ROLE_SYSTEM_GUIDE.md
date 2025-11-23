# HƯỚNG DẪN HỆ THỐNG PHÂN QUYỀN (ROLE SYSTEM)

## 📋 Tổng quan

VerifyX sử dụng 3 loại tài khoản (roles):
- **`consumer`** - Người dùng thường (mặc định)
- **`brand`** - Thương hiệu/Nhà sản xuất
- **`admin`** - Quản trị viên

---

## 🔐 Luồng Xác Thực & Phân Quyền

### 1. Đăng Ký (Sign Up)
```
User đăng ký → Chọn role (consumer/brand) → Tạo tài khoản → Lưu userType vào Firestore
```

**File:** `lib/screens/auth/signup_screen.dart`
- Default: `_userType = 'consumer'`
- Options: `consumer`, `brand`

### 2. Đăng Nhập (Login)
```
User login → Firebase Auth → AuthWrapper kiểm tra userType → Điều hướng
```

**File:** `lib/core/auth/auth_wrapper.dart`
```dart
switch (userType) {
  case 'admin':
    return const AdminScreen();     // → lib/screens/admin/admin_screen.dart
  case 'brand':
    return const BrandHomeScreen(); // → lib/screens/brand/brand_home_screen.dart
  case 'consumer':
    return const HomeScreen();      // → lib/screens/home/home_screen.dart
  default:
    return const HomeScreen();      // Fallback cho unknown userType
}
```

---

## 📊 Cấu Trúc Database (Firestore)

### Collection: `users`
```json
{
  "uid": "user_id",
  "email": "user@example.com",
  "displayName": "Tên người dùng",
  "userType": "consumer",  // ← QUAN TRỌNG: "consumer", "brand", hoặc "admin"
  "createdAt": "2025-10-25T00:00:00Z",
  "lastLogin": "2025-11-10T21:40:00Z",
  "photoURL": null,
  "phoneNumber": null
}
```

---

## 🎯 Màn Hình Theo Role

### Consumer (Người dùng thường)
📱 **Màn hình chính:** `HomeScreen`
- Tab 1: Feed (Xem bài đăng)
- Tab 2: Quét QR (Xác thực sản phẩm)
- Tab 3: Community (Cộng đồng)
- Tab 4: Menu (Cài đặt)

### Brand (Thương hiệu)
📱 **Màn hình chính:** `BrandHomeScreen`
- Tab 1: Community (Đăng bài)
- Tab 2: Products (Quản lý sản phẩm)
- Tab 3: Reports (Báo cáo & thống kê)
- Tab 4: Messages (Tin nhắn)
- Tab 5: Profile (Thông tin Brand)

### Admin (Quản trị viên)
📱 **Màn hình chính:** `AdminScreen`
- Quản lý users
- Xử lý báo cáo
- Thống kê hệ thống
- Cài đặt

---

## 🔧 Các File Quan Trọng

### 1. Authentication & Routing
- `lib/core/auth/auth_wrapper.dart` - Kiểm tra role và điều hướng
- `lib/providers/auth_provider.dart` - Quản lý state authentication
- `lib/services/auth_service.dart` - Logic đăng ký/đăng nhập

### 2. User Management
- `lib/models/user_model.dart` - Model người dùng
- `lib/services/user_service.dart` - CRUD operations cho users

### 3. Screens
- `lib/screens/auth/` - Đăng ký, đăng nhập
- `lib/screens/home/` - Màn hình Consumer
- `lib/screens/brand/` - Màn hình Brand
- `lib/screens/admin/` - Màn hình Admin

---

## 🛠️ Debug & Testing

### Màn hình Debug
**File:** `lib/screens/debug/update_usertype_screen.dart`

Chức năng:
- Xem userType hiện tại
- Thay đổi userType (consumer/brand/admin)
- Test routing

**Cách dùng:**
1. Vào Menu → Debug
2. Chọn userType mới
3. Cập nhật
4. Đăng xuất và đăng nhập lại

### Debug Logs
Auth Wrapper sẽ in ra console:
```
═══════════════════════════════════════════════════════════
🔐 AUTH WRAPPER - ROLE CHECKING
User ID: nXBPqEj28idZ3gEKDfjcdkxXKYl2
Email: nguyenphihung@gmail.com
UserType: consumer
═══════════════════════════════════════════════════════════
✅ Routing to HomeScreen (Consumer)
```

---

## ⚠️ Lưu Ý Quan Trọng

### 1. Kiểm tra userType trước khi routing
```dart
final userType = userData?['userType'] ?? 'consumer';
```
- **Luôn có fallback** về 'consumer' nếu không có data

### 2. Roles hợp lệ
```dart
['consumer', 'brand', 'admin']
```
- **KHÔNG dùng:** 'user', 'manufacturer'
- **CHỈ dùng:** 'consumer', 'brand', 'admin'

### 3. Cập nhật userType
```dart
// Chỉ Admin mới được cập nhật userType của users khác
await UserService().updateUserType(
  uid: userId,
  userType: 'brand', // Phải là một trong 3: consumer, brand, admin
);
```

---

## 🧪 Test Cases

### Test 1: Consumer Account
1. Đăng ký với role "Consumer"
2. Đăng nhập
3. ✅ Phải vào `HomeScreen` với 4 tabs

### Test 2: Brand Account
1. Đăng ký với role "Brand"
2. Đăng nhập
3. ✅ Phải vào `BrandHomeScreen` với 5 tabs

### Test 3: Admin Account
1. Dùng Debug screen để đổi role thành "Admin"
2. Đăng xuất và đăng nhập lại
3. ✅ Phải vào `AdminScreen`

---

## 🔍 Kiểm tra Database

### Firebase Console
1. Vào Firebase Console
2. Chọn Firestore Database
3. Mở collection `users`
4. Kiểm tra field `userType` của từng user

**Ví dụ:**
```
users/
  ├─ nXBPqEj28idZ3gEKDfjcdkxXKYl2/
  │   ├─ email: "nguyenphihung@gmail.com"
  │   └─ userType: "consumer"  ← Phải đúng
  │
  ├─ eFH7lNrCpdbt3po2yism21WmG7K2/
  │   ├─ email: "vandung@gmail.com"
  │   └─ userType: "brand"     ← Phải đúng
  │
  └─ MaNsq9Ty3OZObjf1QdUzgyhiMo83/
      ├─ email: "pahmvandung1@gmail.com"
      └─ userType: "admin"     ← Phải đúng
```

---

## 📞 Troubleshooting

### Lỗi: User vào sai màn hình
**Nguyên nhân:** userType trong Firestore không đúng

**Giải pháp:**
1. Kiểm tra Firebase Console → collection `users` → userType
2. Dùng Debug screen để cập nhật
3. Hoặc update trực tiếp trong Firebase Console

### Lỗi: Không vào được màn hình nào
**Nguyên nhân:** userType = null hoặc giá trị không hợp lệ

**Giải pháp:**
1. Check console logs
2. Xem error message
3. Cập nhật userType về 'consumer', 'brand', hoặc 'admin'

---

## 📝 Checklist Hoàn Thành

✅ Routing đúng cho 3 roles: admin, brand, consumer  
✅ Default userType = 'consumer'  
✅ Switch case xử lý đầy đủ 3 cases + default  
✅ Debug logs hiển thị rõ ràng  
✅ Validation userType trong user_service  
✅ Comments chính xác trong user_model  
✅ Debug screen để test  

---

**Ngày cập nhật:** November 10, 2025  
**Version:** 3.0
