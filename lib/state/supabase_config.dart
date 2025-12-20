import 'package:flutter_riverpod/flutter_riverpod.dart';

// Centralized Supabase configuration flags derived from dart-define.
// This avoids accessing Supabase.instance when not initialized.

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

bool get supabaseEnabled =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

final supabaseEnabledProvider = Provider<bool>((ref) => supabaseEnabled);
