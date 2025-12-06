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
    if (_data is List) {
      final list = (_data as List);
      if (list.isNotEmpty) {
        return FakePostgrestTransformBuilder(list.first as PostgrestMap);
      }
      return FakePostgrestTransformBuilder(<String, dynamic>{});
    }
    return FakePostgrestTransformBuilder(_data as PostgrestMap);
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
  PostgrestFilterBuilder<T> gte(String column, Object value) {
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
    if (_data is List) {
      final list = (_data as List);
      if (list.isNotEmpty) {
        return FakePostgrestTransformBuilder(list.first as PostgrestMap);
      }
      return FakePostgrestTransformBuilder(<String, dynamic>{});
    }
    return FakePostgrestTransformBuilder(_data as PostgrestMap);
  }

  @override
  PostgrestTransformBuilder<T> limit(int count, {String? referencedTable}) {
    return FakePostgrestTransformBuilder(_data);
  }

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    final list = _data is List
        ? (_data as List).cast<Map<String, dynamic>>()
        : _data is Map
        ? <Map<String, dynamic>>[_data as Map<String, dynamic>]
        : <Map<String, dynamic>>[];
    return FakePostgrestTransformBuilder<PostgrestList>(list);
  }
}
