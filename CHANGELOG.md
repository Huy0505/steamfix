# Changelog

## 2.1.0

- Thêm mục menu `4` / `-Mode ui`: sửa lỗi giao diện Steam (cửa sổ trắng, đơ, `steamwebhelper` không phản hồi, "Failed to load steamui.dll") bằng cách đổi tên `steamui.dll` để Steam tải lại (bản cũ giữ lại).
- Áp dụng cho cả nhóm lỗi kết nối `-7`, `-101`, `-102`, `-105`, `-118`, `-53`, không chỉ riêng `-7`.
- Thêm `-Preview`: chạy thử bất kỳ mode nào mà không thay đổi gì.
- Thêm `ERRORS.md`: bảng tra các lỗi Steam hay gặp và nên chọn gì.
- Số bước hiển thị tự tính theo mode (`1/7`, `1/6`…).

## 2.0.1

- Thêm bản **`-plain.zip`**: `SteamFix.ps1` + `Run-SteamFix.bat` đọc trực tiếp, không base64 — dành cho người muốn đọc code trước khi chạy, cũng ít bị antivirus gắn cờ hơn.
- Thêm `SECURITY.md` và mục "Có virus không? / Is it safe?" trong README (liệt kê đúng các lệnh tool chạy).
- `build.ps1` tự ghi số phiên bản vào script; `SHA256.txt` gồm cả hash của bản plain.

## 2.0.0 — bản dùng chung cho nhiều người

- Đóng gói **một file `.bat` duy nhất** (payload base64 tự giải nén ra `%TEMP%`, chạy xong tự xoá) → gửi qua chat/email là dùng được.
- Thêm `build.ps1` sinh `dist/SteamFix-2.0.0.bat`, `.zip` (kèm README, LICENSE, SHA256) và `SHA256.txt`.
- Menu tương tác: sửa / chỉ kiểm tra / hoàn tác / thoát; Enter = sửa.
- Hai ngôn ngữ Việt–Anh, tự chọn theo ngôn ngữ Windows (`-Lang` để ép).
- Hỏi xác nhận trước khi thay đổi; huỷ UAC vẫn chạy tiếp ở chế độ giới hạn thay vì thoát.
- Tìm Steam qua HKCU + HKLM (cả WOW6432Node) + nhiều ổ đĩa.
- Chọn card mạng theo default route (metric thấp nhất) thay vì card đầu tiên; hỗ trợ nhiều DNS backup (mỗi card một mục).
- Dữ liệu trạng thái + log chuyển về `%LOCALAPPDATA%\SteamFix` (tự lùi về `%TEMP%` nếu không ghi được).
- Hoàn tác DNS ngay trong tool (`-Mode restore`), backup được đánh dấu `.used` sau khi hoàn tác.
- Thêm `-Deep` (reset winsock/TCP), `-Unattended`, `-NoPause`, mã thoát 0/1/2/3/9.
- Log ghi cả phiên bản tool, chế độ, quyền Admin, phiên bản Windows.

## 1.0.0

- Bản đầu: một `.ps1` + `.bat` + `.bat` hoàn tác DNS, giao diện tiếng Việt không dấu.
- Sửa lỗi: kiểm tra mạng không còn chặn nhầm khi ICMP bị firewall chặn.
