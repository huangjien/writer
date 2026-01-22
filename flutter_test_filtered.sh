#!/bin/bash

# 
# USAGE: Instead of running `flutter test ...`, run `./flutter_test_filtered.sh ...`
# This script filters out all the noisy Flutter framework exceptions that cause massive logs

echo "🔧 Using filtered Flutter test runner "
echo "📝 Running: flutter test ${flutter_test_args[*]}"
echo ""

# Set default timeout to 30 seconds if not specified and not a help/version command
timeout_args=()
if [[ "$*" != *"--timeout"* ]] && [[ "$*" != *"--help"* ]] && [[ "$*" != *"-h"* ]] && [[ "$*" != *"--version"* ]]; then
  timeout_args=("--timeout=30s")
fi
flutter_test_args=("$@")
flutter_test_args+=("${timeout_args[@]}")

# Run flutter test with real-time filtering for tail monitoring
# Create a named pipe for real-time processing
temp_file=$(mktemp)

# Start flutter test in background and filter in real-time
flutter test "${flutter_test_args[@]}" 2>&1 | (
  while IFS= read -r line; do
    # Skip unwanted patterns immediately
    if echo "$line" | grep -q '^══╡ EXCEPTION CAUGHT BY\|^══════════════════════════════════════$\|^══════════════════════════════════════════════════════════════════════════════════════════════════$'; then
      continue
    elif echo "$line" | grep -q '^The following assertion was thrown\|^The test description was:\|^Test failed. See exception logs above\.\|^To run this test again:\|^The value of a foundation debug variable was changed\|debugAssertAllFoundationVarsUnset'; then
      continue
    elif echo "$line" | grep -q '^When the exception was thrown\|^(elided one frame from package:stack_trace)$\|^When the exception was thrown, this was the stack:\|#[0-9]\+.*package:flutter\|^<asynchronous suspension>$'; then
      continue
    elif echo "$line" | grep -q '^Warning: At least one test in this suite creates an HttpClient\|When running a test suite that uses TestWidgetsFlutterBinding\|all HTTP requests will return status code 400\|Any test expecting a real network connection and status code will fail'; then
      continue
    elif echo "$line" | grep -q 'To test code that needs an HttpClient, provide your own HttpClient implementation\|so that your test can consistently provide a testable response to the code under test\.'; then
      continue
    elif echo "$line" | grep -E '^[[:space:]]*[0-9]{2}:[0-9]{2} .*loading$|^[[:space:]]*All tests passed!$|^[[:space:]]*Testing ended at$'; then
      continue
    elif echo "$line" | grep -q '#[0-9]\+\s*List\.forEach\|^\s*#.*List\.forEach'; then
      continue
    else
      # Print the line immediately for real-time monitoring
      echo "$line"
    fi
  done
) | tee "$temp_file"

# Get the exit code from flutter test (first command in the pipeline)
exit_code=${PIPESTATUS[0]}

# Clean up temp file
rm -f "$temp_file"
exit $exit_code
