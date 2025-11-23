/// ═══════════════════════════════════════════════════════════════════════════
/// BLOCKCHAIN VERIFICATION EXPORTS
/// Tổng hợp exports cho chức năng xác thực blockchain
/// ═══════════════════════════════════════════════════════════════════════════

// Models
export 'models/product_model.dart';
export 'models/verification_record_model.dart';
export 'models/report_model.dart';

// Services
export 'services/product_service.dart';
export 'services/verification_service.dart';
export 'services/report_service.dart';

// Providers
export 'providers/product_provider.dart';
export 'providers/verification_provider.dart';
export 'providers/report_provider.dart';

// Consumer Screens
export 'screens/product/verification/product_verification_screen.dart';
export 'screens/product/verification/product_detail_screen.dart';
export 'screens/product/verification/qr_scanner_screen.dart';
export 'screens/product/consumer/verification_history_screen.dart';

// Brand Screens
export 'screens/product/brand/add_product_screen.dart';
export 'screens/product/brand/brand_products_screen.dart';

// Report Screens
export 'screens/product/report/report_product_screen.dart';

// Admin Screens
export 'screens/admin/reports/admin_reports_screen.dart';
export 'screens/admin/reports/report_detail_screen.dart';
