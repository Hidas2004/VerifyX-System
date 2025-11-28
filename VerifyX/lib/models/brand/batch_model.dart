import 'package:cloud_firestore/cloud_firestore.dart';

class BatchModel {
  final String id;
  final String brandId;
  final String brandName;
  final String batchNumber;
  final String productName;
  final DateTime manufactureDate;
  final DateTime? expiryDate;
  final int quantity;
  final List<String> productIds;
  final String status; 
  final Map<String, dynamic>? blockchainData; // Dữ liệu từ Blockchain
  final DateTime createdAt;

  BatchModel({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.batchNumber,
    this.productName = '',
    required this.manufactureDate,
    this.expiryDate,
    required this.quantity,
    required this.productIds,
    required this.status,
    this.blockchainData,
    required this.createdAt,
  });

  // --- [QUAN TRỌNG] Getter để lấy ID Blockchain an toàn ---
  int get blockchainId {
    if (blockchainData != null && blockchainData!.containsKey('id')) {
      // Chuyển đổi an toàn sang int (kể cả khi Firestore lưu là double hay string)
      return int.tryParse(blockchainData!['id'].toString()) ?? 0;
    }
    return 0;
  }

  factory BatchModel.fromMap(Map<String, dynamic> map) {
    return BatchModel(
      id: map['id'] ?? '',
      brandId: map['brandId'] ?? '',
      brandName: map['brandName'] ?? '',
      batchNumber: map['batchNumber'] ?? '',
      productName: map['productName'] ?? '',
      manufactureDate: _parseDate(map['manufactureDate']),
      expiryDate: map['expiryDate'] != null ? _parseDate(map['expiryDate']) : null,
      quantity: map['quantity'] is int ? map['quantity'] : int.tryParse(map['quantity'].toString()) ?? 0,
      productIds: List<String>.from(map['productIds'] ?? []),
      status: map['status'] ?? 'active',
      blockchainData: map['blockchainData'] != null ? Map<String, dynamic>.from(map['blockchainData']) : null,
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brandId': brandId,
      'brandName': brandName,
      'batchNumber': batchNumber,
      'productName': productName,
      'manufactureDate': manufactureDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'quantity': quantity,
      'productIds': productIds,
      'status': status,
      'blockchainData': blockchainData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper xử lý ngày tháng (chấp nhận cả String và Timestamp)
  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }
  bool get hasBlockchainHash {
    return blockchainData != null && 
          blockchainData!['txHash'] != null && 
          blockchainData!['txHash'].toString().isNotEmpty;
  }
}
