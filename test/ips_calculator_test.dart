import 'package:bas/features/nilai/data/models/nilai_model.dart';
import 'package:bas/features/nilai/domain/ips_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

Nilai _nilai({
  required String kode,
  required double am,
  String thnAkademik = '2023/2024',
  int semester = 1,
}) {
  return Nilai.fromJson(<String, dynamic>{
    'id': 1,
    'kd_matkul': kode,
    'npm': '12523030',
    'uas': '70',
    'uts': '75',
    'quis': '72',
    'tugas': '80',
    'hadir': '100',
    'na_uas': '17.5',
    'na_uts': '15',
    'na_quis': '10.8',
    'na_tugas': '16',
    'na_hadir': '20',
    'hm': 'B+',
    'na': '79.3',
    'am': '$am',
    'mutu': '10.5',
    'thn_akademik': thnAkademik,
    'semester': '$semester',
  });
}

void main() {
  group('IpsCalculator', () {
    test('IPS memakai rumus sum(am x SKS) / sum(SKS)', () {
      final values = [
        _nilai(kode: 'GC327', am: 3.5),
        _nilai(kode: 'GC302', am: 3.0),
      ];

      final summary = IpsCalculator.forSemester(values);

      expect(summary.totalSks, 6);
      expect(summary.totalMutu, 19.5);
      expect(summary.ips, 3.25);
      expect(summary.courseCount, 2);
      expect(summary.countedCourseCount, 2);
      expect(summary.unknownCourseCodes, isEmpty);
    });

    test('IPK dihitung dari seluruh semester', () {
      final values = [
        _nilai(kode: 'GC327', am: 3.5),
        _nilai(kode: 'GC302', am: 3.0),
        _nilai(kode: 'GC303', am: 4.0, thnAkademik: '2024/2025', semester: 2),
      ];

      final summary = IpsCalculator.overall(values);

      expect(summary.totalSks, 9);
      expect(summary.totalMutu, 31.5);
      expect(summary.ipk, closeTo(3.5, 0.0001));
      expect(summary.courseCount, 3);
    });

    test('matkul tanpa referensi dikeluarkan dari perhitungan', () {
      final values = [
        _nilai(kode: 'GC327', am: 3.5),
        _nilai(kode: 'GC999', am: 4.0),
      ];

      final summary = IpsCalculator.overall(values);

      expect(summary.totalSks, 3);
      expect(summary.totalMutu, 10.5);
      expect(summary.ipk, 3.5);
      expect(summary.courseCount, 2);
      expect(summary.countedCourseCount, 1);
      expect(summary.unknownCourseCodes, ['GC999']);
    });

    test('semua matkul tanpa referensi menghasilkan IPS 0 tanpa error', () {
      final summary = IpsCalculator.forSemester([
        _nilai(kode: 'GC999', am: 4.0),
      ]);

      expect(summary.totalSks, 0);
      expect(summary.totalMutu, 0);
      expect(summary.ips, 0);
    });

    test('mengelompokkan per semester dan mengurutkan terbaru dulu', () {
      final groups = IpsCalculator.groupBySemester([
        _nilai(kode: 'GC327', am: 3.5),
        _nilai(kode: 'GC302', am: 3.0),
        _nilai(kode: 'GC303', am: 4.0, thnAkademik: '2024/2025', semester: 2),
      ]);

      expect(groups.length, 2);
      expect(groups.first.thnAkademik, '2024/2025');
      expect(groups.first.semester, 2);
      expect(groups.first.label, 'TA 2024/2025 • Genap');
      expect(groups.first.values.length, 1);
      expect(groups.last.thnAkademik, '2023/2024');
      expect(groups.last.semester, 1);
      expect(groups.last.values.length, 2);
      expect(groups.last.summary.ips, 3.25);
    });
  });
}
