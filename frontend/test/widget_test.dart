import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_monitor_app/main.dart';

void main() {
  testWidgets('shows the water monitoring sign-in screen', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    await tester.pumpWidget(const WaterMonitorApp());
    await tester.pumpAndSettle();
    expect(find.text('Theo dõi nguồn nước\ncủa bạn mỗi ngày.'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
