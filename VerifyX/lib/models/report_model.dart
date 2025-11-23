import 'package:cloud_firestore/cloud_firestore.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// REPORT MODEL - Báo cáo sản phẩm nghi ngờ giả
/// ═══════════════════════════════════════════════════════════════════════════
class ReportModel {
  final String id;
  final String productId;           // ID sản phẩm
  final String serialNumber;        // Mã seri
  final String userId;              // User báo cáo
  final String userName;            // Tên user
  final String reportType;          // 'counterfeit', 'damaged', 'other'
  final String description;         // Mô tả chi tiết
  final List<String> images;        // Hình ảnh bằng chứng
  
  // Status
  final String status;              // 'pending', 'reviewing', 'resolved', 'rejected'
  final String priority;            // 'low', 'medium', 'high', 'critical'
  
  // Response
  final String? adminResponse;      // Phản hồi từ admin
  final String? brandResponse;      // Phản hồi từ brand
  final String? resolvedBy;         // ID người xử lý
  final DateTime? resolvedAt;       // Thời gian xử lý
  
  // Blockchain
  final String blockchainHash;      // Hash báo cáo trên blockchain
  final bool isVerifiedOnChain;     // Đã ghi blockchain
  
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportModel({
    required this.id,
    required this.productId,
    required this.serialNumber,
    required this.userId,
    required this.userName,
    required this.reportType,
    required this.description,
    this.images = const [],
    this.status = 'pending',
    this.priority = 'medium',
    this.adminResponse,
    this.brandResponse,
    this.resolvedBy,
    this.resolvedAt,
    required this.blockchainHash,
    this.isVerifiedOnChain = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      reportType: data['reportType'] ?? 'other',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      status: data['status'] ?? 'pending',
      priority: data['priority'] ?? 'medium',
      adminResponse: data['adminResponse'],
      brandResponse: data['brandResponse'],
      resolvedBy: data['resolvedBy'],
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      blockchainHash: data['blockchainHash'] ?? '',
      isVerifiedOnChain: data['isVerifiedOnChain'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'serialNumber': serialNumber,
      'userId': userId,
      'userName': userName,
      'reportType': reportType,
      'description': description,
      'images': images,
      'status': status,
      'priority': priority,
      'adminResponse': adminResponse,
      'brandResponse': brandResponse,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'blockchainHash': blockchainHash,
      'isVerifiedOnChain': isVerifiedOnChain,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ReportModel copyWith({
    String? status,
    String? priority,
    String? adminResponse,
    String? brandResponse,
    String? resolvedBy,
    DateTime? resolvedAt,
    bool? isVerifiedOnChain,
  }) {
    return ReportModel(
      id: id,
      productId: productId,
      serialNumber: serialNumber,
      userId: userId,
      userName: userName,
      reportType: reportType,
      description: description,
      images: images,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      adminResponse: adminResponse ?? this.adminResponse,
      brandResponse: brandResponse ?? this.brandResponse,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      blockchainHash: blockchainHash,
      isVerifiedOnChain: isVerifiedOnChain ?? this.isVerifiedOnChain,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
