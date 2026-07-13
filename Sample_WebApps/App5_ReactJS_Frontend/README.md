# Hướng dẫn chạy App5: ReactJS Frontend

Đây là một dự án Single Page Application (SPA) được khởi tạo siêu tốc thông qua công cụ `Vite`.

## 🛠️ Yêu cầu môi trường
- Máy tính cần cài đặt sẵn **Node.js** (phiên bản 18+ được khuyến nghị) và **npm** (Node Package Manager).

## 🚀 Cách chạy ứng dụng trên máy local (Môi trường Dev)

1. Mở Terminal (Command Prompt / PowerShell) và trỏ đường dẫn vào thư mục dự án này:
```bash
cd Sample_WebApps/App5_ReactJS_Frontend
```

2. Cài đặt các thư viện (dependencies) cần thiết (chỉ cần chạy lần đầu tiên):
```bash
npm install
```

3. Khởi động server phát triển (Development Server):
```bash
npm run dev
```

4. Truy cập trình duyệt theo đường link xuất hiện trên Terminal (thường là `http://localhost:5173/`).

## 🐳 Gợi ý khi đóng gói Docker (Production Build)
Khi bạn cần đóng gói dự án này ở Tuần 2, quá trình build sẽ trải qua 2 bước (Multi-stage build):
1. **Build mã nguồn:** Dùng image `node` để chạy `npm install` và `npm run build`. Đầu ra của bước này là thư mục chứa file tĩnh tên là `dist/`.
2. **Phục vụ ứng dụng:** Dùng một image web server siêu nhẹ (vd: `nginx:alpine`) để copy nguyên thư mục `dist/` vào cấu hình Nginx mặc định và expose cổng 80.
