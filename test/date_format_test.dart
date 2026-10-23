import 'package:bas/core/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormat', () {
    test('longDate menulis tanggal lengkap berbahasa Indonesia', () {
      expect(
        DateFormat.longDate(DateTime(2026, 10, 22)),
        'Kamis, 22 Oktober 2026',
      );
    });

    test('shortDate menulis tanggal ringkas', () {
      expect(DateFormat.shortDate(DateTime(2026, 1, 5)), '5 Jan 2026');
    });

    test('shortDay dan dayLong menulis nama hari', () {
      expect(DateFormat.shortDay(DateTime(2026, 1, 5)), 'Sen');
      expect(DateFormat.dayLong(DateTime(2026, 1, 5)), 'Senin');
    });

    test('time memakai format 24 jam', () {
      expect(DateFormat.time(DateTime(2026, 1, 5, 8, 5)), '08:05');
    });

    test('relativeDeadline membedakan hari ini, besok, dan terlambat', () {
      final now = DateTime(2026, 1, 5, 10);

      expect(
        DateFormat.relativeDeadline(DateTime(2026, 1, 5, 23), now: now),
        'Hari ini 23:00',
      );
      expect(
        DateFormat.relativeDeadline(DateTime(2026, 1, 6, 8), now: now),
        'Besok 08:00',
      );
      expect(
        DateFormat.relativeDeadline(DateTime(2026, 1, 8, 8), now: now),
        '3 hari lagi',
      );
      expect(
        DateFormat.relativeDeadline(DateTime(2026, 1, 2, 8), now: now),
        'Lewat 3 hari',
      );
    });
  });
}
