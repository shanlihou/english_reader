// This is a basic Flutter widget test for English Reader app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:english_reader/main.dart';
import 'package:provider/provider.dart';
import 'package:english_reader/services/theme_provider.dart';

void main() {
  testWidgets('English Reader app smoke test', (WidgetTester tester) async {
    // Build our app with ThemeProvider and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // Verify that our app starts with the correct title.
    expect(find.text('English Reader'), findsOneWidget);
    expect(find.text('英语阅读器'), findsOneWidget);

    // Verify that the main UI elements are present.
    expect(find.byIcon(Icons.book), findsOneWidget);
    expect(find.byIcon(Icons.file_open), findsOneWidget);
    expect(find.text('选择文本文件'), findsOneWidget);
  });
}
