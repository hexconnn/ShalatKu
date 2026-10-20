
import 'package:flutter_test/flutter_test.dart';
import 'package:shalatku/main.dart';

void main() {
  testWidgets('ShalatKu app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const ShalatKuApp());

    expect(find.text('ShalatKu'), findsOneWidget);
  });
}
