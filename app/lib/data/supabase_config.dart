import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralizes Supabase setup. No credentials are committed to source control.
///
/// Configure at build/run time with:
/// --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co
/// --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
///
/// The anon/publishable key is intended for client apps; security must be
/// enforced with Row Level Security policies. Never use a service-role key here.
class SupabaseConfig {
  SupabaseConfig._();

  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint(
        'Supabase is not configured. Portal Taller will start in demo/local mode.',
      );
      return;
    }

    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }

  static SupabaseClient? get client {
    if (!isConfigured) return null;
    return Supabase.instance.client;
  }
}
