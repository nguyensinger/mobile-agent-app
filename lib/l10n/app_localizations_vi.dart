// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'IT Support Agent';

  @override
  String get loginSubtitle => 'Đăng nhập để nhận và xử lý ticket hỗ trợ';

  @override
  String get serverAddressLabel => 'Địa chỉ máy chủ VM TECH';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get apiKeyHint => 'API key cá nhân của bạn';

  @override
  String get signInButton => 'Đăng nhập';

  @override
  String get errorEnterServerAddress => 'Vui lòng nhập địa chỉ máy chủ';

  @override
  String get errorEnterApiKey => 'Vui lòng nhập API key';

  @override
  String get errorNotAgent =>
      'Tài khoản này không thuộc nhóm IT Support Agent/Manager. Vui lòng liên hệ quản trị viên.';

  @override
  String errorConnectionFailed(String error) {
    return 'Không kết nối được: $error';
  }

  @override
  String get appBarTitle => 'IT Support';

  @override
  String tabMine(int count) {
    return 'Của tôi ($count)';
  }

  @override
  String tabUnassigned(int count) {
    return 'Chưa gán ($count)';
  }

  @override
  String get retryButton => 'Thử lại';

  @override
  String get emptyMyTickets => 'Bạn chưa có ticket nào đang xử lý.';

  @override
  String get emptyUnassignedTickets =>
      'Không có ticket nào đang chờ tiếp nhận.';

  @override
  String get priorityLow => 'Thấp';

  @override
  String get priorityNormal => 'Bình thường';

  @override
  String get priorityHigh => 'Cao';

  @override
  String get priorityUrgent => 'Khẩn cấp';

  @override
  String get stateNew => 'Mới';

  @override
  String get stateAssigned => 'Đã gán';

  @override
  String get stateInProgress => 'Đang xử lý';

  @override
  String get statePaused => 'Tạm dừng';

  @override
  String get stateDone => 'Hoàn thành';

  @override
  String get stateCancelled => 'Đã hủy';

  @override
  String get noDeviceLabel => 'Không gắn thiết bị';

  @override
  String hoursLabel(String hours) {
    return '$hours giờ';
  }

  @override
  String get assignToMeButton => 'Nhận xử lý';

  @override
  String get startButton => 'Bắt đầu';

  @override
  String get endButton => 'Kết thúc';

  @override
  String get markDoneButton => 'Hoàn thành';

  @override
  String get supportModeDialogTitle => 'Hình thức xử lý';

  @override
  String get supportModeOnline => 'Online';

  @override
  String get supportModeOnsite => 'Onsite';

  @override
  String get endSessionDialogTitle => 'Kết thúc xử lý';

  @override
  String get endSessionNoteHint => 'Nội dung công việc đã thực hiện';

  @override
  String get endSessionResolutionStatusLabel => 'Trạng thái xử lý';

  @override
  String get endSessionResolutionStatusHint => '-- Chọn --';

  @override
  String get resolutionStatusResolved => 'Đã giải quyết';

  @override
  String get resolutionStatusPartiallyResolved => 'Giải quyết một phần';

  @override
  String get resolutionStatusNotResolved => 'Chưa giải quyết';

  @override
  String get resolutionStatusEscalated => 'Chuyển cấp cao hơn';

  @override
  String get endSessionNoteRequiredError =>
      'Vui lòng mô tả công việc đã thực hiện.';

  @override
  String get endSessionResolutionRequiredError =>
      'Vui lòng chọn trạng thái xử lý.';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get confirmButton => 'Xác nhận';

  @override
  String get markDoneDialogTitle => 'Đánh dấu ticket hoàn thành?';

  @override
  String get markDoneDialogContent =>
      'Ticket sẽ chuyển sang trạng thái Hoàn thành. Phiên xử lý đang chạy (nếu có) sẽ tự động kết thúc.';

  @override
  String get noMessagesYet => 'Chưa có tin nhắn nào.';

  @override
  String get chatInputHint => 'Nhập tin nhắn...';

  @override
  String get ticketFallbackTitle => 'Ticket';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get logoutButton => 'Đăng xuất';

  @override
  String get bookingRequestsTitle => 'Yêu cầu đặt lịch';

  @override
  String get bookingRequestsTooltip => 'Yêu cầu đặt lịch';

  @override
  String get emptyBookingRequests => 'Không có yêu cầu đặt lịch nào đang chờ.';

  @override
  String get bookingConfirmButton => 'Xác nhận & Tạo Ticket';

  @override
  String get bookingConfirmDialogTitle => 'Xác nhận yêu cầu đặt lịch này?';

  @override
  String get bookingConfirmDialogContent =>
      'Hệ thống sẽ tạo hồ sơ khách hàng (nếu chưa có) và một ticket ban đầu từ yêu cầu này.';
}
