import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../injection_container.dart';
import '../bloc/cafe_detail_bloc.dart';
import '../bloc/cafe_detail_event.dart';
import '../bloc/cafe_detail_state.dart';
import '../widgets/cafe_open_status_badge.dart';
import '../widgets/operating_hour_row.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';

const String _storageBaseUrl = 'http://auth-api.test/storage/';

class CafeDetailPage extends StatelessWidget {
  final int cafeId;

  const CafeDetailPage({super.key, required this.cafeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CafeDetailBloc>()..add(CafeDetailRequested(cafeId)),
      child: const _CafeDetailView(),
    );
  }
}

class _CafeDetailView extends StatelessWidget {
  const _CafeDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Detail Cafe', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<CafeDetailBloc, CafeDetailState>(
        builder: (context, state) {
          if (state is CafeDetailLoading) {
            return const _CafeDetailSkeleton();
          }

          if (state is CafeDetailError) {
            return EmptyState(icon: Icons.error_outline, message: state.message);
          }

          if (state is CafeDetailLoaded) {
            final detail = state.detail;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (detail.photos.isNotEmpty)
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: detail.photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                            child: Image.network(
                              '$_storageBaseUrl${detail.photos[index].photoPath}',
                              width: 240,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 240,
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const EmptyState(icon: Icons.image_not_supported_outlined, message: 'Belum ada foto cafe.'),
                  const SizedBox(height: AppSpacing.lg),
                  Text(detail.cafe.name, style: AppTextStyles.heading1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(detail.cafe.address, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  CafeOpenStatusBadge(openStatus: detail.cafe.openStatus),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CatalogPage(cafeId: detail.cafe.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text('Lihat Menu'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text('Jam Operasional', style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.sm),
                  if (detail.operatingHours.isEmpty)
                    const Text(
                      'Jam operasional belum tersedia.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    )
                  else
                    ...(List.of(detail.operatingHours)
                      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek)))
                        .map((hour) => OperatingHourRow(hour: hour)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CafeDetailSkeleton extends StatelessWidget {
  const _CafeDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: double.infinity, height: 180),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(width: 220, height: 24),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 160, height: 16),
        ],
      ),
    );
  }
}