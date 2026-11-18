# Các lỗi Steam hay gặp

Bảng tra nhanh: máy báo gì thì làm gì.

| Máy báo | Nguyên nhân thường | Cách xử lý |
|---|---|---|
| `Mã lỗi -7`, `-101`, `-102`, `-105`, `-118`, `Lỗi kết nối`, "Steam is having trouble connecting to the Steam servers" | Máy không mở được kết nối tới server đăng nhập của Steam: DNS sai, proxy/VPN chặn, cache DNS hỏng, router | Tool, chọn `1` |
| `-53` "Steam servers are too busy" | Server Valve quá tải hoặc bảo trì | Chờ, hoặc đổi Download Region. Không phải lỗi máy bạn |
| "Content servers unreachable", tải game cứ 0 byte, "Update paused" | Server tải game bị chặn hoặc vùng tải sai | Đổi Download Region (Singapore/Hong Kong). Tool có tắt proxy hộ |
| "Steam needs to be online to update" | Mạng/DNS hoặc file `steam.cfg` chặn cập nhật | Tool chọn `1`. Nếu vẫn lỗi, xoá `steam.cfg` trong thư mục Steam |
| Cửa sổ Steam trắng, đen, đơ; "steamwebhelper is not responding"; "Failed to load steamui.dll" | Cache giao diện hoặc `steamui.dll` hỏng | Tool, chọn `4` (đổi tên `steamui.dll`, Steam tải lại) |
| "Steam is already running" / treo ở "Connecting Steam account" | Tiến trình Steam cũ còn chạy | Tool chọn `1` (tắt sạch rồi mở lại) |
| "Missing file privileges", "Disk write error" | Thiếu quyền ghi hoặc ổ đĩa lỗi | Chạy tool bằng quyền Admin; kiểm tra dung lượng/ổ; Steam → Properties → Installed Files → Verify |
| Steam khởi động chậm, icon tray không hiện | Cài đặt cũ | Đổi Download Region, hoặc cài lại Steam (giữ thư mục `steamapps`) |
| "Steam Guard code not working", không nhận mã | Không phải lỗi mạng | Kiểm tra giờ hệ thống, đổi mạng, dùng mã dự phòng |

## Tool làm được gì trong đống trên

- Nhóm lỗi kết nối (`-7`, `-101`, `-102`, `-105`, `-118`, `-53` một phần): chọn `1`.
- Lỗi giao diện / `steamui.dll` / `steamwebhelper`: chọn `4`.
- Còn lại là việc phải làm tay: đổi Download Region, xoá `steam.cfg`, Verify files, cài lại Steam.

## Đổi Download Region ở đâu

Steam → Settings (hoặc Steam → Preferences) → Downloads → **Download Region** → chọn Singapore, Hong Kong hoặc Việt Nam nếu có → khởi động lại Steam.

## Verify file game

Thư viện → chuột phải game → Properties → Installed Files → **Verify integrity of game files**.
