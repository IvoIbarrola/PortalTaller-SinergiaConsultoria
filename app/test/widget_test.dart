import 'package:flutter_test/flutter_test.dart';

import 'package:workspace/main.dart';

void main() {
  testWidgets('Portal Taller login renders the expected content',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Portal Taller'), findsOneWidget);
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Código'), findsOneWidget);
    expect(find.text('Contraseña'), findsNothing);
    expect(find.text('Seguí el estado de tu siniestro o ingresá a las herramientas de gestión.'),
        findsOneWidget);
  });
}
