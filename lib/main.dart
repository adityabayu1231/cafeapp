import 'package:flutter/material.dart';
import 'features/auth/injection_container.dart' as auth_di;
import 'features/cafe/injection_container.dart' as cafe_di;
import 'features/catalog/injection_container.dart' as catalog_di;
import 'features/cart/injection_container.dart' as cart_di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/wallet/injection_container.dart' as wallet_di;
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_event.dart';
import 'features/checkout/injection_container.dart' as checkout_di;
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await auth_di.initAuthModule(
    onUnauthenticated: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    },
  );

  await cafe_di.initCafeModule(
    onUnauthenticated: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    },
  );

  await catalog_di.initCatalogModule(
    onUnauthenticated: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    },
  );

  await cart_di.initCartModule();

  await wallet_di.initWalletModule(
    onUnauthenticated: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    },
  );

  await checkout_di.initCheckoutModule(
    onUnauthenticated: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
      );
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartBloc>(create: (_) => cart_di.sl<CartBloc>()..add(const CartStarted())),
        BlocProvider<WalletBloc>(
          create: (_) => wallet_di.sl<WalletBloc>()..add(const WalletBalanceRequested()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Cafe App',
        theme: ThemeData(primarySwatch: Colors.brown),
        home: const AuthGate(),
      ),
    );
  }
}