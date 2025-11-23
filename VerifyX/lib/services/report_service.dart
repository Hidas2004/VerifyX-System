import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/report_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// REPORT SERVICE - Quản lý báo cáo giả mạo
/// ═══════════════════════════════════════════════════════════════════════════
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== TẠO BÁO CÁO ====================
  
  /// Tạo báo cáo mới
  Future<String?> createReport({
    required String productId,
    required String serialNumber,
    required String userId,
    required String userName,
    required String reportType,
    required String description,
    List<String> images = const [],
  }) async {
    try {
      // Tạo blockchain hash cho báo cáo
      final blockchainHash = _generateReportHash(
        productId: productId,
        userId: userId,
        timestamp: DateTime.now(),
      );
      
      final now = DateTime.now();
      
      final report = ReportModel(
        id: '',
        productId: productId,
        serialNumber: serialNumber,
        userId: userId,
        userName: userName,
        reportType: reportType,
        description: description,
        images: images,
        blockchainHash: blockchainHash,
        createdAt: now,
        updatedAt: now,
      );
      
      // Lưu báo cáo
      final docRef = await _firestore.collection('reports').add(report.toMap());
      
      // Cập nhật product
      await _updateProductReportStatus(productId);
      
      // Ghi blockchain
      await _writeReportToBlockchain(blockchainHash, report.toMap());
      
      debugPrint('✅ Report created: ${docRef.id}');
      
      return docRef.id;
      
    } catch (e) {
      debugPrint('❌ Error creating report: $e');
      return null;
    }
  }

  // ==================== CẬP NHẬT BÁO CÁO ====================
  
  /// Admin xử lý báo cáo
  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String priority,
    String? adminResponse,
    String? resolvedBy,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': status,
        'priority': priority,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (adminResponse != null) {
        updateData['adminResponse'] = adminResponse;
      }
      
      if (resolvedBy != null) {
        updateData['resolvedBy'] = resolvedBy;
      }
      
      if (status == 'resolved' || status == 'rejected') {
        updateData['resolvedAt'] = FieldValue.serverTimestamp();
        updateData['isVerifiedOnChain'] = true;
      }
      
      await _firestore.collection('reports').doc(reportId).update(updateData);
      
      debugPrint('✅ Report updated: $reportId');
      
    } catch (e) {
      debugPrint('❌ Error updating report: $e');
      rethrow;
    }
  }
  
  /// Brand phản hồi báo cáo
  Future<void> addBrandResponse({
    required String reportId,
    required String brandResponse,
  }) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'brandResponse': brandResponse,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Brand response added');
      
    } catch (e) {
      debugPrint('❌ Error adding brand response: $e');
      rethrow;
    }
  }

  // ==================== QUERY ====================
  
  /// Lấy tất cả báo cáo (Admin)
  Future<List<ReportModel>> getAllReports({
    String? status,
    String? priority,
  }) async {
    try {
      Query query = _firestore.collection('reports');
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority);
      }
      
      final querySnapshot = await query
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting reports: $e');
      return [];
    }
  }
  
  /// Lấy báo cáo của user
  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user reports: $e');
      return [];
    }
  }
  
  /// Lấy báo cáo của sản phẩm
  Future<List<ReportModel>> getProductReports(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reports')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => ReportModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting product reports: $e');
      return [];
    }
  }
  
  /// Lấy báo cáo pending (chưa xử lý)
  Future<List<ReportModel>> getPendingReports() async {
    return await getAllReports(status: 'pending');
  }

  // ==================== STATISTICS ====================
  
  /// Thống kê báo cáo
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final allReports = await getAllReports();
      
      return {
        'total': allReports.length,
        'pending': allReports.where((r) => r.status == 'pending').length,
        'reviewing': allReports.where((r) => r.status == 'reviewing').length,
        'resolved': allReports.where((r) => r.status == 'resolved').length,
        'rejected': allReports.where((r) => r.status == 'rejected').length,
        'highPriority': allReports.where((r) => r.priority == 'high').length,
        'criticalPriority': allReports.where((r) => r.priority == 'critical').length,
      };
    } catch (e) {
      debugPrint('❌ Error getting report stats: $e');
      return {};
    }
  }

  // ==================== HELPERS ====================
  
  /// Cập nhật trạng thái báo cáo của sản phẩm
  Future<void> _updateProductReportStatus(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isReported': true,
        'reportCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error updating product report status: $e');
    }
  }
  
  /// Generate hash cho báo cáo
  String _generateReportHash({
    required String productId,
    required String userId,
    required DateTime timestamp,
  }) {
    final data = 'REPORT:$productId:$userId:${timestamp.toIso8601String()}';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  /// Ghi báo cáo lên blockchain
  Future<void> _writeReportToBlockchain(
    String hash,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('blockchain_reports').add({
        'hash': hash,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      debugPrint('📝 Report written to blockchain: $hash');
    } catch (e) {
      debugPrint('❌ Error writing to blockchain: $e');
    }
  }
}
