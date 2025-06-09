import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for accessing the Supabase authentication instance
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return Supabase.instance.client.auth;
});
