import 'package:cloud_firestore/cloud_firestore.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VERIFICATION RECORD MODEL - Lịch sử kiểm tra sản phẩm
/// ═══════════════════════════════════════════════════════════════════════════
class VerificationRecordModel {
  final String id;
  final String productId;           // ID sản phẩm
  final String serialNumber;        // Mã seri
  final String userId;              // User kiểm tra
  final String userName;            // Tên user
  final DateTime verificationDate;  // Thời gian kiểm tra
  final String verificationMethod;  // 'qr' hoặc 'serial'
  final bool isAuthentic;           // Kết quả xác thực
  final String? location;           // Vị trí kiểm tra
  final String? deviceInfo;         // Thông tin thiết bị
  
  // Blockchain verification
  final String blockchainHash;      // Hash từ blockchain
  final bool blockchainVerified;    // Đã xác thực blockchain
  
  final DateTime createdAt;

  VerificationRecordModel({
    required this.id,
    required this.productId,
    required this.serialNumber,
    required this.userId,
    required this.userName,
    required this.verificationDate,
    required this.verificationMethod,
    required this.isAuthentic,
    this.location,
    this.deviceInfo,
    required this.blockchainHash,
    this.blockchainVerified = false,
    required this.createdAt,
  });

  factory VerificationRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VerificationRecordModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      serialNumber: data['serialNumber'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      verificationDate: (data['verificationDate'] as Timestamp).toDate(),
      verificationMethod: data['verificationMethod'] ?? 'serial',
      isAuthentic: data['isAuthentic'] ?? false,
      location: data['location'],
      deviceInfo: data['deviceInfo'],
      blockchainHash: data['blockchainHash'] ?? '',
      blockchainVerified: data['blockchainVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'serialNumber': serialNumber,
      'userId': userId,
      'userName': userName,
      'verificationDate': Timestamp.fromDate(verificationDate),
      'verificationMethod': verificationMethod,
      'isAuthentic': isAuthentic,
      'location': location,
      'deviceInfo': deviceInfo,
      'blockchainHash': blockchainHash,
      'blockchainVerified': blockchainVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
