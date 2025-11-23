/// ═══════════════════════════════════════════════════════════════════════════
/// VERIFICATION LOG MODEL - Model cho lịch sử xác thực
/// ═══════════════════════════════════════════════════════════════════════════

class VerificationLogModel {
  final String id;
  final String productId;
  final String productName;
  final String serialNumber;
  final String userId;
  final String userName;
  final DateTime verifiedAt;
  final String location;
  final double? latitude;
  final double? longitude;
  final String result; // authentic, suspicious, fake
  final double? aiConfidence;
  final String? aiAnalysis;
  final String? imageUrl;
  final String? deviceInfo;

  VerificationLogModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.serialNumber,
    required this.userId,
    required this.userName,
    required this.verifiedAt,
    required this.location,
    this.latitude,
    this.longitude,
    required this.result,
    this.aiConfidence,
    this.aiAnalysis,
    this.imageUrl,
    this.deviceInfo,
  });

  factory VerificationLogModel.fromMap(Map<String, dynamic> map) {
    return VerificationLogModel(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      verifiedAt: DateTime.parse(map['verifiedAt']),
      location: map['location'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      result: map['result'] ?? 'authentic',
      aiConfidence: map['aiConfidence']?.toDouble(),
      aiAnalysis: map['aiAnalysis'],
      imageUrl: map['imageUrl'],
      deviceInfo: map['deviceInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'serialNumber': serialNumber,
      'userId': userId,
      'userName': userName,
      'verifiedAt': verifiedAt.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'result': result,
      'aiConfidence': aiConfidence,
      'aiAnalysis': aiAnalysis,
      'imageUrl': imageUrl,
      'deviceInfo': deviceInfo,
    };
  }
}
