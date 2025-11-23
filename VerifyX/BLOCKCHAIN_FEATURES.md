# 🔐 Blockchain Product Verification System

Hệ thống xác thực sản phẩm dựa trên công nghệ Blockchain cho VerifyX.

## 📋 Tính năng đã triển khai

### 🎯 Consumer (Người tiêu dùng)
- ✅ Xác thực sản phẩm bằng mã Serial
- ✅ Xác thực sản phẩm bằng quét QR Code
- ✅ Xem chi tiết sản phẩm với thông tin Blockchain
- ✅ Xem truy xuất nguồn gốc (Supply Chain)
- ✅ Báo cáo sản phẩm giả/hư hỏng
- ✅ Xem lịch sử xác thực cá nhân

### 🏢 Brand (Thương hiệu)
- ✅ Đăng ký sản phẩm mới với Blockchain
- ✅ Quản lý danh sách sản phẩm
- ✅ Xem mã QR của sản phẩm
- ✅ Theo dõi thống kê (số lượng xác thực, báo cáo)
- ✅ Nhập thông tin chuỗi cung ứng đầy đủ

### 👨‍💼 Admin
- ✅ Quản lý tất cả báo cáo
- ✅ Phân loại báo cáo (Pending, Reviewing, Resolved, Rejected)
- ✅ Đặt độ ưu tiên (Low, Medium, High, Critical)
- ✅ Phản hồi và xử lý báo cáo
- ✅ Theo dõi thống kê báo cáo
- ✅ Xác thực báo cáo trên Blockchain

## 🔧 Công nghệ sử dụng

### Blockchain
- **SHA-256 Hashing**: Mã hóa thông tin sản phẩm
- **Firestore Collections**: Lưu trữ blockchain records
  - `blockchain_records`: Ghi nhận sản phẩm
  - `blockchain_reports`: Ghi nhận báo cáo

### QR Code
- **qr_flutter**: Tạo mã QR
- **qr_code_scanner**: Quét mã QR
- **Format**: `VERIFYX://SERIAL/{serialNumber}`

### Serial Number
- **Format**: `VFX{timestamp}{random}`
- **Unique**: Không trùng lặp

## 📁 Cấu trúc thư mục

```
lib/
├── models/
│   ├── product_model.dart              # Model sản phẩm
│   ├── verification_record_model.dart  # Model lịch sử xác thực
│   └── report_model.dart               # Model báo cáo
│
├── services/
│   ├── product_service.dart            # Service quản lý sản phẩm
│   ├── verification_service.dart       # Service xác thực
│   └── report_service.dart             # Service báo cáo
│
├── providers/
│   ├── product_provider.dart           # State management sản phẩm
│   ├── verification_provider.dart      # State management xác thực
│   └── report_provider.dart            # State management báo cáo
│
└── screens/
    ├── product/
    │   ├── verification/
    │   │   ├── product_verification_screen.dart   # Xác thực sản phẩm
    │   │   ├── product_detail_screen.dart         # Chi tiết sản phẩm
    │   │   └── qr_scanner_screen.dart             # Quét QR
    │   ├── consumer/
    │   │   └── verification_history_screen.dart   # Lịch sử xác thực
    │   ├── brand/
    │   │   ├── add_product_screen.dart            # Thêm sản phẩm
    │   │   └── brand_products_screen.dart         # Danh sách sản phẩm
    │   └── report/
    │       └── report_product_screen.dart         # Báo cáo sản phẩm
    │
    └── admin/
        └── reports/
            ├── admin_reports_screen.dart          # Quản lý báo cáo
            └── report_detail_screen.dart          # Chi tiết báo cáo
```

## 🔄 Luồng hoạt động

### 1. Brand đăng ký sản phẩm
```
Brand → AddProductScreen
  → ProductService.createProduct()
    → Generate Serial (VFX...)
    → Generate QR Code (VERIFYX://SERIAL/...)
    → Generate Blockchain Hash (SHA-256)
    → Write to Firestore & Blockchain
```

### 2. Consumer xác thực sản phẩm
```
Consumer → ProductVerificationScreen
  → Input Serial OR Scan QR
    → VerificationService.verifyProduct()
      → ProductService.verifyBySerial/QRCode()
        → Check Blockchain
        → Save VerificationRecord
        → Update Product stats
          → Show ProductDetailScreen
```

### 3. Consumer báo cáo giả mạo
```
Consumer → ProductDetailScreen → Report
  → ReportProductScreen
    → ReportService.createReport()
      → Generate Report Hash
      → Write to Blockchain
      → Update Product status
```

### 4. Admin xử lý báo cáo
```
Admin → AdminReportsScreen
  → View Reports (Pending/Reviewing/Resolved)
    → ReportDetailScreen
      → Update Status & Priority
      → Add Admin Response
      → Mark as Verified on Chain
```

## 🗄️ Firebase Collections

### products
```json
{
  "id": "auto-generated",
  "serialNumber": "VFX1699000000001",
  "name": "iPhone 15 Pro Max",
  "qrCode": "VERIFYX://SERIAL/VFX1699000000001",
  "blockchainHash": "sha256_hash_here",
  "manufacturingDate": "2024-01-01",
  "warehouseDate": "2024-01-05",
  "manufacturer": "Foxconn",
  "verificationCount": 25,
  "isReported": false
}
```

### verifications
```json
{
  "productId": "product_id",
  "serialNumber": "VFX1699000000001",
  "userId": "user_id",
  "verificationMethod": "qr",
  "blockchainVerified": true,
  "verificationDate": "2024-11-10"
}
```

### reports
```json
{
  "productId": "product_id",
  "serialNumber": "VFX1699000000001",
  "reportType": "counterfeit",
  "status": "pending",
  "priority": "high",
  "blockchainHash": "report_hash",
  "isVerifiedOnChain": false
}
```

### blockchain_records
```json
{
  "hash": "sha256_hash",
  "data": { /* product data */ },
  "timestamp": "2024-11-10T10:00:00Z"
}
```

### blockchain_reports
```json
{
  "hash": "sha256_hash",
  "data": { /* report data */ },
  "timestamp": "2024-11-10T11:00:00Z"
}
```

## 🚀 Cách sử dụng

### 1. Import vào main.dart
```dart
import 'blockchain_exports.dart';

// Đăng ký Providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => VerificationProvider()),
    ChangeNotifierProvider(create: (_) => ReportProvider()),
  ],
  child: MyApp(),
)
```

### 2. Consumer Flow
```dart
// Xác thực sản phẩm
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductVerificationScreen(),
  ),
);

// Xem lịch sử
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VerificationHistoryScreen(),
  ),
);
```

### 3. Brand Flow
```dart
// Quản lý sản phẩm
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BrandProductsScreen(),
  ),
);
```

### 4. Admin Flow
```dart
// Quản lý báo cáo
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdminReportsScreen(),
  ),
);
```

## 📊 Statistics & Analytics

### Brand Statistics
- Tổng số sản phẩm
- Tổng lượt xác thực
- Số báo cáo nhận được

### Consumer Statistics
- Tổng lần xác thực
- Số sản phẩm chính hãng
- Lần xác thực gần nhất

### Admin Statistics
- Tổng báo cáo
- Báo cáo chờ xử lý
- Báo cáo ưu tiên cao

## 🔒 Security Features

1. **Blockchain Hashing**: SHA-256 encryption
2. **Unique Serial Numbers**: VFX format with timestamp
3. **QR Code Security**: App-specific format
4. **Immutable Records**: Blockchain can't be modified
5. **Verification History**: Full audit trail

## 🎨 UI Components

- Custom buttons with loading states
- Animated statistics cards
- Status badges with colors
- QR code display dialogs
- Priority indicators
- Blockchain verification badges

## 📝 Notes

- Blockchain simulation sử dụng Firestore (có thể integrate với blockchain thật sau)
- QR Scanner yêu cầu camera permissions
- Admin phải có userType = 'admin'
- Brand phải có userType = 'brand'
- Consumer mặc định userType = 'consumer'

## 🔜 Future Enhancements

- [ ] Real blockchain integration (Ethereum, Polygon)
- [ ] Image upload cho báo cáo
- [ ] Push notifications cho báo cáo mới
- [ ] Export reports to PDF
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
- [ ] Blockchain explorer UI

---
**Version**: 1.0.0  
**Last Updated**: 10/11/2025  
**Author**: GitHub Copilot
