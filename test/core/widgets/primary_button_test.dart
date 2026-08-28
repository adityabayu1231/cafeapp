import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cafeapp/core/widgets/primary_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('menampilkan label saat tidak loading', (tester) async {
    await tester.pumpWidget(wrap(
      PrimaryButton(label: 'Login', onPressed: () {}),
    ));

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('menampilkan spinner dan menyembunyikan label saat isLoading true', (tester) async {
    await tester.pumpWidget(wrap(
      PrimaryButton(label: 'Login', isLoading: true, onPressed: () {}),
    ));

    expect(find.text('Login'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('memanggil onPressed saat ditekan (tidak loading)', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      PrimaryButton(label: 'Login', onPressed: () => tapped = true),
    ));

    await tester.tap(find.byType(ElevatedButton));
    expect(tapped, isTrue);
  });

  testWidgets('tombol disabled (tidak bisa ditekan) saat isLoading true', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      PrimaryButton(label: 'Login', isLoading: true, onPressed: () => tapped = true),
    ));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(tapped, isFalse);
  });
}