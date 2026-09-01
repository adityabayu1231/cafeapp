import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/skeleton_box.dart';

class CartItemCardSkeleton extends StatelessWidget {
  const CartItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 140, height: 18),
            SizedBox(height: AppSpacing.xs),
            SkeletonBox(width: 100, height: 12),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(width: 90, height: 20),
          ],
        ),
      ),
    );
  }
}