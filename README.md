# SteamFix — sửa lỗi Steam “Mã lỗi: -7 — không kết nối tới máy chủ”

Công cụ một file, không cần cài đặt, dùng được cho nhiều máy khác nhau.

## Dùng (người dùng thường)

1. Tải **`SteamFix-2.0.0.bat`**.
2. Nhấp đúp. Nếu Windows hiện *“Windows protected your PC”*: bấm **More info → Run anyway** (file không có chữ ký số).
3. Bấm **Yes** ở hộp thoại UAC.
4. Chọn trong menu:
   - `1` — sửa lỗi ngay (mặc định, chỉ cần Enter)
   - `2` — chỉ kiểm tra, không thay đổi gì
   - `3` — hoàn tác, trả DNS về như cũ
   - `0` — thoát

Xong, Steam tự mở lại. Nếu vẫn lỗi: Steam → Settings → Downloads → đổi **Download Region**.

## Có virus không? / Is it safe?

Người dùng có lý do để nghi: file `.bat` không chữ ký, xin quyền Admin, đổi DNS. Chi tiết đầy đủ ở [`SECURITY.md`](SECURITY.md), tóm tắt:

- **Không** gửi dữ liệu đi đâu, **không** tải code từ mạng, **không** cài service/driver/task, **không** đọc tài khoản Steam.
- Chỉ chạy: tắt tiến trình Steam, đổi tên cache, `ipconfig /flushdns`, tắt proxy, đặt DNS `1.1.1.1/8.8.8.8` (lưu DNS cũ, hoàn tác bằng menu `3`), rồi mở lại Steam.
- Bản một-file có payload base64 → AV có thể báo nhầm "downloader". Muốn đọc code trước khi chạy thì tải **`SteamFix-2.0.0-plain.zip`**: `.ps1` đọc được bằng Notepad, không base64.
- Kiểm chứng: `-Mode check` (không đổi gì), đối chiếu `SHA256.txt`, hoặc tự build từ `src/`.

## Dành cho IT / chạy hàng loạt

```bat
SteamFix-2.0.0.bat -Mode check  -NoPause                    :: kiểm tra, không đổi gì
SteamFix-2.0.0.bat -Mode fix    -Unattended -NoPause        :: sửa tự động, không hỏi
SteamFix-2.0.0.bat -Mode restore -Unattended -NoPause       :: hoàn tác DNS
SteamFix-2.0.0.bat -Mode fix -Deep -Unattended -NoPause     :: thêm reset winsock/TCP (cần reboot)
SteamFix-2.0.0.bat -Lang en     -Mode fix                   :: giao diện tiếng Anh
```

| Tham số | Ý nghĩa |
|---|---|
| `-Mode fix\|check\|restore` | Việc cần làm (bỏ trống → menu) |
| `-Unattended` | Không hỏi xác nhận, không xin UAC (dùng khi đã chạy bằng tài khoản admin) |
| `-NoPause` | Không dừng chờ Enter ở cuối (cho script tự động) |
| `-Deep` | Thêm `netsh winsock reset` + `netsh interface ip reset` (phải khởi động lại máy) |
| `-Lang vi\|en` | Ngôn ngữ; mặc định theo Windows, không phải tiếng Việt thì dùng tiếng Anh |

Mã thoát: `0` = không còn lỗi, `1` = còn điểm chưa ổn, `2` = người dùng huỷ, `3` = môi trường không hỗ trợ, `9` = file .bat bị hỏng.

## Tool làm gì

| # | Bước | An toàn? |
|---|------|----------|
| 1 | Ping/TCP ra ngoài + phân giải `api.steampowered.com` | Chỉ đọc, mạng chết thì dừng sớm |
| 2 | Tìm Steam (HKCU/HKLM registry + thư mục mặc định) | Chỉ đọc |
| 3 | Tắt `steam`, `steamwebhelper`, `steamservice`… | Không mất dữ liệu game |
| 4 | Đổi tên `htmlcache`, `appcache`, `config\htmlcache` rồi tạo thư mục rỗng | **Có bản sao** `.old_<ngày giờ>`, giữ 2 bản gần nhất |
| 5 | `ipconfig /flushdns`, tắt proxy (WinHTTP + Internet Settings) | Tắt proxy có thể làm hỏng mạng công ty — xem mục dưới |
| 6 | Đặt DNS `1.1.1.1` + `8.8.8.8` cho card đang giữ default route | **Tự lưu DNS cũ** vào `%LOCALAPPDATA%\SteamFix\dns-backup.json` |
| 7 | Test TCP tới API/Store/CM của Steam, mở lại Steam | Chỉ đọc |

Log: `%LOCALAPPDATA%\SteamFix\logs\steamfix-<ngày giờ>.log`. Không ghi được vào `%LOCALAPPDATA%` thì tự lùi về `%TEMP%\SteamFix\logs`.

## Hoàn tác

- DNS: chạy lại tool, chọn `3` (hoặc `-Mode restore`).
- Cache: xoá thư mục mới, đổi tên `*.old_<ngày giờ>` về tên cũ.
- Không có service/driver/dịch vụ nào được cài; tool là file .bat tự sinh 1 file PowerShell tạm trong `%TEMP%` rồi xoá sau khi chạy.

## Khi tool không cứu được

- Steam/Valve đang bảo trì hoặc sập toàn cầu → xem <https://steamstat.us>.
- ISP chặn cứng, chỉ vào được khi bật VPN → tool không bật VPN thay bạn.
- Máy dùng proxy bắt buộc (công ty/trường): bước 5 tắt proxy sẽ làm mất mạng — dùng `-Mode check` trước, hoặc bật lại proxy sau khi chạy.
- Lỗi do `steam.cfg` cũ, Steam Deck/Proton, hoặc hỏng file cài Steam → xử lý thủ công.

## Ghi chú phát hành

- File `.bat` là **một file duy nhất** chứa toàn bộ script (base64). Không cần file phụ.
- Không ký số → SmartScreen/antivirus có thể cảnh báo; kiểm tra `SHA256.txt` kèm trong zip trước khi chạy.
- Muốn tự kiểm tra trước khi cho ai chạy: `-Mode check` (không thay đổi bất cứ thứ gì).

## Phát hành trên GitHub

Đẩy **mã nguồn**, không đẩy `dist/` (đã có trong `.gitignore`) — file chạy được đưa lên **Releases**:

```powershell
git init; git add .; git commit -m "SteamFix 2.0.0"
# tao repo tren GitHub roi:
git remote add origin https://github.com/<user>/steamfix.git
git push -u origin main
git tag v2.0.0; git push origin v2.0.0
```

Có tag `v*` là workflow [`.github/workflows/build.yml`](.github/workflows/build.yml) tự build và gắn `.bat`, `.zip`, `SHA256.txt` vào Release. Không có tag thì file build nằm ở mục **Actions → Artifacts**.

## Build lại từ nguồn

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Version 2.0.1
```

Sinh ra `dist/SteamFix-<version>.bat`, `dist/SteamFix-<version>.zip`, `dist/SHA256.txt`. Nguồn: `src/Fix-Steam.ps1`.

Giấy phép: MIT (xem `LICENSE`).
