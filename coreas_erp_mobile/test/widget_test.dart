import 'package:flutter_test/flutter_test.dart';
import 'package:coreas_erp_mobile/main.dart';

void main() {
  testWidgets('CoreasErpMobileApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CoreasErpMobileApp());
    expect(find.text('CoreasERP'), findsOneWidget);
  });
}
