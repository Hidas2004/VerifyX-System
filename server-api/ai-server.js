// --- SERVER DÀNH RIÊNG CHO AI CHAT ---
// Chạy trên port 3001, độc lập với server.js (port 3000)

const express = require('express');
const cors = require('cors');
require('dotenv').config(); // Dùng chung file .env với server.js
const { GoogleGenerativeAI } = require("@google/generative-ai");

// Kiểm tra API Key từ file .env
if (!process.env.GEMINI_API_KEY) {
    console.error("LỖI (AI Server): Biến GEMINI_API_KEY chưa được set trong file .env");
    process.exit(1);
}

// Khởi tạo model Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// --- SỬA LỖI Ở DÒNG NÀY ---
// Google đã đổi tên model, "gemini-pro" cũ bị lỗi 404

// Tên mới là "gemini-1.5-flash-latest"
const model = genAI.getGenerativeModel({ model: "gemini-pro" });
// --- KẾT THÚC SỬA LỖI ---


// Khởi tạo Express
const app = express();
app.use(cors()); // Cho phép Flutter (từ domain khác) gọi
app.use(express.json()); // Để server đọc được JSON

// --- Endpoint chính cho AI ---
app.post('/api/ai/chat', async (req, res) => {
    console.log('[AI Server] Nhận yêu cầu /api/ai/chat...');
    
    try {
        const { prompt } = req.body;
        if (!prompt) {
            return res.status(400).json({ error: 'Thiếu nội dung "prompt"' });
        }

        // Gọi Gemini
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const aiText = response.text();

        // Trả kết quả về
        res.status(200).json({ reply: aiText });

    } catch (error) {
        console.error('[AI Server] Lỗi gọi Gemini:', error);
        res.status(500).json({ error: 'Máy chủ AI gặp lỗi' });
    }
});

// Chạy server AI trên port 3001
const AI_PORT = 3001;
app.listen(AI_PORT, () => {
    console.log(`May chu AI VerifyX (Node.js) dang chay tai http://localhost:${AI_PORT}`);
});