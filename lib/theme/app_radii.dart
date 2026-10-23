import 'package:flutter/material.dart';

/// Radius seragam untuk kartu, tombol, kolom input, chip, dan modal.
class AppRadii {
  const AppRadii._();

  static const BorderRadius input = BorderRadius.all(Radius.circular(12));
  static const BorderRadius button = BorderRadius.all(Radius.circular(12));
  static const BorderRadius card = BorderRadius.all(Radius.circular(16));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(20),
  );
  static const BorderRadius chip = BorderRadius.all(Radius.circular(999));
}
