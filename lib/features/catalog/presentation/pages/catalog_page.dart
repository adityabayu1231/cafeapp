import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../injection_container.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatelessWidget {
  final int cafeId;

  const CatalogPage({super.key, required this.cafeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CatalogBloc>()..add(CatalogRequested(cafeId)),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView();

  static const Map<String, String> _categoryLabels = {
    'coffee': 'Coffee',
    'non-coffee': 'Non-Coffee',
    'snack': 'Snack',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Menu', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          if (state is CatalogLoading) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, __) => const ProductCardSkeleton(),
            );
          }

          if (state is CatalogError) {
            return EmptyState(icon: Icons.wifi_off, message: state.message);
          }

          if (state is CatalogLoaded) {
            if (state.productsByCategory.isEmpty) {
              return const EmptyState(
                icon: Icons.no_food_outlined,
                message: 'Belum ada produk di cafe ini.',
              );
            }

            final categories = state.productsByCategory.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final products = state.productsByCategory[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                      child: Text(
                        _categoryLabels[category] ?? category,
                        style: AppTextStyles.heading2,
                      ),
                    ),
                    ...products.map(
                          (product) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(productId: product.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}