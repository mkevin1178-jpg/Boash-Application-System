import 'package:bas/data/demo_repository.dart';
import 'package:bas/features/academic/assignments_screen.dart';
import 'package:bas/models/assignment.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_harness.dart';

/// Repository yang selalu mengembalikan daftar tugas kosong.
class _EmptyRepository extends DemoRepository {
  _EmptyRepository() : super(latency: Duration.zero);

  @override
  Future<List<Assignment>> fetchAssignments() async => const [];
}

void main() {
  setUpAll(disableRuntimeFontFetching);

  testWidgets('menampilkan error state dan tombol coba lagi', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        AssignmentsScreen(
          controller: controller,
          repository: fastRepository(simulateFailure: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat data'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('menampilkan empty state saat data kosong', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        AssignmentsScreen(
          controller: controller,
          repository: _EmptyRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada tugas pada filter ini'), findsOneWidget);
  });

  testWidgets('tombol coba lagi memuat ulang data', (tester) async {
    final controller = await createLoggedInController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrapWithTheme(
        AssignmentsScreen(
          controller: controller,
          repository: fastRepository(simulateFailure: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat data'), findsOneWidget);
  });
}
