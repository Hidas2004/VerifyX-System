const express = require('express');
const cors = require('cors');
const Web3 = require('web3');

// --- CẤU HÌNH ---
const app = express();
app.use(cors());
app.use(express.json());

// 1. Kết nối Ganache
const web3 = new Web3('http://127.0.0.1:7545');

// 2. DÁN THÔNG TIN TỪ BƯỚC 1 VÀO ĐÂY
const contractAddress = '0x480586580b913E1802803Ed2f9f7349eE2F5F3eA';
const contractABI = [
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "OwnableInvalidOwner",
		"type": "error"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "OwnableUnauthorizedAccount",
		"type": "error"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "BatchCreated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "location",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "status",
				"type": "string"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "actor",
				"type": "address"
			}
		],
		"name": "BatchScanned",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_initialLocation",
				"type": "string"
			}
		],
		"name": "createBatch",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_location",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_status",
				"type": "string"
			}
		],
		"name": "scanBatch",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "batches",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "bool",
				"name": "isInitialized",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_id",
				"type": "uint256"
			}
		],
		"name": "getBatchHistory",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "location",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "status",
						"type": "string"
					},
					{
						"internalType": "address",
						"name": "actor",
						"type": "address"
					}
				],
				"internalType": "struct ProductVerification.ScanRecord[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];
const serverAccountPrivateKey = '0x6563dbb08092c9a4e97042a324200cd9ca4acf3e961a65591715f203a71393cf';
// --------------------

// 3. Khởi tạo tài khoản và hợp đồng
const serverAccount = web3.eth.accounts.privateKeyToAccount(serverAccountPrivateKey);
web3.eth.accounts.wallet.add(serverAccount);
const contract = new web3.eth.Contract(contractABI, contractAddress);
console.log(`May chu su dung vi: ${serverAccount.address}`);

// --- API CHO BRAND "ĐĂNG LÊN" ---
app.post('/api/batch/create', async (req, res) => {
  try {
    const { id, name, initialLocation } = req.body;

    const tx = await contract.methods.createBatch(id, name, initialLocation).send({
      from: serverAccount.address,
      gas: 500000,
    });

		console.log(`[createBatch] id=${id} name=${name} location=${initialLocation} tx=${tx.transactionHash}`);
    res.status(201).json({ success: true, txHash: tx.transactionHash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// --- API CHO USER/SHIPPER "QUÉT" ---
app.post('/api/batch/scan', async (req, res) => {
  try {
    const { id, location, status } = req.body;

    const tx = await contract.methods.scanBatch(id, location, status).send({
      from: serverAccount.address,
      gas: 300000,
    });

		console.log(`[scanBatch] id=${id} location=${location} status=${status} tx=${tx.transactionHash}`);
    res.status(201).json({ success: true, txHash: tx.transactionHash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// --- API CHO USER "TRUY XUẤT" ---
app.get('/api/history/:id', async (req, res) => {
  try {
		const batchId = req.params.id;
		console.log(`[getHistory] id=${batchId}`);

		// Kiểm tra batch tồn tại trước để tránh revert và lỗi decode
		const batch = await contract.methods.batches(batchId).call();
		if (!batch.isInitialized) {
			return res.status(404).json({
				error: `Batch ${batchId} khong ton tai tren blockchain`,
			});
		}

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

// Khởi động máy chủ
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`May chu API VerifyX (Node.js) dang chay tai http://localhost:${PORT}`);
});
