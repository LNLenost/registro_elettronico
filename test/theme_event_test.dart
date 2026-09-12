import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/core/infrastructure/theme/bloc/theme_event.dart';
import 'package:registro_elettronico/core/infrastructure/theme/theme_data/themes.dart';

void main() {
  test('theme changes with different type or color are distinct events', () {
    final dark = ThemeChanged(type: ThemeType.dark, color: const Color(0xffff0000));
    final light = ThemeChanged(type: ThemeType.light, color: const Color(0xff0000ff));

    expect(dark, isNot(equals(light)));
  });
}
