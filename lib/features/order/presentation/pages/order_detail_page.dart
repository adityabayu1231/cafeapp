import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../injection_container.dart';
import '../bloc/order_detail_bloc.dart';
import '../bloc/order_detail_event.dart';
import '../bloc/order_detail_state.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailPage extends StatelessWidget {
  final int orderId;
  const OrderDetailPage({super.key, required this.orderId});

  static const _cancellableStatuses = ['pending', 'preparing'];

  String _formatRupiah(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final posFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderDetailBloc>()..add(OrderDetailRequested(orderId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Detail Order', style: TextStyle(color: Colors.white)),
        ),
        body: BlocConsumer<OrderDetailBloc, OrderDetailState>(
          listener: (context, state) {
            if (state is OrderDetailLoaded && state.cancelErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.cancelErrorMessage!)),
              );
            }
          },
          builder: (context, state) {
            if (state is OrderDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderDetailError) {
              return EmptyState(icon: Icons.wifi_off, message: state.message);
            }

            if (state is OrderDetailLoaded) {
              final order = state.order;
              final canCancel = _cancellableStatuses.contains(order.status);

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #${order.id}', style: AppTextStyles.heading1),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: ListView.separated(
                        itemCount: order.items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.quantity}x Produk #${item.productId}', style: AppTextStyles.body),
                              if (item.options.isNotEmpty)
                                Text(
                                  item.options.map((o) => o.optionValue).join(', '),
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              Text(_formatRupiah(item.subtotal), style: AppTextStyles.body),
                            ],
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: AppTextStyles.heading2),
                        Text(
                          _formatRupiah(order.totalAmount),
                          style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    if (canCancel) ...[
                      const SizedBox(height: AppSpacing.md),
                      PrimaryButton(
                        label: 'Batalkan Order',
                        isLoading: state.isCancelling,
                        onPressed: () {
                          context.read<OrderDetailBloc>().add(const OrderCancelRequested());
                        },
                      ),
                    ],
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}