import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_event.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_state.dart';
import 'package:cafeapp/features/auth/presentation/pages/register_page.dart';

class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState> implements RegisterBloc {}

void main() {
  late MockRegisterBloc registerBloc;

  setUp(() {
    registerBloc = MockRegisterBloc();
    when(() => registerBloc.state).thenReturn(const RegisterInitial());
  });

  Widget buildTestable() {
    return MaterialApp(
      home: BlocProvider<RegisterBloc>.value(
        value: registerBloc,
        child: const RegisterPage(),
      ),
    );
  }

  testWidgets('menampilkan 4 field (nama, email, password, konfirmasi) dan tombol Daftar', (tester) async {
    await tester.pumpWidget(buildTestable());

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.widgetWithText(ElevatedButton, 'Daftar'), findsOneWidget);
  });

  testWidgets('menampilkan validasi saat submit form kosong', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pump();

    expect(find.text('Nama wajib diisi'), findsOneWidget);
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
    expect(find.text('Konfirmasi password wajib diisi'), findsOneWidget);
  });

  testWidgets('menampilkan error saat email format tidak valid', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).at(1), 'bukan-email');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pump();

    expect(find.text('Format email tidak valid'), findsOneWidget);
  });

  testWidgets('menampilkan error saat password kurang dari 8 karakter', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pump();

    expect(find.text('Password minimal 8 karakter'), findsOneWidget);
  });

  testWidgets('menampilkan error saat konfirmasi password tidak cocok', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pump();

    expect(find.text('Password tidak cocok'), findsOneWidget);
  });

  testWidgets('mendispatch RegisterSubmitted saat form valid', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).at(0), 'Budi');
    await tester.enterText(find.byType(TextFormField).at(1), 'budi@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Daftar'));
    await tester.pump();

    verify(() => registerBloc.add(const RegisterSubmitted(
      name: 'Budi',
      email: 'budi@example.com',
      password: 'password123',
      passwordConfirmation: 'password123',
    ))).called(1);
  });

  testWidgets('menampilkan "Password cocok" saat kedua field sama', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.pump();

    expect(find.text('Password cocok'), findsOneWidget);
  });

  testWidgets('menampilkan "Password belum sama" saat kedua field berbeda', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password456');
    await tester.pump();

    expect(find.text('Password belum sama'), findsOneWidget);
  });

  testWidgets('tidak menampilkan indikator saat konfirmasi password masih kosong', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.pump();

    expect(find.text('Password cocok'), findsNothing);
    expect(find.text('Password belum sama'), findsNothing);
  });
}