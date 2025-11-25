import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakePostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  final T _data;

  FakePostgrestTransformBuilder(this._data);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) async {
    return onValue(_data);
  }

  @override
  PostgrestTransformBuilder<T> limit(int count, {String? referencedTable}) {
    return this;
  }

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = true,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    return this;
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    if (_data is List && (_data as List).isNotEmpty) {
      return FakePostgrestTransformBuilder(
        (_data as List).first as PostgrestMap,
      );
    }
    throw StateError('List is empty or not a list');
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final T _data;

  FakePostgrestFilterBuilder(this._data);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(T value) onValue, {
    Function? onError,
  }) async {
    return onValue(_data);
  }

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    return this;
  }

  @override
  PostgrestTransformBuilder<T> order(
    String column, {
    bool ascending = true,
    bool nullsFirst = false,
    String? referencedTable,
  }) {
    return FakePostgrestTransformBuilder(_data);
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    if (_data is List && (_data as List).isNotEmpty) {
      return FakePostgrestTransformBuilder(
        (_data as List).first as PostgrestMap,
      );
    }
    // If it's already a map, just return a builder with it? No, usually single() is called on a list builder.
    // But T could be PostgrestList.
    if (_data is Map) {
      return FakePostgrestTransformBuilder(_data as PostgrestMap);
    }
    throw StateError('Cannot call single() on empty list or invalid type');
  }

  @override
  PostgrestTransformBuilder<T> limit(int count, {String? referencedTable}) {
    return FakePostgrestTransformBuilder(_data);
  }
}
