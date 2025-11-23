import 'package:flutter/foundation.dart';
import '../models/verification_record_model.dart';
import '../models/brand/verification_log_model.dart'; // Nhớ import model này
import '../services/verification_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VERIFICATION PROVIDER - Quản lý state cho verifications (FULL UPDATED)
/// ═══════════════════════════════════════════════════════════════════════════
class VerificationProvider with ChangeNotifier {
  final VerificationService _service = VerificationService();
  
  // State cũ
  List<VerificationRecordModel> _verificationHistory = [];
  List<dynamic> _blockchainHistory = [];
  
  // [MỚI] State cho Brand
  List<VerificationLogModel> _brandLogs = [];
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _lastVerificationResult;
  
  // Getters
  List<VerificationRecordModel> get verificationHistory => _verificationHistory;
  List<dynamic> get blockchainHistory => _blockchainHistory;
  List<VerificationLogModel> get brandLogs => _brandLogs; // Getter mới
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get statistics => _statistics;
  Map<String, dynamic>? get lastVerificationResult => _lastVerificationResult;
  
  // ==================== VERIFY (CŨ - GIỮ NGUYÊN) ====================
  
  Future<Map<String, dynamic>> verifyProduct({
    required String serialNumber,
    required String userId,
    required String userName,
    required String verificationMethod,
    String? location,
    String? deviceInfo,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await _service.verifyProduct(
        serialNumber: serialNumber,
        userId: userId,
        userName: userName,
        verificationMethod: verificationMethod,
        location: location,
        deviceInfo: deviceInfo,
      );
      
      _lastVerificationResult = result;
      
      if (result['success'] == true) {
        await loadUserHistory(userId);
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> processScannedCode(String id, String location) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final batchId = _parseBatchId(id); 

      await _service.scanBatchOnBlockchain(
        batchId.toString(),
        location,
        'Da quet boi Nguoi tieu dung',
      );

      _blockchainHistory = await _service.getBatchHistoryFromBlockchain(batchId.toString());

      _isLoading = false;
      notifyListeners();
    } on FormatException catch (formatError) {
      final errorMessage = formatError.message.isNotEmpty
          ? formatError.message
          : 'Ma lo khong hop le.';
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      throw Exception(errorMessage);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // ==================== LOAD USER (CŨ - GIỮ NGUYÊN) ====================
  
  Future<void> loadUserHistory(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _verificationHistory = await _service.getUserVerificationHistory(userId);
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadUserStatistics(String userId) async {
    try {
      _statistics = await _service.getUserStatistics(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ==================== [MỚI] LOAD BRAND LOGS ====================

  Future<void> loadBrandLogs(String brandId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final rawLogs = await _service.getBrandVerifications(brandId);
      
      // Map data sang Model
      _brandLogs = rawLogs.map((map) => VerificationLogModel.fromMap(map)).toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ==================== UTILS ====================
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearLastResult() {
    _lastVerificationResult = null;
    notifyListeners();
  }

  void clearBlockchainHistory() {
    _blockchainHistory = [];
    notifyListeners();
  }

  BigInt _parseBatchId(String rawId) {
    final numeric = rawId.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      throw const FormatException('Khong tim thay chu so hop le.');
    }
    return BigInt.parse(numeric);
  }
}