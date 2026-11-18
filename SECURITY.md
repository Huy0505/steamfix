# Có virus không?

Tool này sửa DNS và tắt proxy, nên hỏi vậy là đúng. Dưới đây là những gì nó chạy, đúng thứ tự, không giấu gì.

## Nó không làm mấy việc này

- Không gửi dữ liệu ra ngoài. Không telemetry, không upload file, không đụng tới tài khoản Steam.
- Không tải code từ mạng về chạy. Trong script không có lệnh gọi web nào, chỉ có lệnh của Windows.
- Không cài service, driver, scheduled task, extension hay autorun.
- Không đọc mật khẩu, cookie, `ssfn*`, `loginusers.vdf`.
- Không xoá game. Cache chỉ bị đổi tên thành `.old_<ngày giờ>`.

## Nó chạy đúng mấy lệnh này

| Lệnh | Để làm gì |
|---|---|
| `Stop-Process` cho `steam`, `steamwebhelper`, `steamservice`, `GameOverlayUI` | Tắt Steam trước khi làm mới cache |
| `Rename-Item` trên `htmlcache`, `appcache`, `config\htmlcache` | Làm mới cache, bản cũ vẫn giữ |
| `ipconfig /flushdns` | Xoá cache DNS của Windows |
| `netsh winhttp reset proxy`, sửa `ProxyEnable` trong `HKCU\...\Internet Settings` | Bỏ proxy đang chặn Steam |
| `Set-DnsClientServerAddress` với 1.1.1.1, 8.8.8.8 | Đổi DNS card mạng đang dùng, DNS cũ lưu ở `%LOCALAPPDATA%\SteamFix\dns-backup.json` |
| Kết nối thử tới `api.steampowered.com:443`, `store.steampowered.com:443`, `cm0.steamserver.net:27017` | Xem mạng có thông không |
| `Start-Process steam.exe` | Mở lại Steam |

Hết. Không có gì khác.

## Sao antivirus hay báo

- File `.bat` không có chữ ký số, mà chứng chỉ ký số thì tốn tiền.
- Bản một-file nhúng payload base64 rồi ghi ra `%TEMP%` để chạy. Đây đúng là kiểu mà AV hay gắn cờ "downloader", nhưng tool không tải gì cả, payload nằm ngay trong file.
- Đổi DNS với tắt proxy cũng là hành vi mấy con PUP hay làm.

Mấy cách kiểm tra, khỏi phải tin lời:

1. Mở [`src/Fix-Steam.ps1`](src/Fix-Steam.ps1) ra đọc, code không obfuscate.
2. Tải bản `SteamFix-<v>-plain.zip`, giải nén, mở `.ps1` bằng Notepad.
3. Chạy `-Mode check`, chỉ xem chứ không sửa gì.
4. So SHA256: `Get-FileHash .\SteamFix-2.0.1.bat -Algorithm SHA256` rồi đối chiếu `SHA256.txt`.
5. Tự build bằng `build.ps1`.

Có vấn đề bảo mật thì mở issue ở [đây](https://github.com/Huy0505/steamfix/issues).
