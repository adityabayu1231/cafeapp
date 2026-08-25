import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cafeapp/core/theme/app_colors.dart';
import 'package:cafeapp/features/cafe/presentation/widgets/cafe_open_status_badge.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('displays "Buka" text with success color when open', (tester) async {
    await tester.pumpWidget(wrap(const CafeOpenStatusBadge(openStatus: 'Buka')));

    expect(find.text('Buka'), findsOneWidget);

    final textWidget = tester.widget<Text>(find.text('Buka'));
    expect(textWidget.style?.color, AppColors.success);
  });

  testWidgets('displays "Tutup" text with error color when closed', (tester) async {
    await tester.pumpWidget(wrap(const CafeOpenStatusBadge(openStatus: 'Tutup')));

    expect(find.text('Tutup'), findsOneWidget);

    final textWidget = tester.widget<Text>(find.text('Tutup'));
    expect(textWidget.style?.color, AppColors.error);
  });

  testWidgets('does not compute status itself, only renders given value', (tester) async {
    // Sengaja kirim value yang secara logika "salah" (misal harusnya buka tapi
    // dikirim Tutup) — widget WAJIB tetap render apa adanya, membuktikan tidak
    // ada logika waktu/kalkulasi ulang di sisi Flutter, sesuai plan.md §5.
    await tester.pumpWidget(wrap(const CafeOpenStatusBadge(openStatus: 'Tutup')));
    expect(find.text('Buka'), findsNothing);
    expect(find.text('Tutup'), findsOneWidget);
  });
}