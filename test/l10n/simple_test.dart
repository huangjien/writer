import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  test('Basic zh strings', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(l10n.confirmDeleteDescription('测试'), '将从云端删除“测试”。是否确认？');
  });
}
