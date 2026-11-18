# SteamFix

Sửa lỗi Steam báo **"Mã lỗi: -7 — Không thể kết nối tới máy chủ"**. Chạy một file `.bat` là xong, không cài gì vào máy.

## Chạy

1. Vào [Releases](https://github.com/Huy0505/steamfix/releases), tải `SteamFix-2.1.0.bat`.
2. Nhấp đúp. Windows hỏi quyền admin thì bấm **Yes** (cần quyền này để đổi DNS).
3. SmartScreen có thể chặn vì file không ký số: **More info → Run anyway**.
4. Hiện menu, bấm `1` rồi Enter. Xong Steam tự mở lại.

Menu có thêm: `2` xem máy đang bị gì mà không thay đổi gì, `3` trả DNS về như cũ, `4` sửa lỗi giao diện (cửa sổ Steam trắng/đơ, `steamwebhelper` không phản hồi, `Failed to load steamui.dll`).

Máy báo lỗi mã khác xem bảng tra ở [ERRORS.md](ERRORS.md).

Vẫn lỗi thì vào Steam → Settings → Downloads, đổi Download Region (Singapore hoặc Hong Kong).

## Chạy tự động

Dùng cho máy nhiều người hoặc script:

```bat
SteamFix-2.1.0.bat -Mode check -NoPause                    :: chỉ kiểm tra
SteamFix-2.1.0.bat -Mode fix -Unattended -NoPause          :: sửa luôn, không hỏi
SteamFix-2.1.0.bat -Mode restore -Unattended -NoPause      :: trả DNS
SteamFix-2.1.0.bat -Mode ui -NoPause                       :: sửa lỗi giao diện
SteamFix-2.1.0.bat -Mode fix -Preview -NoPause             :: xem sẽ làm gì, không đổi gì
SteamFix-2.1.0.bat -Mode fix -Deep -Unattended -NoPause    :: thêm reset winsock, phải reboot
SteamFix-2.1.0.bat -Lang en -Mode fix                      :: giao diện tiếng Anh
```

`-Unattended` bắt buộc phải có `-Mode`, thiếu là tool thoát luôn chứ không đoán bừa.

Mã thoát: 0 không còn lỗi, 1 còn điểm chưa ổn, 2 người dùng huỷ, 3 máy không chạy được, 9 file .bat bị hỏng.

## Tool làm gì

1. Kiểm tra mạng và DNS. Mất mạng thật thì dừng, không đụng gì.
2. Tìm thư mục Steam (registry + mấy đường dẫn quen thuộc).
3. Tắt Steam đang chạy.
4. Đổi tên `htmlcache`, `appcache`, `config\htmlcache` rồi tạo thư mục rỗng. Bản cũ vẫn còn, tên có đuôi `.old_<ngày giờ>`.
5. `ipconfig /flushdns` và tắt proxy (WinHTTP + Internet Settings).
6. Đặt DNS `1.1.1.1` + `8.8.8.8` cho card mạng đang dùng. DNS cũ lưu ở `%LOCALAPPDATA%\SteamFix\dns-backup.json`.
7. Thử kết nối tới server Steam rồi mở lại Steam.

Log nằm trong `%LOCALAPPDATA%\SteamFix\logs`. Không ghi được vào đó thì tool lùi về `%TEMP%\SteamFix`.

## Có virus không

Chắc chắn là có người hỏi, nên mình ghi rõ trong [SECURITY.md](SECURITY.md): tool không gửi dữ liệu đi đâu, không tải code từ mạng, không cài service hay task, không đọc tài khoản Steam.

Bản một-file có nhúng payload base64 nên antivirus hay gắn cờ "downloader". Muốn đọc code trước khi chạy thì tải `SteamFix-2.1.0-plain.zip`, trong đó là `.ps1` mở bằng Notepad được, không mã hoá.

Kiểm tra nhanh: chạy `-Mode check` (không đổi gì), hoặc so SHA256 trong `SHA256.txt`, hoặc tự build.

## Không cứu được khi nào

- Steam đang bảo trì: xem [steamstat.us](https://steamstat.us).
- ISP chặn, phải bật VPN mới vào được.
- Máy dùng proxy của công ty/trường. Bước 5 tắt proxy sẽ làm mất mạng, chạy `-Mode check` trước cho chắc.
- Lỗi từ `steam.cfg` cũ, Steam Deck/Proton, hoặc bộ cài Steam hỏng.

## Build

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Version 2.1.1
```

Ra `dist/` gồm `.bat` một file, bản plain, 2 file zip và `SHA256.txt`. Nguồn nằm ở `src/Fix-Steam.ps1`.

Đẩy tag `v*` lên là workflow tự build và gắn file vào Release.

Giấy phép MIT, xem [LICENSE](LICENSE).
