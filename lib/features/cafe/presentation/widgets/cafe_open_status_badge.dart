import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CafeOpenStatusBadge extends StatelessWidget {
  final String openStatus;

  const CafeOpenStatusBadge({super.key, required this.openStatus});

  bool get _isOpen => openStatus == 'Buka';

  @override
  Widget build(BuildContext context) {
    final color = _isOpen ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        openStatus,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}