import 'package:flutter_test/flutter_test.dart';

import 'package:ecomarketapp/main.dart';

void main() {
  testWidgets('La app arranca y muestra el título', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoMarketApp());
    expect(find.text('EcoMarket App'), findsOneWidget);
  });
}
