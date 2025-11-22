double clampDouble(double value, double min, double max) {
  return value.clamp(min, max);
}

int clampInt(int value, int min, int max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

double clamp01(double value) {
  return value.clamp(0.0, 1.0);
}
