import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/state/mock_providers.dart';

void main() {
  test('mock providers return data', () async {
    final container = ProviderContainer();
    final novels = await container.read(mockNovelsProvider.future);
    expect(novels.isNotEmpty, true);
    final chapters = await container.read(
      mockChaptersProvider('novel-001').future,
    );
    expect(chapters.isNotEmpty, true);
    final progress = await container.read(
      mockLastProgressProvider('novel-001').future,
    );
    expect(progress, null);
  });
}
