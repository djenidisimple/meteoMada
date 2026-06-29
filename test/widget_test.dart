import 'package:flutter_test/flutter_test.dart';
import 'package:meteomada/main.dart';

void main() {
  testWidgets('App should launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MeteoMadaApp());
  });
}
