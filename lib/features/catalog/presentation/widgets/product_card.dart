import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_option_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final List<ProductOptionEntity> selectedOptions;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.selectedOptions = const [],
    this.onTap,
  });

  int get _displayedPrice {
    final extraTotal = selectedOptions.fold<int>(0, (sum, option) => sum + option.extraPrice);
    return product.basePrice + extraTotal;
  }

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
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTextStyles.heading2),
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        product.description!,
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _formatRupiah(_displayedPrice),
                      style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                    ),
                    if (!product.isAvailable) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tidak tersedia',
                        style: AppTextStyles.caption.copyWith(color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}