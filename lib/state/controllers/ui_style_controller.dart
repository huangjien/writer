import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:writer/theme/ui_styles.dart';
import 'package:writer/state/theme_prefs.dart';

const String _prefUiStyleFamily = prefUiStyleFamily;

class UiStyleState {
  final UiStyleFamily family;

  const UiStyleState({required this.family});

  UiStyleState copyWith({UiStyleFamily? family}) =>
      UiStyleState(family: family ?? this.family);
}

class UiStyleController extends StateNotifier<UiStyleState> {
  UiStyleController(this._prefs) : super(_initialState(_prefs));

  static UiStyleState _initialState(SharedPreferences prefs) {
    final family = decodeUiStyleFamily(prefs.getString(_prefUiStyleFamily));
    return UiStyleState(family: family);
  }

  final SharedPreferences _prefs;

  Future<void> setStyle(UiStyleFamily family) async {
    state = state.copyWith(family: family);
    await _prefs.setString(_prefUiStyleFamily, encodeUiStyleFamily(family));
  }
}

final uiStyleControllerProvider =
    StateNotifierProvider<UiStyleController, UiStyleState>((ref) {
      throw UnimplementedError(
        'uiStyleControllerProvider must be overridden in ProviderScope/main.dart',
      );
    });
