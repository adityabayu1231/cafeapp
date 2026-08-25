import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/cafe_entity.dart';
import 'cafe_open_status_badge.dart';

class CafeCard extends StatelessWidget {
  final CafeEntity cafe;
  final VoidCallback? onTap;

  const CafeCard({super.key, required this.cafe, this.onTap});

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
                    Text(cafe.name, style: AppTextStyles.heading2),
                    const SizedBox(height: AppSpacing.xs),
                    Text(cafe.city, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.sm),
                    CafeOpenStatusBadge(openStatus: cafe.openStatus),
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