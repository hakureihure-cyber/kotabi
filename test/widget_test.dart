import 'package:flutter_test/flutter_test.dart';
import 'package:kotabi/main.dart';

void main() {
  testWidgets('KOTABI アプリが起動する', (WidgetTester tester) async {
    await tester.pumpWidget(const KotabiApp());
    await tester.pump();
    expect(find.text('子連れ旅行プラン作成'), findsOneWidget);
  });
}
