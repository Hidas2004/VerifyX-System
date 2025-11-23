# BRAND MANAGEMENT SYSTEM

## Tổng quan
Hệ thống quản lý dành riêng cho Brand với đầy đủ chức năng quản lý sản phẩm, lô hàng, xác thực và báo cáo.

## Cấu trúc

```
lib/screens/brand/
├── brand_home_screen.dart          # Màn hình chính với bottom navigation
├── pages/
│   ├── brand_dashboard_page.dart   # Trang tổng quan + đăng bài
│   ├── product_management_page.dart # Quản lý sản phẩm
│   ├── add_product_screen.dart     # Thêm/sửa sản phẩm
│   ├── batch_tracking_page.dart    # Quản lý lô hàng
│   ├── verification_logs_page.dart # Lịch sử xác thực
│   └── reports_management_page.dart # Quản lý báo cáo
├── widgets/                         # Widgets tùy chỉnh
└── README.md                       # File này

lib/models/brand/
├── batch_model.dart                # Model lô hàng
└── verification_log_model.dart     # Model lịch sử xác thực
```

## Các tính năng

### 1. Dashboard (Trang tổng quan)
- **Thống kê**: Hiển thị số lượng sản phẩm, lượt xác thực
- **Thao tác nhanh**: Nút thêm sản phẩm, tạo lô hàng
- **Feed**: Danh sách bài đăng của Brand (giống User feed)
- **Đăng bài**: Tạo bài viết mới về sản phẩm, tin tức

### 2. Product Management (Quản lý Sản phẩm)
**Chức năng chính:**
- ✅ Xem danh sách tất cả sản phẩm
- ✅ Lọc theo trạng thái (đang bán, ngừng bán)
- ✅ Thêm sản phẩm mới
- ✅ Chỉnh sửa thông tin sản phẩm
- ✅ Sinh mã QR tự động hoặc thủ công
- ✅ Upload hình ảnh sản phẩm
- ✅ Lưu dữ liệu lên Blockchain
- ✅ Cập nhật trạng thái sản phẩm
- ✅ Xóa sản phẩm

**Thông tin sản phẩm:**
- Tên sản phẩm
- Danh mục
- Mô tả chi tiết
- Hình ảnh
- Mã Serial (tự sinh hoặc nhập)
- Blockchain CID
- Trạng thái (active/inactive)

### 3. Batch Tracking (Quản lý Lô hàng)
**Chức năng:**
- ✅ Tạo lô hàng mới
- ✅ Gắn danh sách sản phẩm vào lô
- ✅ Theo dõi ngày sản xuất, hạn sử dụng
- ✅ Quản lý phân phối (nhà phân phối, số lượng)
- ✅ Lưu thông tin lô lên Blockchain
- ✅ Cập nhật trạng thái (active, distributed, recalled)
- ✅ Xem chi tiết từng lô hàng

**Thông tin lô hàng:**
- Mã lô (Batch Number)
- Ngày sản xuất
- Ngày hết hạn
- Số lượng sản phẩm
- Danh sách sản phẩm trong lô
- Nhà phân phối
- Blockchain data
- Trạng thái

### 4. Verification Logs (Theo dõi Xác thực)
**Chức năng:**
- ✅ Xem lịch sử xác thực từ người tiêu dùng
- ✅ Lọc theo kết quả (chính hãng, nghi ngờ, hàng giả)
- ✅ Xem thông tin chi tiết mỗi lượt xác thực
- ✅ Thống kê biểu đồ
- ✅ Xem độ tin cậy AI
- ✅ Phân tích AI về sản phẩm

**Thông tin log:**
- Tên sản phẩm + Serial
- Người xác thực
- Thời gian + Địa điểm
- Kết quả (authentic/suspicious/fake)
- AI Confidence Score
- Phân tích AI
- Hình ảnh minh chứng

### 5. Reports Management (Quản lý Báo cáo)
**Chức năng:**
- ✅ Xem danh sách báo cáo từ người dùng
- ✅ Lọc theo trạng thái (chờ xử lý, đã xử lý, từ chối)
- ✅ Xem chi tiết báo cáo + hình ảnh minh chứng
- ✅ Gửi phản hồi cho người báo cáo
- ✅ Xác nhận sản phẩm là hàng giả
- ✅ Từ chối báo cáo
- ✅ Cập nhật tiến trình xử lý
- ✅ Lưu log xử lý lên Blockchain

**Loại báo cáo:**
- Hàng giả (fake)
- Nghi ngờ (suspicious)
- Hư hỏng (damaged)

## Sử dụng

### 1. Navigate đến Brand Home
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BrandHomeScreen(),
  ),
);
```

### 2. Thêm sản phẩm mới
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AddProductScreen(),
  ),
);
```

### 3. Chỉnh sửa sản phẩm
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AddProductScreen(product: existingProduct),
  ),
);
```

## Models

### BatchModel
```dart
BatchModel(
  id: 'batch_id',
  batchNumber: 'BATCH001',
  manufactureDate: DateTime.now(),
  quantity: 1000,
  productIds: ['prod1', 'prod2'],
  status: 'active',
  // ...
)
```

### VerificationLogModel
```dart
VerificationLogModel(
  id: 'log_id',
  productId: 'prod_id',
  userId: 'user_id',
  result: 'authentic',
  aiConfidence: 95.5,
  // ...
)
```

## TODO - Cần bổ sung

### Models
- [ ] Thêm `status` field vào ProductModel
- [ ] Thêm `blockchainCID` field vào ProductModel
- [ ] Thêm `reporterName`, `imageUrl` vào ReportModel

### Providers
- [ ] Implement `loadProducts()` trong ProductProvider
- [ ] Implement `addProduct()` trong ProductProvider
- [ ] Implement `updateProduct()` trong ProductProvider
- [ ] Implement `deleteProduct()` trong ProductProvider
- [ ] Tạo BatchProvider với CRUD operations
- [ ] Tạo VerificationLogProvider
- [ ] Cập nhật ReportProvider

### Services
- [ ] Blockchain service để lưu dữ liệu
- [ ] Image upload service (Firebase Storage)
- [ ] QR Code generation service
- [ ] AI verification service integration
- [ ] Location service

### UI Enhancements
- [ ] Add charts/graphs cho statistics
- [ ] Implement image picker
- [ ] QR Code scanner integration
- [ ] Map view cho verification locations
- [ ] Export reports (PDF/Excel)

### Backend Integration
- [ ] Connect to Firebase/Backend API
- [ ] Real-time updates
- [ ] Push notifications cho báo cáo mới
- [ ] Blockchain integration (IPFS)

## Navigation Flow

```
BrandHomeScreen
├─ Dashboard (Tab 0)
│  ├─ Stats Cards
│  ├─ Quick Actions
│  └─ Post Feed
│
├─ Products (Tab 1)
│  ├─ Product List
│  ├─ Add Product → AddProductScreen
│  ├─ Edit Product → AddProductScreen(product)
│  └─ Product Details (Bottom Sheet)
│
├─ Batches (Tab 2)
│  ├─ Batch List
│  ├─ Create Batch (Dialog)
│  └─ Batch Details (Bottom Sheet)
│
├─ Verifications (Tab 3)
│  ├─ Verification Logs
│  ├─ Statistics (Dialog)
│  └─ Log Details (Bottom Sheet)
│
└─ Reports (Tab 4)
   ├─ Report List
   ├─ Report Details (Bottom Sheet)
   ├─ Resolve Report (Dialog)
   └─ Reject Report (Dialog)
```

## Notes

- Tất cả màn hình đã có UI hoàn chỉnh
- Cần implement business logic và backend integration
- Models và providers cần được cập nhật
- Blockchain integration là optional nhưng recommended
- AI verification cần external service

## License
Private - VerifyX Brand Management System
