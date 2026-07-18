// test/widget_test.dart
// Basic smoke test - kiểm tra app khởi động được mà không crash.
// Không test logic nghiệp vụ phức tạp (cần mock API/SharedPreferences).

import 'package:flutter_test/flutter_test.dart';
import 'package:it_support_agent_app/main.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ItSupportAgentApp());
    // App hiển thị loading indicator khi đang kiểm tra trạng thái đăng nhập
    expect(find.byType(ItSupportAgentApp), findsOneWidget);
  });
}
