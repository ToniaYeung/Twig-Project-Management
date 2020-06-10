import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findKeyAndExpectOne(String key) {
  Finder finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  return finder;
}

void findKeyAndExpectNothing(String key) {
  Finder finder = find.byKey(Key(key));
  expect(finder, findsNothing);
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
