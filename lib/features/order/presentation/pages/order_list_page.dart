import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../injection_container.dart';
import '../bloc/order_list_bloc.dart';
import '../bloc/order_list_event.dart';
import '../bloc/order_list_state.dart';
import '../widgets/order_status_badge.dart';
import 'order_detail_page.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

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
      create: (_) => sl<OrderListBloc>()..add(const OrderListRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Riwayat Order', style: TextStyle(color: Colors.white)),
        ),
        body: BlocBuilder<OrderListBloc, OrderListState>(
          builder: (context, state) {
            if (state is OrderListLoading) {
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, __) => const SkeletonBox(width: double.infinity, height: 80),
              );
            }

            if (state is OrderListError) {
              return EmptyState(icon: Icons.wifi_off, message: state.message);
            }

            if (state is OrderListLoaded) {
              if (state.orders.isEmpty) {
                return const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  message: 'Belum ada riwayat order.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: state.orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return Card(
                    color: AppColors.surface,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order #${order.id}', style: AppTextStyles.heading2),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _formatRupiah(order.totalAmount),
                                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            OrderStatusBadge(status: order.status),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}