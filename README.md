# Mobile Agent App (Flutter)

Ứng dụng Android/iOS cho nhân viên IT support trực ca:
- Xem danh sách ticket (của tôi / chưa gán), nhận ticket mới
- Chat với khách hàng theo ticket (đồng bộ 2 chiều với Desktop Client App qua Odoo chatter)
- **Start / End session** để tính giờ công xử lý (onsite / online)
- Đánh dấu ticket hoàn thành
- Nhận thông báo ticket mới / tin nhắn mới theo thời gian thực (long-polling qua `bus.bus`)
- **Đa ngôn ngữ**: English / Tiếng Việt / Français, chọn ngay trong app (Settings), áp dụng
  ngay không cần khởi động lại

Đây là bản mobile tương đương với Desktop Agent App (Electron) — cùng nghiệp vụ, cùng gọi
REST API của module `it_support_management`, khác nền tảng UI.

## Cài đặt môi trường phát triển

```bash
flutter pub get
flutter run
```

## Build bản chính thức

```bash
flutter build apk --release          # Android (.apk)
flutter build appbundle --release    # Android (.aab) - dùng để publish Google Play
flutter build ios --release          # iOS (cần macOS + Xcode)
```

## Đăng nhập

Mỗi nhân viên IT support cần **API key cá nhân riêng** (không dùng chung), tạo tại:

Odoo: tự đăng nhập bằng tài khoản của mình → bấm avatar góc trên phải → My Profile →
tab Security → New API Key → **chọn "Persistent Key"** (không chọn thời hạn ngắn, tránh
tự hết hạn).

Khi đăng nhập, app gọi `/api/v1/whoami` để:
1. Xác thực API key hợp lệ.
2. Lấy đúng tên thật của agent từ server (không nhập tay).
3. Kiểm tra tài khoản có thuộc group "IT Support Agent"/"Manager" không - nếu không, từ
   chối đăng nhập.

## Lưu ý mạng

- **Giả lập Android**: dùng `http://10.0.2.2:8069` để trỏ về máy host (không dùng `localhost`).
- **Điện thoại thật qua WiFi**: dùng IP LAN thật của máy chạy Odoo, ví dụ `http://192.168.1.x:8069`.
- **iOS**: tương tự, cần cùng mạng LAN với máy chạy Odoo.

## Đa ngôn ngữ (i18n)

Dùng cơ chế chuẩn chính thức của Flutter (`flutter_localizations` + ARB files), **không**
dùng `flutter_gen`/`generate: true` (đang bị loại bỏ dần khỏi Flutter) - thay vào đó cấu
hình qua `l10n.yaml` với `synthetic-package: false`, sinh code trực tiếp vào
`lib/l10n/generated/`.

```
l10n.yaml                  # Cấu hình gen_l10n
lib/l10n/
  app_en.arb                # Tiếng Anh (gốc/template)
  app_vi.arb                # Tiếng Việt
  app_fr.arb                # Tiếng Pháp
  generated/                 # Tự sinh khi chạy `flutter gen-l10n` hoặc `flutter run`
    app_localizations.dart
    app_localizations_en.dart
    app_localizations_vi.dart
    app_localizations_fr.dart
```

Code KHÔNG cần chạy lệnh `flutter gen-l10n` riêng - Flutter tự chạy lại mỗi khi
`flutter pub get`/`flutter run`. Nếu thêm/sửa key trong file `.arb`, chỉ cần build lại app.

Cách thêm ngôn ngữ mới: tạo file `app_<mã ngôn ngữ>.arb` mới trong `lib/l10n/` với đầy đủ
key giống `app_en.arb`, thêm `Locale('<mã>')` vào `supportedLocales` (tự động lấy từ ARB,
không cần sửa code), và thêm option vào dropdown trong `lib/screens/settings_screen.dart`.

Chọn ngôn ngữ trong app được lưu cục bộ (`shared_preferences`) và áp dụng lại tự động khi
mở app lần sau.

## Model & i18n - lưu ý kiến trúc

`lib/models/ticket.dart` chỉ chứa dữ liệu thuần (`priority`, `state` dạng String thô từ
API), KHÔNG tự dịch sang label hiển thị - vì model không nên phụ thuộc `BuildContext`/ngôn
ngữ UI. Logic dịch nằm ở `lib/models/ticket_labels.dart` (extension `TicketLabels` cần
`BuildContext` để gọi `AppLocalizations.of(context)`), dùng trong widget qua
`ticket.stateLabel(context)` / `ticket.priorityLabel(context)`.

## Cấu trúc thư mục

```
lib/
  main.dart                   # Entry point, locale runtime switch, điều hướng login/danh sách
  models/
    ticket.dart                 # Model Ticket thuần (không phụ thuộc UI/ngôn ngữ)
    ticket_labels.dart            # Extension dịch state/priority - cần BuildContext
    chat_message.dart              # Model tin nhắn chat
  services/
    auth_service.dart                # Lưu/đọc base URL, API key, identity, ngôn ngữ đã chọn
    api_service.dart                   # Gọi REST API Odoo qua dio
    realtime_service.dart               # Vòng lặp long-polling, expose qua Stream
  screens/
    login_screen.dart                    # Đăng nhập, gọi whoami() lấy identity thật
    ticket_list_screen.dart               # Danh sách ticket (tab "Của tôi" / "Chưa gán")
    ticket_detail_screen.dart              # Chi tiết ticket: Start/End session, chat, Hoàn thành
    settings_screen.dart                    # Đổi ngôn ngữ
  widgets/
    ticket_card.dart                          # Widget hiển thị 1 ticket trong list
  l10n/
    app_en.arb, app_vi.arb, app_fr.arb           # Bản dịch
```

## Realtime

Khi mở danh sách ticket, app subscribe vào channel "dispatch" chung (báo có ticket mới).
Khi mở chi tiết 1 ticket, app subscribe channel riêng của ticket đó (báo tin nhắn mới, đổi
trạng thái, session start/end từ agent khác hoặc từ Desktop Client App của khách hàng).
Cùng cơ chế long-polling `/api/v1/poll` dùng chung trên toàn hệ thống.

## App icon (chưa làm)

Icon ứng dụng hiển thị trên màn hình điện thoại (khác với icon trong code/UI) cần dùng
package `flutter_launcher_icons` để tự sinh icon cho cả Android/iOS từ 1 file gốc. Đề xuất
dùng cùng icon chữ "A" (màu xanh dương #255AA8) đã tạo cho Desktop Agent App để đồng bộ
nhận diện, nhưng chưa áp dụng - cần thêm package này vào `dev_dependencies` và chạy
`flutter pub run flutter_launcher_icons` khi cần.
