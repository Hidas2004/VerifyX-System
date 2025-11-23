const express = require('express');
const cors = require('cors');
const Web3 = require('web3');
const path = require('path');
const fs = require('fs');
const admin = require('firebase-admin');

// --- 1. CẤU HÌNH FIREBASE ADMIN ---
try {
  const serviceAccount = require('./serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log("✅ Ket noi Firebase Admin thanh cong!");
} catch (error) {
  console.error("❌ LOI: Chua co file 'serviceAccountKey.json'.");
}

const db = admin.firestore();

// --- 2. CẤU HÌNH SERVER & BLOCKCHAIN ---
const app = express();
app.use(cors());
app.use(express.json());

// Kết nối Ganache
const web3 = new Web3('http://127.0.0.1:7545');

// Đọc Contract
const contractBuildPath = path.resolve(__dirname, '../VerifyX/build/contracts/ProductVerification.json');
if (!fs.existsSync(contractBuildPath)) {
  console.error("❌ LOI: Khong tim thay file build smart contract.");
  process.exit(1);
}
const contractJson = JSON.parse(fs.readFileSync(contractBuildPath, 'utf8'));
const contractAddress = contractJson.networks['5777'].address;
const contractABI = contractJson.abi;

console.log(`Da load hop dong: ProductVerification`);
console.log(`Dia chi hop dong: ${contractAddress}`);

const serverAccountPrivateKey = '0x6563dbb08092c9a4e97042a324200cd9ca4acf3e961a65591715f203a71393cf'; // Private Key của bạn
const serverAccount = web3.eth.accounts.privateKeyToAccount(serverAccountPrivateKey);
web3.eth.accounts.wallet.add(serverAccount);
const contract = new web3.eth.Contract(contractABI, contractAddress);
console.log(`May chu su dung vi: ${serverAccount.address}`);

// ============================================================
// API 1: TẠO LÔ HÀNG (BATCH)
// ============================================================
app.post('/api/batch/create', async (req, res) => {
  try {
    const { brandId, brandName, batchNumber, productName, manufactureDate, expiryDate, quantity } = req.body;
    console.log(`🔄 [API] Tao lo hang: ${batchNumber}`);

    const blockchainId = Date.now(); 

    const tx = await contract.methods.createBatch(
        blockchainId, batchNumber
    ).send({ from: serverAccount.address, gas: 600000 });

    const batchData = {
        batchNumber, productName, brandId, brandName, manufactureDate, expiryDate, 
        quantity: parseInt(quantity), status: 'active', productIds: [],
        blockchainData: { id: blockchainId, txHash: tx.transactionHash, timestamp: Date.now() },
        createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
    };

    const docRef = await db.collection('batches').add(batchData);
    await docRef.update({ id: docRef.id });

    console.log(`✅ Batch OK. Hash: ${tx.transactionHash}`);
    res.status(201).json({ success: true, batchId: docRef.id, txHash: tx.transactionHash });
  } catch (error) {
    console.error("❌ LOI BATCH:", error);
    res.status(500).json({ error: error.toString() });
  }
});

// ============================================================
// API 2: TẠO SẢN PHẨM (PRODUCT) - [PHẦN BẠN ĐANG THIẾU]
// ============================================================
app.post('/api/product/create', async (req, res) => {
  try {
    const { 
      brandId, brandName, serialNumber, name, description, ingredients, 
      imageUrl, category, batchId, blockchainBatchId, manufacturingDate, expiryDate 
    } = req.body;

    console.log(`🔄 [API] Tao san pham: ${name} (Serial: ${serialNumber})`);

    // 1. Ghi Blockchain (Gắn sản phẩm vào lô)
    const tx = await contract.methods.registerProduct(
      serialNumber, blockchainBatchId 
    ).send({ from: serverAccount.address, gas: 600000 });

    const txHash = tx.transactionHash;
    console.log(`✅ Blockchain OK: ${txHash}`);

    // 2. Ghi Firebase
    const productData = {
      serialNumber, name, description, ingredients, category, brandId, brandName,
      imageUrl: imageUrl || "", batchId, blockchainBatchId, 
      manufacturingDate, expiryDate,
      blockchainData: { txHash: txHash, registeredAt: new Date().toISOString() },
      isActive: true, isReported: false, verificationCount: 0,
      createdAt: new Date().toISOString(), updatedAt: new Date().toISOString()
    };

    const docRef = await db.collection('products').add(productData);
    await docRef.update({ id: docRef.id });

    // 3. Cập nhật lô hàng (Thêm ID sản phẩm vào mảng productIds của Batch)
    await db.collection('batches').doc(batchId).update({
      productIds: admin.firestore.FieldValue.arrayUnion(docRef.id)
    });

    console.log(`✅ Product OK. ID: ${docRef.id}`);
    res.status(201).json({ success: true, productId: docRef.id, txHash: txHash });

  } catch (error) {
    console.error("❌ LOI PRODUCT:", error);
    res.status(500).json({ error: error.toString() });
  }
});

// ============================================================
// API 3: QUÉT CẬP NHẬT TRẠNG THÁI
// ============================================================
app.post('/api/batch/scan', async (req, res) => {
  try {
    const { id, location, status } = req.body;
    const tx = await contract.methods.scanBatch(id, location, status).send({ from: serverAccount.address, gas: 300000 });
    console.log(`[scanBatch] id=${id} status=${status}`);
    res.status(201).json({ success: true, txHash: tx.transactionHash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================
// API 4: TRUY XUẤT LỊCH SỬ
// ============================================================
app.get('/api/history/:id', async (req, res) => {
  try {
    const batchId = req.params.id;
    const batch = await contract.methods.batches(batchId).call();
    if (!batch.isInitialized) return res.status(404).json({ error: `Batch ${batchId} not found` });

    const history = await contract.methods.getBatchHistory(batchId).call();
    const formattedHistory = history.map((record) => ({
      timestamp: new Date(Number(record.timestamp) * 1000).toISOString(),
      location: record.location,
      status: record.status,
      actor: record.actor,
    }));
    res.status(200).json(formattedHistory);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 May chu VerifyX dang chay tai http://localhost:${PORT}`);
});