import 'package:flutter_test/flutter_test.dart';

import 'package:wanju_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WanjuApp());
    expect(find.text('万聚'), findsOneWidget);
  });
}