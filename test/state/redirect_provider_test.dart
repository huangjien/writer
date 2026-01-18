import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/state/redirect_provider.dart';

void main() {
  group('AuthRedirectNotifier', () {
    late AuthRedirectNotifier notifier;

    setUp(() {
      notifier = AuthRedirectNotifier();
    });

    group('saveRouteAndRedirect', () {
      test('saves regular route path', () {
        notifier.saveRouteAndRedirect('/library');
        expect(notifier.state, '/library');
      });

      test('saves nested route path', () {
        notifier.saveRouteAndRedirect('/novels/123/chapters/456');
        expect(notifier.state, '/novels/123/chapters/456');
      });

      test('saves root path "/"', () {
        notifier.saveRouteAndRedirect('/');
        expect(notifier.state, '/');
      });

      test('saves "/" for /auth route', () {
        notifier.saveRouteAndRedirect('/auth');
        expect(notifier.state, '/');
      });

      test('saves "/" for /signup route', () {
        notifier.saveRouteAndRedirect('/signup');
        expect(notifier.state, '/');
      });

      test('saves "/" for /forgot-password route', () {
        notifier.saveRouteAndRedirect('/forgot-password');
        expect(notifier.state, '/');
      });

      test('saves "/" for /reset-password route', () {
        notifier.saveRouteAndRedirect('/reset-password');
        expect(notifier.state, '/');
      });

      test('overwrites previously saved route', () {
        notifier.saveRouteAndRedirect('/library');
        expect(notifier.state, '/library');

        notifier.saveRouteAndRedirect('/novels/123');
        expect(notifier.state, '/novels/123');
      });

      test('handles empty string path', () {
        notifier.saveRouteAndRedirect('');
        expect(notifier.state, '/');
      });

      test('handles path with query parameters', () {
        notifier.saveRouteAndRedirect('/library?sort=recent');
        expect(notifier.state, '/library?sort=recent');
      });

      test('handles path with fragment', () {
        notifier.saveRouteAndRedirect('/library#section');
        expect(notifier.state, '/library#section');
      });
    });

    group('getRedirectRoute', () {
      test('returns saved route when state is set', () {
        notifier.saveRouteAndRedirect('/library');
        expect(notifier.getRedirectRoute(), '/library');
      });

      test('returns "/" when state is null', () {
        expect(notifier.state, isNull);
        expect(notifier.getRedirectRoute(), '/');
      });

      test('returns "/" after clearing redirect', () {
        notifier.saveRouteAndRedirect('/library');
        notifier.clearRedirect();
        expect(notifier.getRedirectRoute(), '/');
      });

      test('returns saved nested route', () {
        notifier.saveRouteAndRedirect('/novels/123/chapters/456');
        expect(notifier.getRedirectRoute(), '/novels/123/chapters/456');
      });
    });

    group('clearRedirect', () {
      test('sets state to null', () {
        notifier.saveRouteAndRedirect('/library');
        expect(notifier.state, '/library');

        notifier.clearRedirect();
        expect(notifier.state, isNull);
      });

      test('handles clearing when state is already null', () {
        expect(notifier.state, isNull);
        notifier.clearRedirect();
        expect(notifier.state, isNull);
      });

      test('can save new route after clearing', () {
        notifier.saveRouteAndRedirect('/library');
        notifier.clearRedirect();
        expect(notifier.state, isNull);

        notifier.saveRouteAndRedirect('/novels/123');
        expect(notifier.state, '/novels/123');
      });
    });

    group('integration tests', () {
      test('complete flow: save, get, clear', () {
        // Initial state
        expect(notifier.state, isNull);
        expect(notifier.getRedirectRoute(), '/');

        // Save route
        notifier.saveRouteAndRedirect('/library');
        expect(notifier.state, '/library');
        expect(notifier.getRedirectRoute(), '/library');

        // Clear redirect
        notifier.clearRedirect();
        expect(notifier.state, isNull);
        expect(notifier.getRedirectRoute(), '/');
      });

      test('handles auth route flow correctly', () {
        // Save auth route (should save '/' instead)
        notifier.saveRouteAndRedirect('/auth');
        expect(notifier.state, '/');
        expect(notifier.getRedirectRoute(), '/');

        // Clear and save regular route
        notifier.clearRedirect();
        notifier.saveRouteAndRedirect('/novels/123');
        expect(notifier.state, '/novels/123');
        expect(notifier.getRedirectRoute(), '/novels/123');
      });

      test('handles multiple route saves and clears', () {
        notifier.saveRouteAndRedirect('/library');
        expect(notifier.getRedirectRoute(), '/library');

        notifier.saveRouteAndRedirect('/novels/123');
        expect(notifier.getRedirectRoute(), '/novels/123');

        notifier.saveRouteAndRedirect('/settings');
        expect(notifier.getRedirectRoute(), '/settings');

        notifier.clearRedirect();
        expect(notifier.getRedirectRoute(), '/');

        notifier.saveRouteAndRedirect('/profile');
        expect(notifier.getRedirectRoute(), '/profile');
      });
    });
  });

  group('authRedirectProvider', () {
    test('provides AuthRedirectNotifier instance', () {
      final container = ProviderContainer();
      final notifier = container.read(authRedirectProvider.notifier);

      expect(notifier, isA<AuthRedirectNotifier>());

      container.dispose();
    });

    test('initial state is null', () {
      final container = ProviderContainer();
      final state = container.read(authRedirectProvider);

      expect(state, isNull);

      container.dispose();
    });

    test('notifier can be used to save routes', () {
      final container = ProviderContainer();
      final notifier = container.read(authRedirectProvider.notifier);

      notifier.saveRouteAndRedirect('/library');
      final state = container.read(authRedirectProvider);

      expect(state, '/library');

      container.dispose();
    });
  });
}
