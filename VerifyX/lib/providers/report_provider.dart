import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// REPORT PROVIDER - Quản lý state cho reports
/// ═══════════════════════════════════════════════════════════════════════════
class ReportProvider with ChangeNotifier {
  final ReportService _service = ReportService();
  
  // State
  List<ReportModel> _reports = [];
  List<ReportModel> _userReports = [];
  List<ReportModel> _pendingReports = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statistics;
  
  // Getters
  List<ReportModel> get reports => _reports;
  List<ReportModel> get userReports => _userReports;
  List<ReportModel> get pendingReports => _pendingReports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get statistics => _statistics;
  
  // ==================== CREATE ====================
  
  /// Tạo báo cáo mới
  Future<bool> createReport({
    required String productId,
    required String serialNumber,
    required String userId,
    required String userName,
    required String reportType,
    required String description,
    List<String> images = const [],
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final reportId = await _service.createReport(
        productId: productId,
        serialNumber: serialNumber,
        userId: userId,
        userName: userName,
        reportType: reportType,
        description: description,
        images: images,
      );
      
      if (reportId != null) {
        // Reload user reports
        await loadUserReports(userId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = 'Không thể tạo báo cáo';
      _isLoading = false;
      notifyListeners();
      return false;
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ==================== UPDATE ====================
  
  /// Admin cập nhật trạng thái báo cáo
  Future<bool> updateReportStatus({
    required String reportId,
    required String status,
    required String priority,
    String? adminResponse,
    String? resolvedBy,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.updateReportStatus(
        reportId: reportId,
        status: status,
        priority: priority,
        adminResponse: adminResponse,
        resolvedBy: resolvedBy,
      );
      
      // Reload reports
      await loadAllReports();
      await loadPendingReports();
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Brand phản hồi báo cáo
  Future<bool> addBrandResponse({
    required String reportId,
    required String brandResponse,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _service.addBrandResponse(
        reportId: reportId,
        brandResponse: brandResponse,
      );
      
      // Reload reports
      await loadAllReports();
      
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ==================== LOAD ====================
  
  /// Load tất cả báo cáo (Admin)
  Future<void> loadAllReports({String? status, String? priority}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _reports = await _service.getAllReports(
        status: status,
        priority: priority,
      );
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load báo cáo của user
  Future<void> loadUserReports(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _userReports = await _service.getUserReports(userId);
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load báo cáo pending
  Future<void> loadPendingReports() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _pendingReports = await _service.getPendingReports();
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load thống kê
  Future<void> loadStatistics() async {
    try {
      _statistics = await _service.getReportStatistics();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // ==================== UTILS ====================
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
