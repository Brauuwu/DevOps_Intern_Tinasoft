# Hướng dẫn chạy App6: Spring Boot Backend

Đây là một dự án ứng dụng Backend cung cấp REST API được khởi tạo dựa trên hệ sinh thái **Java Spring Boot** và cấu trúc build bằng **Maven**.

## 🛠️ Yêu cầu môi trường
- Máy tính cần cài đặt **Java Development Kit (JDK)** phiên bản từ 17 trở lên.
- Đã cấu hình và cài đặt công cụ **Maven** (Nếu bạn dùng IDE như IntelliJ IDEA hay Eclipse thì Maven thường đã được tích hợp sẵn).

## 🚀 Cách chạy ứng dụng trên máy local (Môi trường Dev)

**Cách 1: Sử dụng Terminal / Command Prompt**
1. Trỏ Terminal vào thư mục chứa project:
```bash
cd Sample_WebApps/App6_SpringBoot_Backend
```
2. Khởi động ứng dụng bằng lệnh Maven wrapper:
```bash
mvn spring-boot:run
```
*(Lưu ý: Nếu không nhận lệnh `mvn`, bạn có thể chạy `./mvnw spring-boot:run` trên Linux/Mac hoặc `mvnw.cmd spring-boot:run` trên Windows nếu project có sẵn wrapper. Nếu không, hãy mở qua IDE ở Cách 2).*

**Cách 2: Sử dụng IDE (Khuyến nghị)**
1. Mở thư mục `App6_SpringBoot_Backend` trực tiếp bằng IntelliJ IDEA, Eclipse, hoặc VSCode (có cài Java Extension Pack).
2. Chờ IDE tự động load file `pom.xml` và tải các thư viện về máy.
3. Mở file `src/main/java/com/example/demo/DemoApplication.java` và ấn nút **Run** (mũi tên màu xanh).

**Kiểm tra API**
Mở trình duyệt hoặc dùng Postman truy cập URL: 
`http://localhost:8080/api/status`

## 🐳 Gợi ý khi đóng gói Docker (Production Build)
Ứng dụng Java nên sử dụng kỹ thuật Multi-stage build để tối ưu dung lượng:
1. **Build mã nguồn:** Dùng image `maven` hoặc `maven:eclipse-temurin` để chạy lệnh `mvn clean package`. File đầu ra sẽ là một file thực thi có đuôi `.jar` nằm trong thư mục `target/`.
2. **Thực thi ứng dụng:** Dùng một image Java Runtime siêu nhẹ (vd: `eclipse-temurin:17-jre-alpine`) để copy nguyên file `.jar` đó từ Stage 1 sang và chạy lệnh `java -jar ten-file.jar`.
