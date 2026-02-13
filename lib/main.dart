import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gokul_shree_app/src/app.dart';
import 'package:gokul_shree_app/src/core/config/env_config.dart';
import 'package:gokul_shree_app/src/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 App starting...');

  // Load environment configuration
  try {
    debugPrint('📂 Loading .env...');
    await EnvConfig.load();
    debugPrint('✅ Environment config loaded');
  } catch (e) {
    debugPrint('⚠️ Failed to load .env file: $e');
  }

  // Initialize Supabase with credentials from env
  try {
    debugPrint('🗄️ Initializing Supabase...');
    await initializeSupabase();
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Supabase initialization failed: $e');
    debugPrint('🔄 App will work in offline mode with mock data');
  }

  debugPrint('🎨 Calling runApp...');
  runApp(const ProviderScope(child: MyApp()));
}
