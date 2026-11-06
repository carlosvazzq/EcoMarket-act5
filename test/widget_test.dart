import 'package:flutter_test/flutter_test.dart';

import 'package:ecomarketapp/main.dart';

void main() {
  testWidgets('La app arranca y muestra el título', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EcoMarketApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('EcoMarket App'), findsOneWidget);
  });
}
