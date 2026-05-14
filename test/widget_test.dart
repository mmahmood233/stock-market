import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stock_market/core/di/injection_container.dart';
import 'package:stock_market/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await InjectionContainer.init();
  });

  tearDown(InjectionContainer.dispose);

  testWidgets('App loads the authentication flow', (tester) async {
    await tester.pumpWidget(const StockMarketApp());
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Stock Market'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Sign Up'), findsWidgets);
  });
}
