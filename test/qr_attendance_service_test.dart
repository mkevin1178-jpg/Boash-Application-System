import 'package:bas/data/demo_data.dart';
import 'package:bas/models/attendance.dart';
import 'package:bas/models/attendance_log.dart';
import 'package:bas/services/qr_attendance_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Senin 2 Nov 2026 08:30 — jam kuliah MK-01 (08:00–10:00) pada data demo.
DateTime _at(int hour, int minute, {int day = 2}) =>
    DateTime(2026, 11, day, hour, minute);

int _epoch(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

String _payload({String code = 'MK-01', int meeting = 3, DateTime? expires}) =>
    'BAS-ATT|1|$code|$meeting|${_epoch(expires ?? _at(9, 30))}';

ScanResult _evaluate(
  String? raw, {
  DateTime? now,
  List<AttendanceLog> existing = const [],
  String npm = '12523030',
}) {
  final service = QrAttendanceService(clock: () => now ?? _at(8, 30));
  return service.evaluate(
    raw: raw,
    npm: npm,
    courses: DemoData.courses,
    schedule: DemoData.buildSchedule(),
    existing: existing,
  );
}

AttendanceLog _log({String npm = '12523030'}) => AttendanceLog(
  npm: npm,
  courseCode: 'MK-01',
  courseName: 'Pemrograman Mobile',
  meeting: 3,
  scannedAt: _at(8, 30),
);

void main() {
  group('QrAttendanceService.evaluate', () {
    test('payload valid → hadir dengan log', () {
      final result = _evaluate(_payload());
      expect(result.status, ScanStatus.hadir);
      expect(result.isSuccess, isTrue);
      expect(result.log!.courseCode, 'MK-01');
      expect(result.log!.meeting, 3);
      expect(result.log!.npm, '12523030');
    });

    test('null / kosong → formatTidakValid', () {
      for (final raw in <String?>[null, '', '   ']) {
        expect(_evaluate(raw).status, ScanStatus.formatTidakValid);
      }
    });

    test('format salah → formatTidakValid', () {
      final exp = _epoch(_at(9, 30));
      for (final raw in [
        'hello',
        'BAS-ATT|2|MK-01|3|$exp',
        'BAS-ATT|1|MK-01|0|$exp',
        'BAS-ATT|1|MK-01|3|abc',
        'BAS-ATT|1|MK-01|3',
        'BAS-ATT|1||3|$exp',
      ]) {
        final result = _evaluate(raw);
        expect(result.status, ScanStatus.formatTidakValid, reason: raw);
        expect(result.log, isNull);
      }
    });

    test('mata kuliah asing → mataKuliahTidakDikenal', () {
      expect(
        _evaluate(_payload(code: 'MK-99')).status,
        ScanStatus.mataKuliahTidakDikenal,
      );
    });

    test('kedaluwarsa 1 detik sebelum now → kedaluwarsa', () {
      final expired = _at(8, 30).subtract(const Duration(seconds: 1));
      expect(
        _evaluate(_payload(expires: expired)).status,
        ScanStatus.kedaluwarsa,
      );
    });

    test('hari salah (Selasa) → diLuarJadwal', () {
      expect(
        _evaluate(
          _payload(expires: _at(9, 30, day: 3)),
          now: _at(8, 30, day: 3),
        ).status,
        ScanStatus.diLuarJadwal,
      );
    });

    test('terlalu pagi (07:30) → diLuarJadwal', () {
      expect(
        _evaluate(_payload(), now: _at(7, 30)).status,
        ScanStatus.diLuarJadwal,
      );
    });

    test('dalam toleransi (07:50) → hadir', () {
      expect(_evaluate(_payload(), now: _at(7, 50)).status, ScanStatus.hadir);
    });

    test('setelah jam selesai (10:01) → diLuarJadwal', () {
      expect(
        _evaluate(_payload(expires: _at(11, 0)), now: _at(10, 1)).status,
        ScanStatus.diLuarJadwal,
      );
    });

    test('toleransi dapat diubah lewat konstruktor', () {
      final service = QrAttendanceService(
        clock: () => _at(7, 30),
        earlyWindow: const Duration(minutes: 30),
      );
      final result = service.evaluate(
        raw: _payload(),
        npm: '12523030',
        courses: DemoData.courses,
        schedule: DemoData.buildSchedule(),
        existing: const [],
      );
      expect(result.status, ScanStatus.hadir);
    });

    test('duplikat (npm, matkul, pertemuan) → sudahTercatat', () {
      expect(
        _evaluate(_payload(), existing: [_log()]).status,
        ScanStatus.sudahTercatat,
      );
    });

    test('log milik NPM lain tidak dianggap duplikat', () {
      expect(
        _evaluate(_payload(), existing: [_log(npm: '99999999')]).status,
        ScanStatus.hadir,
      );
    });

    test('kode legacy fase 1 tidak diterima pada fase 2', () {
      final result = _evaluate('ABSEN-TRM-2026');
      expect(result.status, ScanStatus.formatTidakValid);
      expect(result.isSuccess, isFalse);
      expect(result.log, isNull);
    });
  });

  group('AttendanceRecord.copyWith', () {
    test('mengubah total & hadir, field lain tetap', () {
      const record = AttendanceRecord(
        courseCode: 'MK-01',
        courseName: 'Pemrograman Mobile',
        totalMeeting: 10,
        attended: 8,
        sick: 1,
        permission: 1,
        missed: 0,
      );
      final updated = record.copyWith(totalMeeting: 11, attended: 9);
      expect(updated.totalMeeting, 11);
      expect(updated.attended, 9);
      expect(updated.sick, 1);
      expect(updated.courseCode, 'MK-01');
    });
  });
}
