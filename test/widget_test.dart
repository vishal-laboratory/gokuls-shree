// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gokul_shree_app/src/app.dart';
import 'package:gokul_shree_app/src/routing/app_router.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Wrap with ProviderScope and override goRouterProvider to avoid Supabase dependency
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goRouterProvider.overrideWithValue(
            GoRouter(
              routes: [
                GoRoute(path: '/', builder: (context, state) => const SizedBox()),
              ],
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app builds without crashing.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
