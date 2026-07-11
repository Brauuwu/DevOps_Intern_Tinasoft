# Sơ đồ Pipeline End-to-End tham khảo

Để hoàn thiện quy trình CI/CD End-to-End, nhóm cần liên kết các thành phần lại với nhau:

1. **Code Commit**: Developer push code lên GitLab/GitHub Repository.
2. **CI Pipeline (GitLab CI)**: Pipeline tự động trigger quá trình:
   - Run Unit Test.
   - Dùng Kaniko để build Docker Image.
   - Đẩy image lên Harbor Registry.
   - Update tag của image mới vào Git repo chứa Kubernetes manifest (hoặc repo riêng).
3. **CD Pipeline (ArgoCD)**:
   - ArgoCD phát hiện thay đổi trong Git repo manifest.
   - Tự động pull manifest mới và sync xuống Kubernetes Cluster.
4. **Kết quả**: Ứng dụng mới nhất được deploy mà không cần sự can thiệp thủ công.
