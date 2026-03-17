import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assistbridge/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AssistBridgeApp());

    // Verify app loads (basic smoke test)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
