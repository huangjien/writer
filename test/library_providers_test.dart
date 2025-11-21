import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_reader/features/library/library_providers.dart';

void main() {
  test('library providers have expected defaults and update', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(downloadFeatureFlagProvider), isFalse);
    expect(container.read(downloadStateProvider), isEmpty);
    expect(container.read(removedNovelIdsProvider), isEmpty);

    container
        .read(downloadStateProvider.notifier)
        .update((s) => {...s, 'n1': true});
    expect(container.read(downloadStateProvider)['n1'], isTrue);

    container
        .read(removedNovelIdsProvider.notifier)
        .update((s) => {...s, 'n1'});
    expect(container.read(removedNovelIdsProvider).contains('n1'), isTrue);
  });
}
