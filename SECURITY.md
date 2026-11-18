# Bảo mật — SteamFix

Tool này đổi DNS và tắt proxy trên máy, nên câu hỏi "có virus không" là hợp lý. Đây là toàn bộ sự thật về nó.

## Tool KHÔNG làm gì

- Không gửi dữ liệu ra ngoài (không telemetry, không analytics, không upload file, không gửi tài khoản Steam).
- Không tải hay chạy code từ Internet. Script không hề gọi web; chỉ có các lệnh Windows cục bộ.
- Không cài service, driver, scheduled task, extension, registry autorun.
- Không đọc/ghi mật khẩu, cookie, `ssfn*`, `loginusers.vdf`, hay bất kỳ dữ liệu Steam nào.
- Không xoá game. Cache bị **đổi tên** thành `.old_<ngày giờ>`, không xoá cứng.

## Tool CÓ làm gì (đúng danh sách này)

| Lệnh / hành động | Tác dụng |
|---|---|
| `Stop-Process` cho `steam`, `steamwebhelper`, `steamservice`, `GameOverlayUI` | Tắt Steam trước khi làm mới cache |
| `Rename-Item` trên `htmlcache`, `appcache`, `config\htmlcache` | Làm mới cache, giữ bản cũ |
| `ipconfig /flushdns` | Xoá cache DNS của Windows |
| `netsh winhttp reset proxy` + sửa `ProxyEnable` trong `HKCU\...\Internet Settings` | Tắt proxy đang chặn Steam |
| `Set-DnsClientServerAddress` (1.1.1.1, 8.8.8.8) | Đổi DNS cho card mạng đang dùng; DNS cũ lưu ở `%LOCALAPPDATA%\SteamFix\dns-backup.json` |
| TCP connect tới `api.steampowered.com:443`, `store.steampowered.com:443`, `cm0.steamserver.net:27017` | Chỉ kiểm tra thông mạng |
| `Start-Process steam.exe` | Mở lại Steam |

Không có gì khác.

## Vì sao antivirus có thể báo nhầm

- File `.bat` không có chữ ký số (code-signing certificate rất đắt).
- Bản một-file chứa **payload base64** rồi ghi ra `%TEMP%` và chạy — đúng là mẫu hành vi mà heuristic của AV hay gắn cờ "Downloader/PS1 dropper". Tool không tải gì cả, payload nằm ngay trong file.
- Đổi DNS + tắt proxy là hành vi mà AV/PUP cũng hay làm.

Cách kiểm chứng thay vì tin lời:

1. Đọc [ `src/Fix-Steam.ps1`](src/Fix-Steam.ps1) — toàn bộ logic nằm ở đó, không obfuscate.
2. Tải **bản plain** (`SteamFix-<v>-plain.zip`): `.ps1` đọc trực tiếp bằng Notepad, không base64.
3. Chạy `-Mode check`: chỉ kiểm tra, không thay đổi gì.
4. So `SHA256.txt` trong Release với file đã tải (`Get-FileHash .\SteamFix-2.0.0.bat -Algorithm SHA256`).
5. Tự build: `powershell -ExecutionPolicy Bypass -File .\build.ps1`.

## Báo lỗi bảo mật

Mở issue tại <https://github.com/Huy0505/steamfix/issues> kèm mô tả và cách tái hiện. Không có bug bounty.
