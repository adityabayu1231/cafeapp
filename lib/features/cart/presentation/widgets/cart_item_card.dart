import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onRemove;

  const CartItemCard({super.key, required this.item, required this.onRemove});

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
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: AppTextStyles.heading2),
                  if (item.selectedOptions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.selectedOptions.map((o) => o.optionValue).join(', '),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${item.quantity}x ${_formatRupiah(item.unitPrice)}',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatRupiah(item.subtotal),
                    style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}