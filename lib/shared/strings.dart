String? trimToNull(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

String trimOrEmpty(String? s) {
  if (s == null) return '';
  final t = s.trim();
  return t.isEmpty ? '' : t;
}

bool isBlank(String? s) {
  if (s == null) return true;
  return s.trim().isEmpty;
}

String trimOrDefault(String? s, String defaultValue) {
  if (s == null) return defaultValue;
  final t = s.trim();
  return t.isEmpty ? defaultValue : t;
}
