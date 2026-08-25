import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../injection_container.dart';
import '../bloc/cafe_list_bloc.dart';
import '../bloc/cafe_list_event.dart';
import '../bloc/cafe_list_state.dart';
import '../widgets/cafe_card.dart';
import '../widgets/cafe_card_skeleton.dart';
import 'cafe_detail_page.dart';

class CafeListPage extends StatelessWidget {
  const CafeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CafeListBloc>()..add(const CafeListRequested()),
      child: const _CafeListView(),
    );
  }
}

class _CafeListView extends StatefulWidget {
  const _CafeListView();

  @override
  State<_CafeListView> createState() => _CafeListViewState();
}

class _CafeListViewState extends State<_CafeListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Awake Coffee', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<CafeListBloc>().add(CafeSearchChanged(value));
              },
              decoration: InputDecoration(
                hintText: 'Cari cafe berdasarkan kota...',
                hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: BlocBuilder<CafeListBloc, CafeListState>(
                builder: (context, state) {
                  if (state is CafeListLoading) {
                    return ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, __) => const CafeCardSkeleton(),
                    );
                  }

                  if (state is CafeListError) {
                    return EmptyState(
                      icon: Icons.wifi_off,
                      message: state.message,
                    );
                  }

                  if (state is CafeListLoaded) {
                    if (state.cafes.isEmpty) {
                      return const EmptyState(
                        icon: Icons.local_cafe_outlined,
                        message: 'Belum ada cafe ditemukan.',
                      );
                    }
                    return ListView.separated(
                      itemCount: state.cafes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final cafe = state.cafes[index];
                        return CafeCard(
                          cafe: cafe,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CafeDetailPage(cafeId: cafe.id)),
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}