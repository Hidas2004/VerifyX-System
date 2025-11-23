// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ProductVerification {
    address private _owner;

    // Cấu trúc dữ liệu
    struct Batch {
        uint id;
        string name;
        bool isInitialized;
    }

    struct Product {
        string serialNumber;
        uint batchId;
        bool isRegistered;
        uint timestamp;
    }

    struct ScanRecord {
        uint timestamp;
        string location;    
        string status;
        address actor;
    }

    // Lưu trữ
    mapping(uint => Batch) public batches;
    mapping(string => Product) public products; // Quản lý sản phẩm theo Serial
    mapping(uint => ScanRecord[]) private batchHistories;

    // Events
    event BatchCreated(uint indexed id, string name, address indexed owner);
    event ProductRegistered(string indexed serialNumber, uint indexed batchId, address indexed owner);
    event BatchScanned(uint indexed id, string location, string status, address indexed actor);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    // 1. Tạo Lô hàng
    function createBatch(uint _id, string memory _name) public onlyOwner {
        require(!batches[_id].isInitialized, "Batch ID da ton tai");
        
        batches[_id] = Batch({
            id: _id,
            name: _name,
            isInitialized: true
        });

        // Tạo lịch sử khởi tạo
        ScanRecord memory initialRecord = ScanRecord({
            timestamp: block.timestamp,
            location: "Nha may san xuat",
            status: "Khoi tao",
            actor: msg.sender 
        });
        batchHistories[_id].push(initialRecord);

        emit BatchCreated(_id, _name, msg.sender);
    }

    // 2. Đăng ký Sản phẩm (Hàm này server.js đang gọi nhưng bị thiếu trước đó)
    function registerProduct(string memory _serialNumber, uint _batchId) public onlyOwner {
        require(batches[_batchId].isInitialized, "Batch ID khong ton tai"); // Đây là dòng báo lỗi bạn gặp
        require(!products[_serialNumber].isRegistered, "Serial Number da ton tai");

        products[_serialNumber] = Product({
            serialNumber: _serialNumber,
            batchId: _batchId,
            isRegistered: true,
            timestamp: block.timestamp
        });

        emit ProductRegistered(_serialNumber, _batchId, msg.sender);
    }

    // 3. Quét cập nhật trạng thái lô
    function scanBatch(uint _id, string memory _location, string memory _status) public {
        require(batches[_id].isInitialized, "Batch ID khong tim thay");
        
        batchHistories[_id].push(ScanRecord({
            timestamp: block.timestamp,
            location: _location,
            status: _status,
            actor: msg.sender
        }));

        emit BatchScanned(_id, _location, _status, msg.sender);
    }

    // 4. Lấy lịch sử
    function getBatchHistory(uint _id) public view returns (ScanRecord[] memory) {
        return batchHistories[_id];
    }
}