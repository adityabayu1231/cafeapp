import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/cafe_operating_hour_entity.dart';

const List<String> _dayNames = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
]; // index 0-6, SAMA persis dengan konvensi day_of_week di DATABASE-SCHEMA.md

class OperatingHourRow extends StatelessWidget {
  final CafeOperatingHourEntity hour;

  const OperatingHourRow({super.key, required this.hour});

  @override
  Widget build(BuildContext context) {
    final dayName = _dayNames[hour.dayOfWeek];
    final timeText = hour.isClosed
        ? 'Tutup'
        : '${hour.openTime ?? '-'} - ${hour.closeTime ?? '-'}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dayName, style: AppTextStyles.body),
          Text(
            timeText,
            style: AppTextStyles.body.copyWith(
              color: hour.isClosed ? AppColors.error : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}