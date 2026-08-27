import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/product_detail_entity.dart';
import '../../domain/entities/product_option_entity.dart';
import '../../injection_container.dart';
import '../bloc/product_detail_bloc.dart';
import '../bloc/product_detail_event.dart';
import '../bloc/product_detail_state.dart';
import '../widgets/product_card.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailBloc>()..add(ProductDetailRequested(productId)),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Detail Produk', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return const _ProductDetailSkeleton();
          }

          if (state is ProductDetailError) {
            return EmptyState(icon: Icons.error_outline, message: state.message);
          }

          if (state is ProductDetailLoaded) {
            return _ProductOptionSelector(detail: state.detail);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProductDetailSkeleton extends StatelessWidget {
  const _ProductDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 220, height: 24),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: 160, height: 16),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(width: double.infinity, height: 90),
        ],
      ),
    );
  }
}

class _ProductOptionSelector extends StatefulWidget {
  final ProductDetailEntity detail;

  const _ProductOptionSelector({required this.detail});

  @override
  State<_ProductOptionSelector> createState() => _ProductOptionSelectorState();
}

class _ProductOptionSelectorState extends State<_ProductOptionSelector> {
  late Map<String, ProductOptionEntity> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {};
    for (final option in widget.detail.options) {
      if (option.isDefault) {
        _selected[option.optionType] = option;
      }
    }
  }

  Map<String, List<ProductOptionEntity>> get _groupedOptions {
    final Map<String, List<ProductOptionEntity>> grouped = {};
    for (final option in widget.detail.options) {
      grouped.putIfAbsent(option.optionType, () => []).add(option);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.detail.product;
    final grouped = _groupedOptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: AppTextStyles.heading1),
          if (product.description != null && product.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              product.description!,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ProductCard(product: product, selectedOptions: _selected.values.toList()),
          const SizedBox(height: AppSpacing.xl),
          if (grouped.isEmpty)
            Text(
              'Produk ini tidak punya opsi kustomisasi.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            )
          else
            ...grouped.entries.map(
                  (entry) => _OptionTypeSection(
                optionType: entry.key,
                options: entry.value,
                selected: _selected[entry.key],
                onSelected: (option) {
                  setState(() => _selected[entry.key] = option);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionTypeSection extends StatelessWidget {
  final String optionType;
  final List<ProductOptionEntity> options;
  final ProductOptionEntity? selected;
  final ValueChanged<ProductOptionEntity> onSelected;

  const _OptionTypeSection({
    required this.optionType,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(optionType, style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: options.map((option) {
              final isSelected = selected?.id == option.id;
              final label = option.extraPrice > 0
                  ? '${option.optionValue} (+Rp${option.extraPrice})'
                  : option.optionValue;
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => onSelected(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}