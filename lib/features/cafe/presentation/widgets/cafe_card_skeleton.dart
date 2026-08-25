import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/skeleton_box.dart';

class CafeCardSkeleton extends StatelessWidget {
  const CafeCardSkeleton({super.key});

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
            SkeletonBox(width: 180, height: 18),
            SizedBox(height: AppSpacing.xs),
            SkeletonBox(width: 100, height: 14),
            SizedBox(height: AppSpacing.sm),
            SkeletonBox(width: 60, height: 20, borderRadius: AppSpacing.radiusInput),
          ],
        ),
      ),
    );
  }
}