import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global navigator key provider
///
/// This provides access to the app's navigator key from anywhere in the app.
/// This is useful for triggering navigation from services or repositories that
/// don't have direct access to a BuildContext.
final globalNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});
