import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tontinepro_collecteur/app.dart';

void main() {
  testWidgets('app boots without framework exception', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TontineCollecteurApp()),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
