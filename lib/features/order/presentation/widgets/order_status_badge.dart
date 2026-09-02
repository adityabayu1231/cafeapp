import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  const OrderStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'finished':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _label {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'preparing':
        return 'Diproses';
      case 'finished':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(color: _color, fontWeight: FontWeight.bold),
      ),
    );
  }
}