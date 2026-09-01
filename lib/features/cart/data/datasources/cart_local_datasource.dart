import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartLocalDataSource {
  Future<({List<CartItemEntity> items, int? cafeId, String? cafeName})> getCart();

  Future<void> saveCart({
    required List<CartItemEntity> items,
    required int? cafeId,
    required String? cafeName,
  });
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const _itemsKey = 'cart_items';
  static const _cafeIdKey = 'cart_cafe_id';
  static const _cafeNameKey = 'cart_cafe_name';

  final SharedPreferences prefs;

  CartLocalDataSourceImpl(this.prefs);

  @override
  Future<({List<CartItemEntity> items, int? cafeId, String? cafeName})> getCart() async {
    final raw = prefs.getString(_itemsKey);
    final items = raw == null
        ? <CartItemEntity>[]
        : (jsonDecode(raw) as List)
        .map((e) => CartItemEntity.fromJson(e as Map<String, dynamic>))
        .toList();

    return (
    items: items,
    cafeId: prefs.getInt(_cafeIdKey),
    cafeName: prefs.getString(_cafeNameKey),
    );
  }

  @override
  Future<void> saveCart({
    required List<CartItemEntity> items,
    required int? cafeId,
    required String? cafeName,
  }) async {
    await prefs.setString(_itemsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
    if (cafeId != null) {
      await prefs.setInt(_cafeIdKey, cafeId);
    } else {
      await prefs.remove(_cafeIdKey);
    }
    if (cafeName != null) {
      await prefs.setString(_cafeNameKey, cafeName);
    } else {
      await prefs.remove(_cafeNameKey);
    }
  }
}