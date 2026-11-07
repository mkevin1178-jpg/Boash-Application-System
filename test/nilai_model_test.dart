import 'package:bas/features/nilai/data/models/nilai_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Nilai.fromJson', () {
    test('mem-parse respons normal sesuai contoh API', () {
      final nilai = Nilai.fromJson(<String, dynamic>{
        'id': 162801,
        'kd_matkul': 'GC327',
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
        'am': '3.5',
        'mutu': '10.5',
        'thn_akademik': '2023/2024',
        'semester': '1',
        'tahun': '',
        'tri_semester': '',
        'bmanual': null,
      });

      expect(nilai.id, 162801);
      expect(nilai.kdMatkul, 'GC327');
      expect(nilai.npm, '12523030');
      expect(nilai.uas, 70);
      expect(nilai.uts, 75);
      expect(nilai.quis, 72);
      expect(nilai.tugas, 80);
      expect(nilai.hadir, 100);
      expect(nilai.naUas, 17.5);
      expect(nilai.naUts, 15);
      expect(nilai.naQuis, 10.8);
      expect(nilai.naTugas, 16);
      expect(nilai.naHadir, 20);
      expect(nilai.hm, 'B+');
      expect(nilai.na, 79.3);
      expect(nilai.am, 3.5);
      expect(nilai.mutu, 10.5);
      expect(nilai.thnAkademik, '2023/2024');
      expect(nilai.semester, 1);
      expect(nilai.semesterLabel, '2023/2024 • Ganjil');
    });

    test('field null, kosong, dan tidak valid tidak membuat crash', () {
      final nilai = Nilai.fromJson(<String, dynamic>{
        'id': null,
        'kd_matkul': null,
        'npm': null,
        'uas': null,
        'uts': '',
        'quis': 'null',
        'tugas': 'bukan angka',
        'hadir': '12,5',
        'na_uas': null,
        'na_uts': '',
        'na_quis': 'null',
        'na_tugas': 'abc',
        'na_hadir': null,
        'hm': null,
        'na': '',
        'am': null,
        'mutu': 'null',
        'thn_akademik': null,
        'semester': null,
      });

      expect(nilai.id, 0);
      expect(nilai.kdMatkul, '');
      expect(nilai.npm, '');
      expect(nilai.uas, 0);
      expect(nilai.uts, 0);
      expect(nilai.quis, 0);
      expect(nilai.tugas, 0);
      expect(nilai.hadir, 12.5);
      expect(nilai.naUas, 0);
      expect(nilai.naUts, 0);
      expect(nilai.naQuis, 0);
      expect(nilai.naTugas, 0);
      expect(nilai.naHadir, 0);
      expect(nilai.hm, '');
      expect(nilai.na, 0);
      expect(nilai.am, 0);
      expect(nilai.mutu, 0);
      expect(nilai.thnAkademik, '');
      expect(nilai.semester, 0);
    });

    test('menerima angka numerik langsung dan semester genap', () {
      final nilai = Nilai.fromJson(<String, dynamic>{
        'id': 7,
        'kd_matkul': 'GC302',
        'npm': 12523030,
        'uas': 70,
        'uts': 75.5,
        'quis': 72,
        'tugas': 80,
        'hadir': 100,
        'na_uas': 17.5,
        'na_uts': 15.1,
        'na_quis': 10.8,
        'na_tugas': 16,
        'na_hadir': 20,
        'hm': 'B+',
        'na': 79.4,
        'am': 3.5,
        'mutu': 10.5,
        'thn_akademik': '2024/2025',
        'semester': 2,
      });

      expect(nilai.id, 7);
      expect(nilai.npm, '12523030');
      expect(nilai.uts, 75.5);
      expect(nilai.semester, 2);
      expect(nilai.semesterLabel, '2024/2025 • Genap');
    });
  });
}
