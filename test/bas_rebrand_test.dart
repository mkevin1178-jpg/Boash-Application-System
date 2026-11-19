import 'package:bas/features/auth/login_screen.dart';
import 'package:bas/features/splash/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

void main() {
  setUpAll(disableRuntimeFontFetching);

  testWidgets('splash dan login memakai identitas BAS', (tester) async {
    await tester.pumpWidget(wrapWithTheme(const SplashScreen()));
    await tester.pump();

    expect(find.text('BAS'), findsOneWidget);
    expect(find.text('BOASH'), findsNothing);

    final controller = await createController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      wrapWithTheme(
        LoginScreen(controller: controller, repository: fastRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BAS'), findsOneWidget);
    expect(find.text('BOASH STUDENT APP'), findsNothing);
  });
}
