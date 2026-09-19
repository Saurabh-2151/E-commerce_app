import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce_app/main.dart';

void main() {
  testWidgets('App renders SplashScreen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopEasyApp());

    expect(find.text('ShopEasy'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_rounded), findsOneWidget);
  });
}
