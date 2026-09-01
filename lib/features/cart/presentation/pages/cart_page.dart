import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_item_card_skeleton.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatRupiah(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final posFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Keranjang', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isLoading) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, __) => const CartItemCardSkeleton(),
            );
          }

          if (state.items.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              message: 'Keranjang kamu masih kosong.\nYuk pilih menu favoritmu!',
            );
          }

          return Column(
            children: [
              if (state.cafeName != null)
                Container(
                  width: double.infinity,
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        state.cafeName!,
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return CartItemCard(
                      item: item,
                      onRemove: () {
                        context.read<CartBloc>().add(ItemRemovedFromCart(item.mergeKey));
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total (perkiraan)', style: AppTextStyles.body),
                          Text(
                            _formatRupiah(state.totalPreview),
                            style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      PrimaryButton(
                        label: 'Checkout',
                        onPressed: () {
                          // TODO(F-4): navigasi ke CheckoutPage begitu CheckoutBloc tersedia.
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}