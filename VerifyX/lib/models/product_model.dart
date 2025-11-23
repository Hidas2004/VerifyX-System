import 'package:cloud_firestore/cloud_firestore.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT MODEL - Quản lý thông tin sản phẩm (Final Version)
/// ═══════════════════════════════════════════════════════════════════════════
class ProductModel {
  final String id;
  final String serialNumber;
  final String name;
  final String description;
  final String ingredients;
  final String category;
  final String brandId;
  final String brandName;
  final String? imageUrl;
  final String qrCode;
  
  // Liên kết Blockchain & Batch
  final String batchId;
  final int blockchainBatchId; // Quan trọng: ID để check Blockchain
  final String blockchainHash; // TxHash của lần tạo sản phẩm

  // Ngày tháng
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final DateTime warehouseDate;
  final DateTime? distributionDate;
  
  // Chuỗi cung ứng
  final String manufacturer;
  final String? distributor;
  final String? retailer;
  final String? retailLocation;
  
  // Trạng thái & Thống kê
  final int verificationCount;
  final DateTime? lastVerification;
  final List<String> verificationHistory;
  final bool isActive;
  final bool isReported;
  final int reportCount;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.description,
    this.ingredients = '',
    required this.category,
    required this.brandId,
    required this.brandName,
    this.imageUrl,
    required this.qrCode,
    this.batchId = '',
    this.blockchainBatchId = 0,
    this.blockchainHash = '',
    required this.manufacturingDate,
    required this.expiryDate,
    required this.warehouseDate,
    this.distributionDate,
    required this.manufacturer,
    this.distributor,
    this.retailer,
    this.retailLocation,
    this.verificationCount = 0,
    this.lastVerification,
    this.verificationHistory = const [],
    this.isActive = true,
    this.isReported = false,
    this.reportCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory tạo model từ Firestore Document (An toàn tuyệt đối)
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper lấy chuỗi an toàn
    String getString(String key) => data[key]?.toString() ?? '';
    
    // Helper lấy số an toàn (int)
    int getInt(String key) {
      final val = data[key];
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    // Helper lấy Blockchain Hash từ object lồng nhau
    String getTxHash() {
      if (data['blockchainData'] != null && data['blockchainData'] is Map) {
        return data['blockchainData']['txHash']?.toString() ?? '';
      }
      return data['blockchainHash']?.toString() ?? '';
    }

    return ProductModel(
      id: doc.id,
      serialNumber: getString('serialNumber'),
      name: getString('name'),
      description: getString('description'),
      ingredients: getString('ingredients'),
      category: getString('category'),
      brandId: getString('brandId'),
      brandName: getString('brandName'),
      imageUrl: data['imageUrl'],
      qrCode: getString('qrCode'),
      
      batchId: getString('batchId'),
      // [QUAN TRỌNG] Lấy ID Blockchain an toàn
      blockchainBatchId: getInt('blockchainBatchId'),

      blockchainHash: getTxHash(),
      
      manufacturingDate: _parseDate(data['manufacturingDate']),
      expiryDate: _parseDate(data['expiryDate']),
      warehouseDate: _parseDate(data['warehouseDate']),
      distributionDate: data['distributionDate'] != null 
          ? _parseDate(data['distributionDate']) : null,
      
      manufacturer: getString('manufacturer'),
      distributor: getString('distributor'),
      retailer: getString('retailer'),
      retailLocation: getString('retailLocation'),
      
      verificationCount: getInt('verificationCount'),
      lastVerification: data['lastVerification'] != null 
          ? _parseDate(data['lastVerification']) : null,
      
      verificationHistory: List<String>.from(data['verificationHistory'] ?? []),
      
      isActive: data['isActive'] ?? true,
      isReported: data['isReported'] ?? false,
      reportCount: getInt('reportCount'),
      
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  /// Helper xử lý ngày tháng (Timestamp / String / Null)
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'category': category,
      'brandId': brandId,
      'brandName': brandName,
      'imageUrl': imageUrl,
      'qrCode': qrCode,
      'batchId': batchId,
      'blockchainBatchId': blockchainBatchId,
      'blockchainHash': blockchainHash,
      'manufacturingDate': Timestamp.fromDate(manufacturingDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'warehouseDate': Timestamp.fromDate(warehouseDate),
      'distributionDate': distributionDate != null ? Timestamp.fromDate(distributionDate!) : null,
      'manufacturer': manufacturer,
      'distributor': distributor,
      'retailer': retailer,
      'retailLocation': retailLocation,
      'verificationCount': verificationCount,
      'lastVerification': lastVerification != null ? Timestamp.fromDate(lastVerification!) : null,
      'verificationHistory': verificationHistory,
      'isActive': isActive,
      'isReported': isReported,
      'reportCount': reportCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}