module.exports = {
  /**
   * Chỉ định đường dẫn TƯƠNG ĐỐI so với file config này.
   * Vì file config nằm trong 'VerifyX', nên đường dẫn chỉ là './contracts'
   */
  contracts_directory: './contracts', // <-- ĐÃ SỬA LẠI
  migrations_directory: './migrations', // <-- ĐÃ SỬA LẠI

  /**
   * Chỉ định nơi lưu file .json (artifacts)
   * Mặc định là './build/contracts'
   */
  contracts_build_directory: './build/contracts', // <-- THÊM VÀO CHO CHẮC CHẮN

  networks: {
    // Cấu hình cho Ganache UI của bạn
    ganache: {
      host: "127.0.0.1",    // Địa chỉ IP từ ảnh Ganache
      port: 7545,           // Cổng từ ảnh Ganache
      network_id: "5777",   // NETWORK ID từ ảnh Ganache
    }
  },

  // Giữ nguyên phần cấu hình trình biên dịch của bạn
  compilers: {
    solc: {
      version: "0.8.19", // Phiên bản Solidity bạn đang dùng
    }
  }
};