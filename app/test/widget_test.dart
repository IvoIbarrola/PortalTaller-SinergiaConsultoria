import 'package:flutter_test/flutter_test.dart';

import 'package:workspace/main.dart';

void main() {
  testWidgets('Portal Taller home screen renders the expected content',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Portal Taller'), findsOneWidget);
    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Consultá el estado de tus vehículos y reparaciones.'),
        findsOneWidget);
  });
}
